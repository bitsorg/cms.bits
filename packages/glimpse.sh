package: glimpse
version: 4.18.7-6
variables: 
  tag: 5426ca983218befa4aeadf21cad2305d90c84adb
sources:
 - git+https://github.com/cms-externals/glimpse.git?obj=master/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - autotools
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CFLAGS="-Wno-error=return-mismatch -Wno-error=implicit-int -Wno-error=implicit-function-declaration" ./configure --prefix=$INSTALLROOT

perl -p -i -e "s|dynfilters||g" Makefile

make -j1
make install
