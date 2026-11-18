package: db6
version: "%(tag_basename)s"
tag: 6.2.32
requires:
 - gcc
sources: 
- http://cmsrep.cern.ch/cmssw/download/db-%(tag_basename)s.tar.gz
---
CMS_BITS_MARCH=$(gcc -dumpmachine)

tar -xzf "$SOURCEDIR"/*.tar.gz -C "$BUILDDIR"

cd $BUILDDIR/db-*

./dist/configure \
    --prefix="$INSTALLROOT" \
    --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
    --disable-java \
    --disable-tcl \
    --disable-static

make ${JOBS:+-j $JOBS}
make install
