package: xtl
version: "0.7.4"
build_requires:
- CMake
requires:
- gcc
sources:
- https://github.com/QuantStack/xtl/archive/%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

make ${JOBS:+-j$JOBS} prefix="$INSTALLROOT"
make install
