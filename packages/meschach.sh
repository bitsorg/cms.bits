package: meschach
version: 1.2.pCMS1
sources:
 - http://homepage.divms.uiowa.edu/~dstewart/meschach/mesch12b.tar.gz
patches:
 - meschach-1.2-slc4.patch
 - meschach-1.2b-fPIC.patch
 - meschach-1.2b-parallel-build.patch
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR" 

patch -p0 <$SOURCEDIR/$PATCH0
patch -p0 <$SOURCEDIR/$PATCH1
patch -p1 <$SOURCEDIR/$PATCH2

if [[ $(uname) == Darwin ]]; then
  perl -p -i -e "s|define HAVE_MALLOC_H 1|undef MALLOCDECL|g" machine.h
fi

make ${JOBS:+-j$JOBS}

mkdir -p "$INSTALLROOT/include"
mkdir -p "$INSTALLROOT/lib"

cp $BUILDDIR/*.h "$INSTALLROOT/include"
cp $BUILDDIR/meschach.a "$INSTALLROOT/lib/libmeschach.a"
