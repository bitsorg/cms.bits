package: gperftools
version: "2.11"
sources:
 - https://github.com/gperftools/gperftools/archive/refs/tags/gperftools-%(version)s.tar.gz
build_requires:
 - autotools
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./autogen.sh

./configure \
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --enable-sized-delete \
  --enable-dynamic-sized-delete-support \
  --disable-libunwind \
  --disable-debugalloc

make ${JOBS:+-j$JOBS}
make install

rm -rf $INSTALLROOT/share/{doc,man}
