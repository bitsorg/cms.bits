package: sqlite-bootstrap
version: "3.48.0"
sources:
 - https://www.sqlite.org/2025/sqlite-autoconf-3480000.tar.gz
requires:
 - gcc
---
CMS_BITS_MARCH=$(gcc -dumpmachine)
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" --prefix=$INSTALLROOT \
            --disable-static --disable-dependency-tracking

make install
rm -rf $INSTALLROOT/lib/pkgconfig
