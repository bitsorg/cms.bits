package: c-ares
version: "1_15_0"
sources:
 - https://github.com/c-ares/c-ares/archive/cares-%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE

make VERBOSE=1 ${JOBS:+-j$JOBS}
make install
