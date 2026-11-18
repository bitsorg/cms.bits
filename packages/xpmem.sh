package: xpmem
version: "v2.6.3"
tag: 61c39efdea943ac863037d7e35b236145904e64d
sources: 
 - https://github.com/hpc/xpmem/archive/%(tag_basename)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

sh autogen.sh 
ls -l
./configure \
  --prefix=$INSTALLROOT \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking \
  --disable-kernel-module \
  --with-pic \
  --with-gnu-ld

make ${JOBS:+-j$JOBS}
make install

rm -rf $INSTALLROOT/etc
rm -f $INSTALLROOT/lib/lib*.la
rm -rf $INSTALLROOT/lib/pkgconfig
