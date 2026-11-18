package: sigcpp
version: "3.2.0"
sources:
 - https://github.com/libsigcplusplus/libsigcplusplus/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build && mkdir ../build && cd ../build

cmake $BUILDDIR \
	-DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
        -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

make ${JOBS:+-j$JOBS}
make install
rm -rf $INSTALLROOT/pkgconfig
cp $INSTALLROOT/lib/sigc++-3.0/include/sigc++config.h $INSTALLROOT/include/sigc++-3.0/
