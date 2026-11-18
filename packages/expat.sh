package: expat
version: "%(tag_basename)s"
tag: R_2_4_8
requires:
 - gcc
source: https://github.com/libexpat/libexpat
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/expat/conftools"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
ls -l "$TMPDIR"/config.*

if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
    ls -la "$TMPDIR"/config.{guess,sub}
else
    exit 1
fi

for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/conftools/*"); do
    rm -f "$CONFIG_GUESS_FILE" || { echo "❌ Failed to remove $CONFIG_GUESS_FILE"; exit 1; }
    cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE" || { echo "❌ Failed to copy config.guess to $CONFIG_GUESS_FILE"; exit 1; }
    chmod +x "$CONFIG_GUESS_FILE" || { echo "❌ Failed to chmod $CONFIG_GUESS_FILE"; exit 1; }
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/conftools/*"); do
    echo "  📝 Replacing: $CONFIG_SUB_FILE"
    rm -f "$CONFIG_SUB_FILE" || { echo "❌ Failed to remove $CONFIG_SUB_FILE"; exit 1; }
    cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE" || { echo "❌ Failed to copy config.sub to $CONFIG_SUB_FILE"; exit 1; }
    chmod +x "$CONFIG_SUB_FILE" || { echo "❌ Failed to chmod $CONFIG_SUB_FILE"; exit 1; }
done


cd "$PKGNAME"
./buildconf.sh
./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j $JOBS}

make install

