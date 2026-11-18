package: nasm
version: "%(tag_basename)s"
tag: 2.14.02
sources:
- https://www.nasm.us/pub/nasm/releasebuilds/%(tag_basename)s/nasm-%(tag_basename)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR"/*.tar.gz \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure --prefix="$INSTALLROOT"

make ${JOBS:+-j$JOBS}
make install