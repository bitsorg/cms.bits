package: collier
version: 1.2.8
sources:
 - https://cmsrep.cern.ch/cmssw/download/collier/%(version)s/%(package)s-%(version)s.tar.gz
build_requires:
 - gmake
 - CMake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

sed -i 's;add_definitions(-Dcollierdd -DSING);add_definitions(-Dcollierdd -DSING -fPIC);g' ./CMakeLists.txt

rm -rf ../build && mkdir ../build && cd ../build

cmake $BUILDDIR \
  -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -Dstatic=ON \
  -DCMAKE_Fortran_FLAGS=-fPIC

make -j1
mkdir -p $INSTALLROOT/lib $INSTALLROOT/include
cp $BUILDDIR/libcollier.a $INSTALLROOT/lib
cp $BUILDDIR/modules/*.mod $INSTALLROOT/include/
