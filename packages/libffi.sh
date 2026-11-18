package: libffi
version: "%(tag_basename)s"
tag: v3.4.2
requires:
 - gcc
source: https://github.com/libffi/libffi
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' \
      "$SOURCEDIR"/ "$BUILDDIR"/
autoreconf -fiv
./configure \
  --prefix="$INSTALLROOT" \
  --enable-portable-binary \
  --disable-dependency-tracking \
  --disable-static \
  --disable-docs
make $MAKEPROCESSES
make $MAKEPROCESSES install

rm -rf "${INSTALLROOT}/lib"
rm -rf ${INSTALLROOT}/lib64/*.la