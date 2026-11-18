package: xz-bootstrap
version: "5.6.4"
sources:
 - http://tukaani.org/xz/xz-%(version)s.tar.gz
requires:
 - gcc
---
tar xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure CFLAGS='-fPIC -D_FILE_OFFSET_BITS=64 -Ofast' --prefix=$INSTALLROOT --disable-static

make ${JOBS:+-j $JOBS}
make install

