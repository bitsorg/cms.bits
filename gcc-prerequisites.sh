package: gcc-prerequisites
version: "1.0"
variables:
  gmpVersion:      "6.3.0"
  mpfrVersion:     "4.2.1"
  mpcVersion:      "1.3.1"
  islVersion:      "0.27"
  zlibVersion:     "1.2.13"
  zstdVersion:     "1.5.4"
  bisonVersion:    "3.8.2"
  flexVersion:     "2.6.4"
  binutilsVersion: "2.43.1"
  elfutilsVersion: "0.192"
  m4Version:       "1.4.19"
sources:
  - https://ftp.gnu.org/gnu/gmp/gmp-%(gmpVersion)s.tar.gz
  - https://ftp.gnu.org/gnu/mpfr/mpfr-%(mpfrVersion)s.tar.gz
  - https://ftp.gnu.org/gnu/mpc/mpc-%(mpcVersion)s.tar.gz
  - https://libisl.sourceforge.io/isl-%(islVersion)s.tar.gz
  - https://github.com/madler/zlib/releases/download/v%(zlibVersion)s/zlib-%(zlibVersion)s.tar.gz
  - https://github.com/facebook/zstd/releases/download/v%(zstdVersion)s/zstd-%(zstdVersion)s.tar.gz
  - https://ftp.gnu.org/gnu/bison/bison-%(bisonVersion)s.tar.gz
  - https://github.com/westes/flex/releases/download/v%(flexVersion)s/flex-%(flexVersion)s.tar.gz
  - https://ftp.gnu.org/gnu/binutils/binutils-%(binutilsVersion)s.tar.gz
  - https://sourceware.org/elfutils/ftp/%(elfutilsVersion)s/elfutils-%(elfutilsVersion)s.tar.bz2
  - https://ftp.gnu.org/gnu/m4/m4-%(m4Version)s.tar.gz
patches:
 - gcc-flex-disable-doc.patch
 - gcc-flex-nonfull-path-m4.patch
validate_deps: false
---
for f in "$SOURCEDIR"/*; do
    case "$f" in
        *.tar.gz) tar -xzf "$f" -C "$BUILDDIR";;
        *.tar.bz2) tar -xjf "$f" -C "$BUILDDIR";;
    esac
done

pushd "$BUILDDIR/flex-%(flexVersion)s"
  patch -p1 < $SOURCEDIR/$PATCH0
  patch -p1 < $SOURCEDIR/$PATCH1
popd

# Detect OS and set appropriate compiler toolchain
# macOS uses clang with Objective-C support, Linux uses gcc
OS="$(uname)"
ARCH="$(uname -m)"
if [ "$OS" = "Darwin" ]; then
  export CC="clang"
  export CXX="clang++"
  export CPP="clang -E"
  export CXXCPP="clang++ -E"
  export ADDITIONAL_LANGUAGES=",objc,obj-c++"
  export CONF_GCC_OS_SPEC=""
else
  export CC="gcc"
  export CXX="c++"
  export CPP="cpp"
  export CXXCPP="c++ -E"
  export CONF_GCC_OS_SPEC=""
fi

# Enable Position Independent Code for shared library compatibility
CC="$CC -fPIC"
CXX="$CXX -fPIC"

# Temporary directory for intermediate build tools (not included in final install)
mkdir -p ${INSTALLROOT}/tmp/sw
export PATH=${INSTALLROOT}/tmp/sw/bin:$PATH

# Build zlib with architecture-specific optimizations
# -msse3 enabled only on x86_64 for SIMD performance boost
pushd "$BUILDDIR/zlib-%(zlibVersion)s"
  CONF_FLAGS="-fPIC -O3 -DUSE_MMAP -DUNALIGNED_OK -D_LARGEFILE64_SOURCE=1"
  if [ "$ARCH" = "x86_64" ]; then
    CONF_FLAGS+=" -msse3"
  fi
  CFLAGS="$CONF_FLAGS" ./configure --static --prefix="${INSTALLROOT}/tmp/sw"
  make ${JOBS:+-j $JOBS}
  make install
popd

CXXFLAGS="-O2"
CFLAGS="-O2"
CMS_BITS_MARCH=$(gcc -dumpmachine)
echo $CMS_BITS_MARCH

# Linux-specific builds: these tools are typically pre-installed on macOS
if [ "$OS" = "Linux" ]; then
  # Configure linker options:
  # - gold linker enabled for faster linking on large projects
  # - LTO plugin support for link-time optimization
  CONF_BINUTILS_OPTS="--enable-ld=default --enable-lto --enable-plugins --enable-threads"
  CONF_GCC_WITH_LTO="--enable-ld=default --enable-lto"
  CONF_BINUTILS_OPTS+=" --enable-gold=yes"
  CONF_GCC_WITH_LTO+=" --enable-gold=yes"

  make -C zstd-%(zstdVersion)s/lib ${JOBS:+-j "$JOBS"} \
       install-static install-includes \
       prefix="${INSTALLROOT}/tmp/sw" \
       CPPFLAGS="-fPIC" CFLAGS="-fPIC"

  pushd "$BUILDDIR"/m4-%(m4Version)s
    ./configure --prefix="${INSTALLROOT}/tmp/sw" \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
                CC="${CC}"
    make ${JOBS:+-j "$JOBS"} && echo "   make m4 OK"
    make install && echo "   install m4 OK"
  popd

  pushd "$BUILDDIR"/bison-%(bisonVersion)s
    ./configure --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
                --prefix="${INSTALLROOT}/tmp/sw" \
                CC="${CC}"
    make ${JOBS:+-j "$JOBS"} && echo "   make bison OK"
    make install && echo "   install bison OK"
  popd

  pushd "$BUILDDIR"/flex-%(flexVersion)s
    ./configure --disable-nls --prefix="${INSTALLROOT}/tmp/sw" \
                --enable-static --disable-shared \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
                CC="${CC}" CXX="${CXX}"
    make ${JOBS:+-j "$JOBS"} && echo "   make flex OK"
    make install && echo "   install flex OK"
  popd

  # elfutils: tools for ELF binary inspection and debug info handling
  # --program-prefix='eu-' avoids conflicts with binutils tools
  pushd "$BUILDDIR"/elfutils-%(elfutilsVersion)s
    ./configure --disable-static --with-zlib --without-bzlib --without-lzma --without-libarchive \
                --disable-libdebuginfod --enable-libdebuginfod=dummy --disable-debuginfod \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" --program-prefix='eu-' \
                --disable-silent-rules --prefix="${INSTALLROOT}" \
                CC="gcc" \
                CPPFLAGS="-I${INSTALLROOT}/tmp/sw/include" \
                LDFLAGS="-L${INSTALLROOT}/tmp/sw/lib"
    make ${JOBS:+-j "$JOBS"} && echo "   make elfutils OK"
    make install && echo "   install elfutils OK"
  popd

  # ppc64le: enable cross-compilation targets for SPU and PowerPC
  if [ "$ARCH" = "ppc64le" ]; then
    echo "DETected ppc64le: enabling SPU and powerpc targets"
    CONF_BINUTILS_OPTS+=" --enable-targets=spu --enable-targets=powerpc-linux"
  fi

  pushd "$BUILDDIR"/binutils-%(binutilsVersion)s
    ./configure --disable-static --prefix="${INSTALLROOT}" \
                ${CONF_BINUTILS_OPTS} \
                --disable-werror --enable-deterministic-archives \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" --disable-nls \
                --with-system-zlib --enable-64-bit-bfd \
                CC="$CC" CXX="$CXX" CPP="$CPP" CXXCPP="$CXXCPP" \
                CFLAGS="-I${INSTALLROOT}/include -I${INSTALLROOT}/tmp/sw/include" \
                CXXFLAGS="-I${INSTALLROOT}/include -I${INSTALLROOT}/tmp/sw/include" \
                LDFLAGS="-L${INSTALLROOT}/lib -L${INSTALLROOT}/tmp/sw/lib"

    make ${JOBS:+-j "$JOBS"} && echo "   make binutils OK"

    # Replace symlinks with copies for systems that don't handle symlinks well
    find . -name Makefile \
      -exec perl -p -i -e 's|LN = ln|LN = cp -p|;s|ln ([^-])|cp -p $1|g' {} \;
    make install && echo "   install binutils OK"
  popd
fi
echo Done

# GMP, MPFR, MPC, ISL: math libraries required by GCC
# Build order matters: GMP -> MPFR -> MPC (dependency chain)
# ISL depends on GMP and enables Graphite loop optimizations
pushd "$BUILDDIR"/gmp-%(gmpVersion)s
  ./configure --disable-static --prefix="${INSTALLROOT}" --enable-shared --disable-static --enable-cxx \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd

pushd "$BUILDDIR"/mpfr-%(mpfrVersion)s
  ./configure --disable-static --prefix="${INSTALLROOT}" --with-gmp="${INSTALLROOT}" \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd

pushd "$BUILDDIR"/mpc-%(mpcVersion)s
  ./configure --disable-static --prefix="${INSTALLROOT}" --with-gmp="${INSTALLROOT}" --with-mpfr="${INSTALLROOT}" \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd

pushd "$BUILDDIR"/isl-%(islVersion)s
  ./configure --disable-static --with-gmp-prefix="${INSTALLROOT}" --prefix="${INSTALLROOT}" \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd
