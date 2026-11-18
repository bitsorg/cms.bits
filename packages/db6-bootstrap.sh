package: db6-bootstrap
version: "6.0.30"
sources: 
-  https://github.com/yasuhirokimura/db6/archive/refs/tags/%(version)s.tar.gz
---
CMS_BITS_MARCH=$(gcc -dumpmachine)
tar xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./dist/configure \
    --prefix="$INSTALLROOT" \
    --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
    --disable-java \
    --disable-tcl \
    --disable-static

make ${JOBS:+-j $JOBS}
make install    