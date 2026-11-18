package: cpu_features
version: 0.9.0
sources:
  - https://github.com/google/cpu_features/archive/refs/tags/v%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DBUILD_TESTING=OFF
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
)
cmake "${cmake_args[@]}"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" install
