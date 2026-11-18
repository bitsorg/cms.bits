package: gmake
version: "4.3"
sources:
 - https://mirror.ibcp.fr/pub/gnu/make/make-%(version)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR"/*.tar.gz -C "$BUILDDIR"

cd $BUILDDIR/make-*
./configure --prefix=$INSTALLROOT
make ${JOBS:+-j $JOBS}
make install
rm -rf $INSTALLROOT/{man,info}
cd $INSTALLROOT/bin
ln -sf make gmake
