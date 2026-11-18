package: ROOT
version: 6.36.05
tag: 7947cea45c6fdee76ce1afc0f8a652df351b71bd
source: https://github.com/cms-sw/root
env:
 ROOTSYS: $ROOT_ROOT
prepend_path:
 PYTHON3PATH: $ROOT_ROOT/lib
build_requires:
- CMake
- ninja
requires:
- gcc
- GSL
- libjpeg-turbo
- libpng
- libtiff
- giflib
- pcre2
- Python
- FFTW3
- xz
- XRootD
- libxml2
- zlib
- davix
- TBB
- OpenBLAS
- py-numpy
- lz4
- FreeType
- zstd
- dcap
- cuda
---
case "$(uname)" in
Darwin)
  soext="dylib"
  ;;
*)
  soext="so"
  ;;
esac
PKGBUILDDIR="$BUILDDIR/$PKGNAME-$PKGVERSION"

mkdir -p "$PKGBUILDDIR"
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$PKGBUILDDIR"/
curl -L -k -s -o "$PKGBUILDDIR/graf2d/asimage/src/libAfterImage/config.sub" http://cmsrep.cern.ch/cmssw/download/config/config.sub
curl -L -k -s -o "$PKGBUILDDIR/graf2d/asimage/src/libAfterImage/config.guess" http://cmsrep.cern.ch/cmssw/download/config/config.guess
chmod +x $PKGBUILDDIR/graf2d/asimage/src/libAfterImage/config.{sub,guess}

export CFLAGS=-D__ROOFIT_NOBANNER
export CXXFLAGS=-D__ROOFIT_NOBANNER

if [ -z "${arch_build_flags:-}" ]; then
  case "$(uname -m)" in
  ppc64le) arch_build_flags="-mcpu=power8 -mtune=power8 --param=l1-cache-size=64 --param=l1-cache-line-size=128 --param=l2-cache-size=512" ;;
  aarch64) arch_build_flags="-march=armv8-a -mno-outline-atomics" ;;
  x86_64) arch_build_flags="" ;;
  *) arch_build_flags="" ;;
  esac
fi

if [ -n "${arch_build_flags:-}" ]; then
  export CFLAGS="${CFLAGS} ${arch_build_flags}"
  export CXXFLAGS="${CXXFLAGS} ${arch_build_flags}"
fi

# Set OS-specific flags
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Build CMake command
cmake_args=(
  "../$PKGNAME/$PKGNAME-$PKGVERSION"
  -G Ninja
  -DCMAKE_BUILD_TYPE="${cmake_build_type}"
  -DLLVM_BUILD_TYPE="Release"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_C_COMPILER=gcc
  -DCMAKE_CXX_COMPILER=g++
  -DCMAKE_Fortran_COMPILER=gfortran
  -DCMAKE_LINKER=ld
  -DCMAKE_VERBOSE_MAKEFILE=TRUE
  -Droot7=ON
  -Dfail-on-missing=ON
  -Dgnuinstall=OFF
  -Droofit=ON
  -Dvdt=OFF
  -Dhdfs=OFF
  -Dqt=OFF
  -Dtmva=ON
  -DPython3_EXECUTABLE="${PYTHON_ROOT}/bin/python3.12"
  -Dqtgsi=OFF
  -Dpgsql=OFF
  -Dsqlite=OFF
  -Dmysql=OFF
  -Doracle=OFF
  -Dldap=OFF
  -Dkrb5=OFF
  -Dftgl=OFF
  -Dfftw3=ON
  -Dtbb=ON
  -Dimt=ON
  -DFFTW_INCLUDE_DIR="${FFTW3_ROOT}/include"
  -DFFTW_LIBRARY="${FFTW3_ROOT}/lib/libfftw3.${soext}"
  -Dmathmore=ON
  -Dexplicitlink=ON
  -Dbuiltin_tbb=OFF
  -Dbuiltin_pcre=OFF
  -Dbuiltin_freetype=OFF
  -Dbuiltin_zlib=OFF
  -Dbuiltin_lzma=OFF
  -Dbuiltin_gsl=OFF
  -Dbuiltin_glew=ON
  -Dbuiltin_ftgl=ON
  -Dbuiltin_gl2ps=ON
  -Dbuiltin_xxhash=ON
  -Dbuiltin_nlohmannjson=ON
  -Darrow=OFF
  -DGSL_ROOT_DIR="${GSL_ROOT}"
  -DGSL_CBLAS_LIBRARY="${OPENBLAS_ROOT}/lib/libopenblas.${soext}"
  -DGSL_CBLAS_LIBRARY_DEBUG="${OPENBLAS_ROOT}/lib/libopenblas.${soext}"
  -DCMAKE_CXX_STANDARD=$CXXSTD
  -Dssl=ON
  -Dpyroot=ON
  -Dxrootd=ON
  -Dbuiltin_xrootd=OFF
  -DXROOTD_INCLUDE_DIR="${XROOTD_ROOT}/include/xrootd"
  -DXROOTD_ROOT_DIR="${XROOTD_ROOT}"
  -DCMAKE_C_FLAGS="-D__ROOFIT_NOBANNER"
  -DCMAKE_CXX_FLAGS="-D__ROOFIT_NOBANNER"
  -Dgviz=OFF
  -Dbonjour=OFF
  -Dodbc=OFF
  -Dpythia6=OFF
  -Dpythia8=OFF
  -Dfitsio=OFF
  -Dgfal=OFF
  -Dchirp=OFF
  -Dsrp=OFF
  -Ddavix=ON
  -Dglite=OFF
  -Dsapdb=OFF
  -Dalien=OFF
  -Dmonalisa=OFF
  -DJPEG_INCLUDE_DIR="${LIBJPEG_TURBO_ROOT}/include"
  -DJPEG_LIBRARY="${LIBJPEG_TURBO_ROOT}/lib64/libjpeg.${soext}"
  -DPNG_INCLUDE_DIRS="${LIBPNG_ROOT}/include"
  -DPNG_LIBRARY="${LIBPNG_ROOT}/lib/libpng.${soext}"
  -Dastiff=ON
  -DTIFF_INCLUDE_DIR="${LIBTIFF_ROOT}/include"
  -DTIFF_LIBRARY="${LIBTIFF_ROOT}/lib/libtiff.${soext}"
  -DLIBLZMA_INCLUDE_DIR="${XZ_ROOT}/include"
  -DLIBLZMA_LIBRARY="${XZ_ROOT}/lib/liblzma.${soext}"
  -DLZ4_INCLUDE_DIR="${LZ4_ROOT}/include"
  -DLZ4_LIBRARY="${LZ4_ROOT}/lib/liblz4.${soext}"
  -DZLIB_ROOT="${ZLIB_ROOT}"
  -DZLIB_INCLUDE_DIR="${ZLIB_ROOT}/include"
  -DZSTD_ROOT="${ZSTD_ROOT}"
  -DCMAKE_PREFIX_PATH="${LZ4_ROOT};${GSL_ROOT};${XZ_ROOT};${GIFLIB_ROOT};${FREETYPE_ROOT};${PYTHON3_ROOT};${LIBPNG_ROOT};${PCRE2_ROOT};${TBB_ROOT};${OPENBLAS_ROOT};${DAVIX_ROOT};${LIBXML2_ROOT};${ZSTD_ROOT}"
)

# Add OS-specific options
if [ "$OS" = "linux" ]; then
  cmake_args+=(
    -Drfio=OFF
    -Dcastor=OFF
    -Ddcache=ON
    -DDCAP_INCLUDE_DIR="${DCAP_ROOT}/include"
    -DDCAP_DIR="${DCAP_ROOT}"
  )
elif [ "$OS" = "darwin" ]; then
  cmake_args+=(
    -Dcocoa=OFF
    -Dx11=ON
    -Dcastor=OFF
    -Drfio=OFF
    -Ddcache=OFF
  )
fi

# Execute cmake
cmake "${cmake_args[@]}"

for d in ${EXPAT_ROOT} ${BZ2LIB_ROOT} ${DB6_ROOT} ${GDBM_ROOT} ${LIBFFI_ROOT} ${ZLIB_ROOT} ${SQLITE_ROOT} ${XZ_ROOT} ${LIBUUID_ROOT}; do
  if [[ -n "$d" ]]; then
    if [[ -e "$d/lib" ]]; then
      LDFLAGS="$LDFLAGS -L$d/lib"
    fi
    if [[ -e "$d/lib64" ]]; then
      LDFLAGS="$LDFLAGS -L$d/lib64"
    fi
    if [[ -e "$d/include" ]]; then
      CPPFLAGS="$CPPFLAGS -I$d/include"
    fi
  fi
done

for d in \
  ${GSL_ROOT} \
  ${LIBJPEG_TURBO_ROOT} \
  ${LIBPNG_ROOT} \
  ${LIBTIFF_ROOT} \
  ${GIFLIB_ROOT} \
  ${PCRE2_ROOT} \
  ${PYTHON_ROOT} \
  ${FFTW3_ROOT} \
  ${XZ_ROOT} \
  ${XROOTD_ROOT} \
  ${LIBXML2_ROOT} \
  ${ZLIB_ROOT} \
  ${DAVIX_ROOT} \
  ${TBB_ROOT} \
  ${OPENBLAS_ROOT} \
  ${PY_NUMPY_ROOT} \
  ${LZ4_ROOT} \
  ${FREETYPE_ROOT} \
  ${ZSTD_ROOT} \
  ${DCAP_ROOT}; do

  if [ -d "${d}/include" ]; then
    ROOT_INCLUDE_PATH="${d}/include${ROOT_INCLUDE_PATH:+:${ROOT_INCLUDE_PATH}}"
  fi
done

export ROOT_INCLUDE_PATH
export ROOTSYS=$INSTALLROOT
ninja -v ${JOBS:+-j$JOBS} install

find $INSTALLROOT -type f -name '*.py' | xargs chmod -x
grep -rlI '#!.*python' $INSTALLROOT | xargs chmod +x
for p in $(grep -rlI -m1 '^#\!.*python' $INSTALLROOT/bin $INSTALLROOT/etc); do
  lnum=$(grep -n -m1 '^#\!.*python' $p | sed 's|:.*||')
  sed -i -e "${lnum}c#!/usr/bin/env python3" $p
done

