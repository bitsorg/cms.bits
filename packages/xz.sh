package: xz
version: 5.2.5
tag: v%(version)s
requires:
 - gcc
 - autotools
source: https://github.com/tukaani-project/xz
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded \
    "$SOURCEDIR"/ "$BUILDDIR"/

./autogen.sh --no-po4a

./configure \
    CFLAGS='-fPIC -Ofast' \
    --prefix="$INSTALLROOT" \
    --disable-static \
    --disable-nls \
    --disable-rpath \
    --disable-dependency-tracking \
    --disable-doc

make ${JOBS:+-j $JOBS}
make install

if [ -x "$INSTALLROOT/bin/xz" ]; then
  :
else
  exit 1
fi
