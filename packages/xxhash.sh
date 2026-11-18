package: xxhash
version: "v%(tag_basename)s"
tag: "0.8.2"
sources:
 - https://github.com/Cyan4973/xxHash/archive/refs/tags/v%(tag_basename)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS} prefix="$INSTALLROOT"
make install  prefix="$INSTALLROOT"
