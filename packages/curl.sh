package: curl
version: "8.13.0"
sources:
  - http://curl.haxx.se/download/curl-%(version)s.tar.gz
requires:
  - gcc
  - zlib
build_requires:
  - gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
./configure \
    --prefix="$INSTALLROOT" \
    --disable-silent-rules \
    --disable-static \
    --without-libidn \
    --without-zstd \
    --without-libpsl \
    --disable-ldap \
    --with-zlib="${ZLIB_ROOT}" \
    --without-nss \
    --without-libssh2 \
    --with-gssapi=/usr \
    --without-libpsl \
    --with-openssl
make ${JOBS:+-j$JOBS}
make install
rm -rf "$INSTALLROOT/lib/pkgconfig"
