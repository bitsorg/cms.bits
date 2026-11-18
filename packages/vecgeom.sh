package: vecgeom
version: "2.0.0"
variables:
 vecgeom_backend: Scalar
 tag: v%(version)s
sources:
 - git+https://gitlab.cern.ch/vecgeom/vecgeom.git?obj=master/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
patches:
 - vecgeom-fix-vector.patch
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - xerces-c
env:
  USE_VECGEOM: "1"
---
export BUILD_FLAGS="-fPIC $arch_build_flags $lto_build_flags $pgo_build_flags"

tar -xzf "$SOURCEDIR/$SOURCE0" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

vecgeom_version=$(echo "$PKG_VERSION" | sed -e 's|^v||;s|-.*||')

if [ "$(uname -m)" = "x86_64" ]; then
  if [[ "%(vecgeom_backend)s" == "Vc" ]]; then
    SEL_ARCH="$(echo "$selected_microarch" | sed 's|^-m||')"
    VECGEOM_VECTOR_INST="$(grep ' set(VECGEOM_ISAS ' "$BUILDDIR/CMakeLists.txt" | tr ' ' '\n' | grep -E "^${SEL_ARCH}$")"
  fi
fi

cmake_args=(
  -DVecGeom_GIT_DESCRIBE="${vecgeom_version};;"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DBUILD_TESTING=OFF
  -DVecGeom_VERSION="$vecgeom_version"
  -DCMAKE_CXX_STANDARD:STRING="${CXXSTD:-20}"
  -DCMAKE_AR="$(which gcc-ar)"
  -DCMAKE_RANLIB="$(which gcc-ranlib)"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG $BUILD_FLAGS"
  -DCMAKE_VERBOSE_MAKEFILE=TRUE
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="$BUILD_FLAGS"
  -DCMAKE_STATIC_LIBRARY_C_FLAGS="$BUILD_FLAGS"
  -DCMAKE_CXX_FLAGS="$BUILD_FLAGS"
  -DCMAKE_C_FLAGS="$BUILD_FLAGS"
  -DVECGEOM_NO_SPECIALIZATION=ON
  -DVECGEOM_BUILTIN_VECCORE=ON
  -DVECGEOM_BACKEND="%(vecgeom_backend)s"
  -DVECGEOM_GEANT4=OFF
  -DVECGEOM_ROOT=OFF
  -DCMAKE_PREFIX_PATH="$XERCES_C_ROOT"
)

if [[ "%(vecgeom_backend)s" == "Vc" ]]; then
  cmake_args+=(-DVECGEOM_VECTOR="${VECGEOM_VECTOR_INST}")
fi

cmake -S "$BUILDDIR" -B "$BUILDROOT/build" "${cmake_args[@]}"

cmake --build "$BUILDROOT/build" ${JOBS:+--parallel $JOBS} --verbose
cmake --install "$BUILDROOT/build"

sed -i -e "s|set(VecCore_DIR .*|set(VecCore_DIR \"${INSTALLROOT}/lib64/cmake/VecCore\")|" \
  "$INSTALLROOT/lib64/cmake/VecGeom/VecGeomConfig.cmake"
