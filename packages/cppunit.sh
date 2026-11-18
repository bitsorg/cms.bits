package: cppunit
version: 1.15.x
variables:
 tag: 2b72f2b3ef94452ae649fc6a44bec049f1acb173
 branch: master
 github_user: git/libreoffice
sources:
 - git+https://anongit.freedesktop.org/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - gmake
 - autotools
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
./autogen.sh
./configure --prefix=$INSTALLROOT --disable-static
make ${JOBS:+-j$JOBS}
make install
rm -rf $INSTALLROOT/lib/pkgconfig
rm -rf $INSTALLROOT/lib/*.{l,}a
