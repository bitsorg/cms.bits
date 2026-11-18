package: flex
version: "2.6.4"
sources:
 - https://github.com/westes/flex/releases/download/v%(version)s/flex-%(version)s.tar.gz
patches:
 - gcc-flex-nonfull-path-m4.patch
 - gcc-flex-disable-doc.patch
build_requires:
 - autotools
 - bison
requires:
 - gcc
---
CMS_BITS_MARCH=$(gcc -dumpmachine)

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -i "$SOURCEDIR/${PATCH0}"
patch -p1 -i "$SOURCEDIR/${PATCH1}"

CFLAGS="-O2 -Wno-error=implicit-function-declaration -Wno-error=int-conversion" \
./configure --disable-dependency-tracking --disable-nls \
            --build=$CMS_BITS_MARCH --host="$CMS_BITS_MARCH" --prefix=$INSTALLROOT

make ${JOBS:+-j $JOBS}
make install