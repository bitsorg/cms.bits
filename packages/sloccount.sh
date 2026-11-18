package: sloccount
version: "2.26"
sources:
 -  http://www.dwheeler.com/sloccount/sloccount-%(version)s.tar.gz
build_requires:
 - flex
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
cp makefile makefile.dist
perl -p -i -e "s|^PREFIX=/usr/local|PREFIX=$INSTALLROOT|g" makefile
make
mkdir -p $INSTALLROOT/bin
make install
