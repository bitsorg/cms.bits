package: isal
version: "%(tag_basename)s"
tag: v2.30.0
source: https://github.com/intel/isa-l
build_requires:
 - nasm
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

./autogen.sh
./configure --prefix=$INSTALLROOT --with-pic

make ${JOBS:+-j$JOBS}
make install