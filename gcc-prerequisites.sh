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
---
# Unpack all source archives
for f in "$SOURCEDIR"/*; do
    case "$f" in
        *.tar.gz) tar -xzf "$f" -C "$BUILDDIR";;
        *.tar.bz2) tar -xjf "$f" -C "$BUILDDIR";;
    esac
done

# Apply patches
pushd "$BUILDDIR/flex-%(flexVersion)s"
  patch -p1 < $SOURCEDIR/$PATCH0
  patch -p1 < $SOURCEDIR/$PATCH1
popd

# Set environment variables
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

CC="$CC -fPIC"
CXX="$CXX -fPIC"

mkdir -p ${INSTALLROOT}/tmp/sw
export PATH=${INSTALLROOT}/tmp/sw/bin:$PATH

# Build zlib
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

if [ "$OS" = "Linux" ]; then
  # Configure flags
  CONF_BINUTILS_OPTS="--enable-ld=default --enable-lto --enable-plugins --enable-threads"
  CONF_GCC_WITH_LTO="--enable-ld=default --enable-lto"
  CONF_BINUTILS_OPTS+=" --enable-gold=yes"
  CONF_GCC_WITH_LTO+=" --enable-gold=yes"

  # Build zstd
  make -C zstd-%(zstdVersion)s/lib ${JOBS:+-j "$JOBS"} \
       install-static install-includes \
       prefix="${INSTALLROOT}/tmp/sw" \
       CPPFLAGS="-fPIC" CFLAGS="-fPIC"

  # Build m4
  pushd "$BUILDDIR"/m4-%(m4Version)s
    ./configure --prefix="${INSTALLROOT}/tmp/sw" \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
                CC="${CC}"
    make ${JOBS:+-j "$JOBS"} && echo "   make m4 OK"
    make install && echo "   install m4 OK"
  popd

  # Build bison
  pushd "$BUILDDIR"/bison-%(bisonVersion)s
    ./configure --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
                --prefix="${INSTALLROOT}/tmp/sw" \
                CC="${CC}"
    make ${JOBS:+-j "$JOBS"} && echo "   make bison OK"
    make install && echo "   install bison OK"
  popd

  # Build flex
  pushd "$BUILDDIR"/flex-%(flexVersion)s
    ./configure --disable-nls --prefix="${INSTALLROOT}/tmp/sw" \
                --enable-static --disable-shared \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
                CC="${CC}" CXX="${CXX}"
    make ${JOBS:+-j "$JOBS"} && echo "   make flex OK"
    make install && echo "   install flex OK"
  popd

  # Build elfutils
  pushd "$BUILDDIR"/elfutils-%(elfutilsVersion)s
    ./configure --disable-static --with-zlib --without-bzlib --without-lzma \
                --disable-libdebuginfod --enable-libdebuginfod=dummy --disable-debuginfod \
                --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" --program-prefix='eu-' \
                --disable-silent-rules --prefix="${INSTALLROOT}" \
                CC="gcc" \
                CPPFLAGS="-I${INSTALLROOT}/tmp/sw/include" \
                LDFLAGS="-L${INSTALLROOT}/tmp/sw/lib"
    make ${JOBS:+-j "$JOBS"} && echo "   make elfutils OK"
    make install && echo "   install elfutils OK"
  popd

  if [ "$ARCH" = "ppc64le" ]; then
    echo "DETected ppc64le: enabling SPU and powerpc targets"
    CONF_BINUTILS_OPTS+=" --enable-targets=spu --enable-targets=powerpc-linux"
  fi

  # Build binutils
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

    find . -name Makefile \
      -exec perl -p -i -e 's|LN = ln|LN = cp -p|;s|ln ([^-])|cp -p $1|g' {} \;
    make install && echo "   install binutils OK"
  popd
fi
echo Done

# Build gmp
pushd "$BUILDDIR"/gmp-%(gmpVersion)s
  ./configure --disable-static --prefix="${INSTALLROOT}" --enable-shared --disable-static --enable-cxx \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd

# Build mpfr
pushd "$BUILDDIR"/mpfr-%(mpfrVersion)s
  ./configure --disable-static --prefix="${INSTALLROOT}" --with-gmp="${INSTALLROOT}" \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd

# Build mpc
pushd "$BUILDDIR"/mpc-%(mpcVersion)s
  ./configure --disable-static --prefix="${INSTALLROOT}" --with-gmp="${INSTALLROOT}" --with-mpfr="${INSTALLROOT}" \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd

# Build isl
pushd "$BUILDDIR"/isl-%(islVersion)s
  ./configure --disable-static --with-gmp-prefix="${INSTALLROOT}" --prefix="${INSTALLROOT}" \
              --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
              CC="${CC}" CXX="${CXX}" CPP="${CPP}" CXXCPP="${CXXCPP}"
  make ${JOBS:+-j $JOBS}
  make install
popd
