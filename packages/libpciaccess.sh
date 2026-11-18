package: libpciaccess
version: "libpciaccess_0.16"
sources: 
- http://deb.debian.org/debian/pool/main/libp/libpciaccess/%(version)s.orig.tar.gz
build_requires:
 - autotools
requires:
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure \
  --prefix ${INSTALLROOT} \
  --disable-dependency-tracking \
  --enable-shared \
  --disable-static \
  --with-pic \
  --with-gnu-ld \
  --with-zlib \
  CPPFLAGS="-I$ZLIB_ROOT/include" \
  LDFLAGS="-L$ZLIB_ROOT/lib"

make ${JOBS:+-j$JOBS}
make install
