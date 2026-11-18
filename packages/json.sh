package: json
version: "3.11.3"
sources:
 - https://github.com/nlohmann/json/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build && mkdir -p ../build && cd ../build

cmake $BUILDDIR \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DJSON_BuildTests=OFF \
  -DJSON_MultipleHeaders=OFF

make ${JOBS:+-j$JOBS} VERBOSE=1
make install
