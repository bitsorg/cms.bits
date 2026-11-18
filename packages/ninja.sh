package: ninja
version: "%(tag_basename)s"
tag: v1.11.1
source: https://github.com/ninja-build/ninja
build_requires:
  - re2c
  - Python
requires:
  - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/
python3 ./configure.py --bootstrap

mkdir -p "$INSTALLROOT/bin"
cp ninja $INSTALLROOT/bin