package: geant4
version: "11.4.1"
tag: 425b0689d08917d8908d69fb7873e79db001d2ba
variables:
 github_user: cms-externals
 branch: cms/v%(version)s
sources:
-  git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag_basename)s&export=%(package)s.%(version)s&output=/%(package)s.%(version)s-%(tag_basename)s.tgz
build_requires:
- CMake 
- gmake 
requires:
- gcc
- vecgeom
- clhep
- expat
- geant4-data
- xerces-c
- zlib
---
#eval "$setup_pgo"
#setup_pgo_flags "$BUILDDIR" "$PKGNAME/$PKGHASH"
export BUILD_FLAGS="-fPIC $arch_build_flags $lto_build_flags $pgo_build_flags"

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

soext="so"
if [[ "$(uname -s)" == "Darwin" ]]; then
    soext="dylib"
fi

rm -rf $BUILDROOT/build && mkdir $BUILDROOT/build && cd $BUILDROOT/build

cmake_args=(
  -DCMAKE_CXX_COMPILER="g++"
  -DCMAKE_CXX_FLAGS="${BUILD_FLAGS}"
  -DCMAKE_AR="$GCC_ROOT/bin/gcc-ar"
  -DCMAKE_RANLIB="$GCC_ROOT/bin/gcc-ranlib"
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DCMAKE_CXX_STANDARD:STRING="$CXXSTD"
  -DCMAKE_BUILD_TYPE="Release"
  -DGEANT4_USE_GDML=ON
  -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"
  -DGEANT4_ENABLE_TESTING=OFF
  -DGEANT4_BUILD_VERBOSE_CODE=OFF
  -DGEANT4_BUILD_BUILTIN_BACKTRACE=OFF
  -DBUILD_SHARED_LIBS=ON
  -DBUILD_STATIC_LIBS=ON
  -DGEANT4_INSTALL_EXAMPLES=OFF
  -DGEANT4_USE_SYSTEM_CLHEP=ON
  -DGEANT4_USE_SYSTEM_EXPAT=ON
  -DGEANT4_USE_SYSTEM_ZLIB=ON
  -DGEANT4_BUILD_MULTITHREADED=ON
  -DCMAKE_PREFIX_PATH="${GCC_ROOT};${CLHEP_ROOT};${EXPAT_ROOT};${GEANT4_DATA_ROOT};${XERCES_C_ROOT};${ZLIB_ROOT};${VECGEOM_ROOT}"
)

if [[ -n $VECGEOM_ROOT ]]; then
  cmake_args+=(
    -DGEANT4_USE_USOLIDS="all"
    -DVecGeom_DIR="${VECGEOM_ROOT}/lib64/cmake/VecGeom"
    -DVecCore_DIR="${VECGEOM_ROOT}/lib64/cmake/VecCore"
  )
fi

cmake "${cmake_args[@]}" $BUILDDIR

make ${JOBS:+-j$JOBS} VERBOSE=1
make install

mkdir -p $INSTALLROOT/lib64/archive
cd $INSTALLROOT/lib64/archive
find $INSTALLROOT/lib64 -name "*.a" -exec gcc-ar x {} \;
gcc-ar rcs libgeant4-static.a *.o
find . -name "*.o" -delete

if [[ -n "$pgo_build_flags" ]]; then
  sed -i -r -e 's| +(-fprofile-[^ ]+ )+||' "$INSTALLROOT/lib64/cmake/Geant4/Geant4Config.cmake" "$INSTALLROOT/bin/geant4-config"
fi
