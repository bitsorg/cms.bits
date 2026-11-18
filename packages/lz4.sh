package: lz4
version: "%(tag_basename)s"
tag: v1.9.2
source: https://github.com/lz4/lz4
build_requires:
  - gcc
  - CMake
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

make ${JOBS:+-j$JOBS}
make install PREFIX=$INSTALLROOT