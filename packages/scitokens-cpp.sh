package: scitokens-cpp
version: 0.7.0
sources: 
 - https://github.com/scitokens/%(package)s/archive/refs/tags/v%(version)s.tar.gz
patches:
 - scitokens-cpp.patch
build_requires:
 - CMake
 - gmake
requires:
 - libuuid
 - curl
 - sqlite
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p0 < "$SOURCEDIR/$PATCH0"

sed -i -e 's/ -Werror//' CMakeLists.txt

rm -rf ../build && mkdir ../build && cd ../build

cmake $BUILDDIR \
	-DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
	-DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
        -DCMAKE_PREFIX_PATH="${CURL_ROOT};${LIBUUID_ROOT};${SQLITE_ROOT}"

make ${JOBS:+-j $JOBS}
make install
