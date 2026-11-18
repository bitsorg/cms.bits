package: flatbuffers
version: "24.3.25"
sources:
 - https://github.com/google/flatbuffers/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir ../build
cd ../build

cmake $BUILDDIR -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DFLATBUFFERS_BUILD_CPP17=ON \
  -DFLATBUFFERS_BUILD_SHAREDLIB=ON \
  -DFLATBUFFERS_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

make -v ${JOBS:+-j $JOBS} 
make ${JOBS:+-j $JOBS} install
