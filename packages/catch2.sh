package: catch2
version: 3.13.0
sources:
 - https://github.com/catchorg/Catch2/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
make_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCATCH_INSTALL_HELPERS=ON
    -DCATCH_INSTALL_EXTRAS=ON
)
cmake "${make_args[@]}"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" install
