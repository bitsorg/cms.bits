package: libunwind
version: 1.8.1
variables:
  branch: master
  tag: f081cf42917bdd5c428b77850b473f31f81767cf
sources:
  - git://github.com/%(package)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s-%(branch)s&output=/%(package)s-%(version)s-%(branch)s-%(tag)s.tgz
build_requires:
  - autotools
  - gmake
requires:
  - zlib
  - xz
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv

./configure CFLAGS="-g -O3 -fcommon" \
  CPPFLAGS="-I${ZLIB_ROOT}/include -I${XZ_ROOT}/include" \
  LDFLAGS="-L${ZLIB_ROOT}/lib -L${XZ_ROOT}/lib" \
  --prefix=$INSTALLROOT --disable-block-signals --enable-zlibdebuginfo --disable-per-thread-cache

make ${JOBS:+-j$JOBS}
make install

if [ -d "$INSTALLROOT/lib64" ]; then
  mkdir -p "$INSTALLROOT/lib"
  mv "$INSTALLROOT/lib64/"* "$INSTALLROOT/lib/"
  rmdir "$INSTALLROOT/lib64"
fi
