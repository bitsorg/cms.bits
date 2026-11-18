package: libpng
version: "%(tag_basename)s"
tag: cms/v1.6.37
requires:
  - gcc
  - zlib
build_requires:
  - CMake
source: https://github.com/cms-externals/libpng
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

autoreconf -fiv

./configure \
  --prefix="$INSTALLROOT" \
  --disable-silent-rules \
  CPPFLAGS="-I${ZLIB_ROOT}/include" \
  LDFLAGS="-L${ZLIB_ROOT}/lib"

make ${JOBS:+-j $JOBS}
make install