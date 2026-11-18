package: rapidjson
version: "1.1.0"
sources:
 -  https://github.com/Tencent/%(package)s/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build ; mkdir ../build ; cd ../build

cmake $BUILDDIR\
	-DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
	-DCMAKE_CXX_STANDARD=$CXXSTD \
	-DRAPIDJSON_BUILD_TESTS=OFF \
	-DRAPIDJSON_BUILD_DOC=OFF \
	-DRAPIDJSON_BUILD_EXAMPLES=OFF

make ${JOBS:+-j$JOBS} install
