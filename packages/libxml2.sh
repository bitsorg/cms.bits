package: libxml2
version: "%(tag_basename)s"
tag: v2.9.10
build_requires:
  - autotools
requires:
 - zlib
 - xz
 - gcc
source: https://gitlab.gnome.org/GNOME/libxml2
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

./autogen.sh

./configure --disable-static --prefix=$INSTALLROOT \
            --with-zlib="${ZLIB_ROOT}" \
            --with-lzma="${XZ_ROOT}" --without-python

make ${JOBS:+-j$JOBS}
make install
rm -rf ${INSTALLROOT}/lib/pkgconfig
rm -rf ${INSTALLROOT}/lib/*.{l,}a   
