package: gbl
version: V03-01-01
variables:
 tag: 59c2d99ea96bc739321fd251096504c91467be24
sources:
 - git+https://gitlab.desy.de/claus.kleinwort/general-broken-lines.git?obj=main/%(tag)s&export=%(version)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - CMake
requires:
 - eigen
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q 'CMAKE_CXX_STANDARD  *11' cpp/CMakeLists.txt
sed -i -e "s|CMAKE_CXX_STANDARD  *11|CMAKE_CXX_STANDARD $CXXSTD|" cpp/CMakeLists.txt

rm -rf ../build && mkdir -p ../build && cd ../build

cmake $BUILDDIR/cpp \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DEIGEN3_INCLUDE_DIR=${EIGEN_ROOT}/include/eigen3 \
  -DSUPPORT_ROOT=False \
  -DCMAKE_CXX_FLAGS="$CMS_EIGEN_CXX_FLAGS ${selected_microarch}"

make ${JOBS:+-j$JOBS}
make install
