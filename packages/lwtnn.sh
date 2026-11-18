package: lwtnn
version: 2.14.1
sources:
  - https://github.com/lwtnn/lwtnn/archive/v%(version)s.tar.gz
patches:
  - lwtnn-assert-fix.patch
build_requires:
  - ninja
  - CMake
requires:
  - gcc
  - eigen
  - boost
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

cmake -S "$BUILDDIR" -B "$BUILDROOT/build" \
  -G Ninja \
  -DCMAKE_CXX_COMPILER="g++" \
  -DCMAKE_CXX_FLAGS="-fPIC -DBOOST_DISABLE_ASSERTS $CMS_EIGEN_CXX_FLAGS ${selected_microarch}" \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILTIN_BOOST=OFF \
  -DBUILTIN_EIGEN=OFF \
  -DCMAKE_PREFIX_PATH="${EIGEN_ROOT};${BOOST_ROOT}" \
  -DCMAKE_CXX_STANDARD="${CXXSTD:-20}"

ninja -v ${JOBS:+-j$JOBS} -C "$BUILDROOT/build"
ninja -v ${JOBS:+-j$JOBS} -C "$BUILDROOT/build" install

