package: g4hepem
version: "20251114"
variables:
  tag:         "%(version)s"
  branch:      master
  github_user: mnovak42
sources:
  - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s.%(version)s&output=/%(package)s.%(version)s-%(tag)s.tgz
build_requires:
  - CMake
  - gmake
requires:
  - geant4
  - clhep
  - expat
  - xerces-c
  - zlib
  - vecgeom
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q 'BUILD_SHARED_LIBS ON' "$BUILDDIR/CMakeLists.txt" && \
    sed -i -e 's|BUILD_SHARED_LIBS ON|BUILD_SHARED_LIBS OFF|' "$BUILDDIR/CMakeLists.txt"
grep -q 'BUILD_STATIC_LIBS OFF' "$BUILDDIR/CMakeLists.txt" && \
    sed -i -e 's|BUILD_STATIC_LIBS OFF|BUILD_STATIC_LIBS ON|' "$BUILDDIR/CMakeLists.txt"

CMS_FLAGS="-fPIC ${arch_build_flags} ${selected_microarch}"

use_vecgeom=OFF
[ -n "$VECGEOM_REVISION" ] && use_vecgeom=ON

cmake -S "$BUILDDIR" -B "$BUILDROOT/build" \
  -DCMAKE_CXX_COMPILER="g++" \
  -DCMAKE_CXX_FLAGS="$CMS_FLAGS" \
  -DCMAKE_C_FLAGS="$CMS_FLAGS" \
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="$CMS_FLAGS" \
  -DCMAKE_STATIC_LIBRARY_C_FLAGS="$CMS_FLAGS" \
  -DCMAKE_AR="$(which gcc-ar)" \
  -DCMAKE_RANLIB="$(which gcc-ranlib)" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_STATIC_LIBS=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_PREFIX_PATH="${GEANT4_ROOT};${CLHEP_ROOT};${EXPAT_ROOT};${XERCES_C_ROOT};${ZLIB_ROOT}${use_vecgeom:+;${VECGEOM_ROOT}}"

cmake --build "$BUILDROOT/build" ${JOBS:+--parallel $JOBS} -- VERBOSE=1
cmake --install "$BUILDROOT/build"

mkdir -p "$BUILDROOT/tmp_archive"
pushd "$BUILDROOT/tmp_archive"
  find "$INSTALLROOT/lib64" -name "*.a" -exec $(which gcc-ar) x {} \;
  $(which gcc-ar) rcs "$INSTALLROOT/lib64/libg4hepem-static.a" *.o
popd
rm -rf "$BUILDROOT/tmp_archive"

