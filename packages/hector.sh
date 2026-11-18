package: hector
version: 1.3.4_patch1
tag: 566e76718059fde2bf044579a2010a482b52a04a
source: https://github.com/cms-externals/hector
requires:
 - ROOT
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
mkdir -p obj lib

if [[ $(uname) == "Darwin" ]]; then
  perl -p -i -e 's|-rdynamic||g' Makefile
fi

sed -i.bak 's/@g++/ -fPIC -O2 -std=c++20/g' Makefile
make
rsync -a . $INSTALLROOT
