package: gnuplot
version: 5.2.8
sources:
 - http://downloads.sourceforge.net/project/gnuplot/gnuplot/%(version)s/gnuplot-%(version)s.tar.gz
requires:
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CFLAGS=-I${ZLIB_ROOT}/include \
LDFLAGS=-L${ZLIB_ROOT}/lib \
./configure \
  --prefix $INSTALLROOT \
  --disable-wxt \
  --without-cairo \
  --without-tutorial \
  --without-readline \
  --without-gd \
  --without-x \
  --without-lua

make ${JOBS:+-j$JOBS}
make install
