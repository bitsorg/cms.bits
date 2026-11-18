package: file-bootstrap
version: "5.46"
tag: FILE5_46
source: https://github.com/file/file
requires:
 - autotools
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

autoreconf -fiv
./configure --prefix=$INSTALLROOT
make
make install
