package: ROOT
version: "v1"
tag: cms/v6-36-00-patches/1715228c2c
source: https://github.com/cms-sw/root
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
cat << 'EOF' > CMakePresets.json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "ROOT-Build",
      "displayName": "ROOT Build Configuration",
      "description": "Build configuration for ROOT for CMS",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "${env:LLVM_BUILD_TYPE}",
        "LLVM_BUILD_TYPE": "${env:LLVM_BUILD_TYPE}",
        "CMAKE_CXX_STANDARD": "${env:CXXSTD}",
        "CMAKE_VERBOSE_MAKEFILE": "TRUE",
        "CMAKE_INSTALL_PREFIX": "${env:INSTALLROOT}",
        "CMAKE_C_COMPILER": "gcc",
        "CMAKE_CXX_COMPILER": "g++",
        "CMAKE_Fortran_COMPILER": "gfortran",
        "CMAKE_LINKER": "ld",
        "CMAKE_C_FLAGS": "-D__ROOFIT_NOBANNER",
        "CMAKE_CXX_FLAGS": "-D__ROOFIT_NOBANNER",
        "Python3_EXECUTABLE": "${env:PYTHON_ROOT}/bin/python3.9",

        "TIFF_LIBRARY": "${env:LIBTIFF_ROOT}/lib/libtiff.${env:soext}",
        "LIBLZMA_INCLUDE_DIR": "${env:XZ_ROOT}/include",
        "LIBLZMA_LIBRARY": "${env:XZ_ROOT}/lib/liblzma.${env:soext}",
        "LZ4_INCLUDE_DIR": "${env:LZ4_ROOT}/include",
        "LZ4_LIBRARY": "${env:LZ4_ROOT}/lib/liblz4.${env:soext}",
        "ZLIB_ROOT": "${env:ZLIB_ROOT}",
        "ZLIB_INCLUDE_DIR": "${env:ZLIB_ROOT}/include",
        "ZSTD_ROOT": "${env:ZSTD_ROOT}",
        "GSL_ROOT_DIR": "${env:GSL_ROOT}",
        "GSL_CBLAS_LIBRARY": "${env:OPENBLAS_ROOT}/lib/libopenblas.${env:soext}",
        "GSL_CBLAS_LIBRARY_DEBUG": "${env:OPENBLAS_ROOT}/lib/libopenblas.${env:soext}",
        "XROOTD_INCLUDE_DIR": "${env:XROOTD_ROOT}/include/xrootd",
        "XROOTD_ROOT_DIR": "${env:XROOTD_ROOT}",

        "FFTW_INCLUDE_DIR": "${env:FFTW3_ROOT}/include",
        "FFTW_LIBRARY": "${env:FFTW3_ROOT}/lib/libfftw3.${env:soext}",
	    "DCMAKE_PREFIX_PATH": "${env:DCMAKE_PREFIX_PATH};${env:LZ4_ROOT};${env:GSL_ROOT};${env:XZ_ROOT};${env:GIFLIB_ROOT};${env:FREETYPE_ROOT};${env:PYTHON3_ROOT};${env:LIBPNG_ROOT};${env:PCRE2_ROOT};${env:TBB_ROOT};${env:OPENBLAS_ROOT};${env:DAVIX_ROOT};${env:LIBXML2_ROOT};${env:ZSTD_ROOT}"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "ROOT-Build",
      "configurePreset": "ROOT-Build"
    }
  ]
}
EOF

declare -A cmake_bools=(
  # ROOT features
  [root7]=ON
  [roofit]=ON
  [tmva]=ON
  [imt]=ON
  [mathmore]=ON
  [pyroot]=ON
  
  # Optional features
  [ssl]=ON
  [fail-on-missing]=ON
  [explicitlink]=ON
  [xrootd]=ON
  
  # Builtin flags
  [builtin_tbb]=OFF
  [builtin_pcre]=OFF
  [builtin_freetype]=OFF
  [builtin_zlib]=OFF
  [builtin_lzma]=OFF
  [builtin_gsl]=OFF
  [builtin_xrootd]=OFF
  [builtin_glew]=ON
  [builtin_ftgl]=ON
  [builtin_gl2ps]=ON
  [builtin_xxhash]=ON
  [builtin_nlohmannjson]=ON
  
  # Disabled features
  [gnuinstall]=OFF
  [vdt]=OFF
  [qt]=OFF
  [qtgsi]=OFF
  [pgsql]=OFF
  [sqlite]=OFF
  [mysql]=OFF
  [oracle]=OFF
  [ldap]=OFF
  [krb5]=OFF
  [ftgl]=OFF
  [arrow]=OFF
  [gviz]=OFF
  [bonjour]=OFF
  [odbc]=OFF
  [pythia6]=OFF
  [pythia8]=OFF
  [fitsio]=OFF
  [gfal]=OFF
  [chirp]=OFF
  [srp]=OFF
  [glite]=OFF
  [sapdb]=OFF
  [alien]=OFF
  [monalisa]=OFF
)

# Build cmake arguments for boolean flags
cmake_bool_args=()
for key in "${!cmake_bools[@]}"; do
  cmake_bool_args+=("-D${key}=${cmake_bools[$key]}")
done

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
if cmake --preset=root-build "${cmake_args[@]}"; then
    echo "✅ CMake preset 'root-build' completed successfully."
else
    echo "❌ CMake preset 'root-build' failed."
fi
exit 1
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

