package: g4vg
version: 1.0.6
sources:
  - https://github.com/celeritas-project/g4vg/releases/download/v%(version)s/g4vg-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - geant4
  - vecgeom
  - clhep
  - expat
  - xerces-c
  - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

build_flags="-Wall -Wextra -pedantic -fPIC"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_CXX_STANDARD="${CXXSTD:-17}" \
  -DCMAKE_AR=$(which gcc-ar) \
  -DCMAKE_RANLIB=$(which gcc-ranlib) \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="${build_flags}" \
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="${build_flags}" \
  -DCMAKE_PREFIX_PATH="${GEANT4_ROOT};${VECGEOM_ROOT};${CLHEP_ROOT};${EXPAT_ROOT};${XERCES_C_ROOT};${ZLIB_ROOT}" \
  -DVecCore_DIR=${VECGEOM_ROOT}/lib64/cmake/VecCore \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DG4VG_BUILD_TESTS=OFF \
  -DG4VG_DEBUG=OFF

cmake --build "$BUILDDIR/build" ${JOBS:+--parallel $JOBS} --verbose
cmake --install "$BUILDDIR/build"

