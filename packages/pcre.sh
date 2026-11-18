package: pcre
version: "8.43"
requires:
 - bz2lib
 - zlib
 - gcc
sources:
- https://sourceforge.net/projects/pcre/files/pcre/%(version)s/pcre-%(version)s.tar.gz/download
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure \
  --enable-unicode-properties \
  --enable-pcregrep-libz \
  --enable-pcregrep-libbz2 \
  --prefix=$INSTALLROOT \
  CPPFLAGS="-I${BZ2LIB_ROOT}/include -I${ZLIB_ROOT}/include" \
  LDFLAGS="-L${BZ2LIB_ROOT}/lib -L${ZLIB_ROOT}/lib"
make

make install

rm -rf $INSTALLROOT/lib/pkgconfig

rm -f $INSTALLROOT/lib/*.{l,}a
