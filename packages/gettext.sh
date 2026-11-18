package:  gettext
version: "v%(tag_basename)s"
tag: "0.22"
sources:
- https://mirror.ibcp.fr/pub/gnu/gettext/gettext-0.22.tar.gz
requires:
- gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
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

if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
    ls -la "$TMPDIR"/config.{guess,sub}
else
    exit 1
fi
for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_GUESS_FILE" || { echo "❌ Failed to remove $CONFIG_GUESS_FILE"; exit 1; }
    cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE" || { echo "❌ Failed to copy config.guess to $CONFIG_GUESS_FILE"; exit 1; }
    chmod +x "$CONFIG_GUESS_FILE" || { echo "❌ Failed to chmod $CONFIG_GUESS_FILE"; exit 1; }
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_SUB_FILE" || { echo "❌ Failed to remove $CONFIG_SUB_FILE"; exit 1; }
    cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE" || { echo "❌ Failed to copy config.sub to $CONFIG_SUB_FILE"; exit 1; }
    chmod +x "$CONFIG_SUB_FILE" || { echo "❌ Failed to chmod $CONFIG_SUB_FILE"; exit 1; }
done

./configure \
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --disable-rpath \
  --disable-nls \
  --disable-acl \
  --disable-curses \
  --disable-openmp \
  --disable-native-java \
  --disable-java \
  --enable-relocatable \
  --without-xz \
  --without-bzip2 \
  --with-included-libxml \
  --with-included-glib \
  --with-included-libunistring \
  --with-included-libcroco

make ${JOBS:+-j$JOBS} 
make install

grep -l -R '/bin/perl' $INSTALLROOT | xargs -n1 sed -ideleteme -e 's;^#!.*perl;#!/usr/bin/perl;'
find $INSTALLROOT -name '*deleteme' -delete
grep -l -R '/bin/perl' $INSTALLROOT | xargs -n1 sed -ideleteme -e 's;exec [^ ]*/perl;exec /usr/bin/perl;g'
find $INSTALLROOT -name '*deleteme' -delete
