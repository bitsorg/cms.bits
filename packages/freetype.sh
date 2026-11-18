package: FreeType
version: v2.10.0
tag: VER-2-10-0
source: https://github.com/freetype/freetype
requires:
  - gcc
  - bz2lib
  - zlib
  - libpng
---
rsync -a --chmod=ug=rwX --exclude='**/.git' --delete --delete-excluded "$SOURCEDIR/" ./
type libtoolize && export LIBTOOLIZE=libtoolize
type glibtoolize && export LIBTOOLIZE=glibtoolize
sh autogen.sh
./configure --prefix="$INSTALLROOT"              \
            ${BZ2LIB_ROOT:+--with-bzip2="$BZ2ZLIB_ROOT"} \
            ${ZLIB_ROOT:+--with-zlib="$ZLIB_ROOT"} \
            ${LIBPNG_ROOT:+--with-png="$LIBPNG_ROOT"} \
            --with-harfbuzz=no

make ${JOBS:+-j$JOBS}
make install