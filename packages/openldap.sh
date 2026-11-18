package: openldap
version: 2.5.19
sources:
 - ftp://ftp.openldap.org/pub/OpenLDAP/%(package)s-release/%(package)s-%(version)s.tgz
requires:
 - db6
 - gcc
 - libuuid
prepend_path:
  LD_LIBRARY_PATH: $OPENLDAP_ROOT/lib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 
CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"

TMPDIR="$BUILDDIR/build"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"

./configure \
  --prefix=$INSTALLROOT \
  --without-cyrus-sasl \
  --with-tls=openssl \
  --disable-static \
  --disable-slapd \
  CPPFLAGS="-I${DB6_ROOT}/include" \
  LDFLAGS="-L${DB6_ROOT}/lib"
make depend
make

make install
find $INSTALLROOT/lib -type f | xargs chmod 0755
rm -rf $INSTALLROOT/man $INSTALLROOT/share/man
