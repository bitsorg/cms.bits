package: hepmc
version: 2.06.10
tag: 97620c648f31c9129b42c0b38fe4bd1ddfee9cab
source: https://github.com/cms-externals/hepmc
build_requires:
  - CMake
  - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

rm -rf ../build && mkdir ../build && cd ../build

cmake ../hepmc \
    -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
    -DCMAKE_CXX_FLAGS="-fPIC" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_CXX_STANDARD=$CXXSTD \
    -Dmomentum:STRING=GEV \
    -Dlength:STRING=MM 

make ${JOBS:+-j $JOBS}
make install

rm -rf $INSTALLROOT/lib/*.so
rm -rf $INSTALLROOT/lib/*.la