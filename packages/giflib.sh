package: giflib
version: "5.2.1"
sources:
 - https://sourceforge.net/projects/giflib/files/giflib-%(version)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

echo "all:" > doc/Makefile
make all ${JOBS:+-j$JOBS} LIBVER=$PKGVERSION LIBMAJOR=5 PREFIX=$INSTALLROOT
make LIBVER=${PKGVERSION} LIBMAJOR=5 PREFIX=$INSTALLROOT install