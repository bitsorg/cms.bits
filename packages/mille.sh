package: mille
version: V01-00-00
sources:
  - https://gitlab.desy.de/millepede/Mille/-/archive/%(version)s/mille-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - zlib
  - ROOT
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_PREFIX_PATH="${ZLIB_ROOT};${ROOT_ROOT}"
    -DCMAKE_CXX_STANDARD="${CXXSTD:-20}"
)
cmake "${cmake_args[@]}"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" VERBOSE=1
make -C "$BUILDDIR/build" install
