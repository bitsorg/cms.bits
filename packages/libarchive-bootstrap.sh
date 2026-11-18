package: libarchive-bootstrap
version: "3.7.7"
sources:
- http://www.libarchive.org/downloads/libarchive-%(version)s.tar.gz
requires:
- xz-bootstrap
- gcc
---
tar xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"

TMPDIR="$BUILDDIR/tmp"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
ls -l "$TMPDIR"/config.*
for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_GUESS_FILE"
    cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE"
    chmod +x "$CONFIG_GUESS_FILE"
done
for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_SUB_FILE"
    cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE"
    chmod +x "$CONFIG_SUB_FILE"
done

./configure \
  --prefix=$INSTALLROOT \
  --disable-silent-rules \
  --disable-dependency-tracking \
  --disable-rpath \
  --disable-bsdtar \
  --disable-bsdcpio \
  --enable-static \
  --disable-shared \
  --without-lzmadec \
  --without-iconv \
  --without-lzo2 \
  --without-nettle \
  --without-openssl \
  --without-xml2 \
  --without-expat \
  CPPFLAGS="-I${XZ_BOOTSTRAP_ROOT}/include" \
  LDFLAGS="-L${XZ_BOOTSTRAP_ROOT}/lib"

make ${JOBS:+-j $JOBS}
make install

find $INSTALLROOT/lib -type f -name '*.la' -delete
