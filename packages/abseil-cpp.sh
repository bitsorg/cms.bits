package: abseil-cpp
version: "%(tag_basename)s"
tag: "20220623.1"
source: https://github.com/abseil/abseil-cpp
requires:
- gcc
- CMake
- gmake
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

cmake -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_CXX_STANDARD=$CXXSTD \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_TESTING=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE

make ${JOBS:+-j $JOBS}
make install