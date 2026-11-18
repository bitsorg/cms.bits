package: bison
version: "3.8.2"
sources:
 - https://mirror.ibcp.fr/pub/gnu/bison/bison-%(version)s.tar.gz
build_requires:
 - autotools
requires:
 - autotools
 - gcc
env:
  BISON_PKGDATA_DIR: $BISON_ROOT/share/bison
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMS_BITS_MARCH=$(gcc -dumpmachine)

./configure --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
            --prefix=$INSTALLROOT --disable-nls --disable-rpath \
            --enable-dependency-tracking

make ${JOBS:+-j $JOBS}
make install
