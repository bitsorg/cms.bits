package: xtensor
version: "0.24.1"
build_requires:
- CMake
requires:
- xtl
- gcc
sources:
- https://github.com/QuantStack/xtensor/archive/%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf build; mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DCMAKE_PREFIX_PATH=${XTL_ROOT} ..
make ${JOBS:+-j$JOBS}
make install
