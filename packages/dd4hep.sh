package: dd4hep
version: v01-31-0x
tag: 74155cec308e842fba19cc21e01165a4553bba47
source: https://github.com/AIDASoft/DD4hep.git
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - clhep
 - expat
 - xerces-c
 - vecgeom
 - zlib
 - ROOT
 - boost
 - geant4
 - gcc
 - json
---
export build_flags="-fPIC $arch_build_flags $lto_build_flags $pgo_build_flags"

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

unset $BOOST_ROOT

cmake_fixed_args=(
    "-DCMAKE_INSTALL_PREFIX=$INSTALLROOT"
    "-DCMAKE_CXX_FLAGS=${build_flags} "
    "-DCMAKE_STATIC_LIBRARY_CXX_FLAGS=${build_flags} "
    "-DCMAKE_STATIC_LIBRARY_C_FLAGS=${build_flags} "
    "-DBoost_NO_BOOST_CMAKE=ON"
    "-DDD4HEP_USE_XERCESC=ON"
    "-DDD4HEP_USE_PYROOT=ON"
    "-DCMAKE_AR=$(which gcc-ar)"
    "-DCMAKE_RANLIB=$(which gcc-ranlib)"
    "-DCMAKE_CXX_STANDARD=$CXXSTD"
    "-DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE"
    "-DDD4HEP_USE_GEANT4_UNITS=ON"
    "-DXERCESC_ROOT_DIR=${XERCES_C_ROOT}"
    "-DCMAKE_PREFIX_PATH=$CLHEP_ROOT;$EXPAT_ROOT;$XERCES_C_ROOT;$VEGEOM_ROOT;$ZLIB_ROOT;$ROOT_ROOT;$BOOST_ROOT;$GEANT4_ROOT;$GCC_ROOT;$JSON_ROOT"
)

cmake "${cmake_fixed_args[@]}" -DBUILD_SHARED_LIBS=ON -DDD4HEP_USE_GEANT4=OFF

make ${JOBS:+-j "$JOBS"} VERBOSE=1
make install VERBOSE=1

rm -fr $BUILDDIR/build-g4
mkdir $BUILDDIR/build-g4

cmake "${cmake_fixed_args[@]}" -DBUILD_SHARED_LIBS=OFF -DDD4HEP_USE_GEANT4=ON
make ${JOBS:+-j "$JOBS"} VERBOSE=1

pushd DDG4
 for lib in $(ls ../lib/libDDG4*.a | sed 's|.a$||'); do
   mv "${lib}.a" "$INSTALLROOT/lib/${lib}-static.a"
 done
popd

mv $BUILDDIR/DDG4/include/DDG4 $INSTALLROOT/include
