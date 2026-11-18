package: xerces-c
version: "3.1.3"
tag: xerces-3.1.3
source: https://github.com/apache/xerces-c
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"

TMPDIR="$BUILDDIR/config"
mkdir -p "$TMPDIR"

rm -f "$TMPDIR"/config.{sub,guess}

curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"

curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"

ls -l "$TMPDIR"/config.*

# Verify files were downloaded successfully
if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
  ls -la "$TMPDIR"/config.{guess,sub}
else
  exit 1
fi

for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/config/*"); do
  rm -f "$CONFIG_GUESS_FILE" || {
    echo "❌ Failed to remove $CONFIG_GUESS_FILE"
    exit 1
  }
  cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE" || {
    echo "❌ Failed to copy config.guess to $CONFIG_GUESS_FILE"
    exit 1
  }
  chmod +x "$CONFIG_GUESS_FILE" || {
    echo "❌ Failed to chmod $CONFIG_GUESS_FILE"
    exit 1
  }
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/config/*"); do
  rm -f "$CONFIG_SUB_FILE" || {
    echo "❌ Failed to remove $CONFIG_SUB_FILE"
    exit 1
  }
  cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE" || {
    echo "❌ Failed to copy config.sub to $CONFIG_SUB_FILE"
    exit 1
  }
  chmod +x "$CONFIG_SUB_FILE" || {
    echo "❌ Failed to chmod $CONFIG_SUB_FILE"
    exit 1
  }
done

if [[ "$(uname)" == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -DOS_OBJECT_USE_OBJC=0"
  export CFLAGS="${CFLAGS} -DOS_OBJECT_USE_OBJC=0"
fi

export XERCESCROOT=$PWD
export VERBOSE=1

autoreconf -ivf

./configure \
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --disable-rpath \
  --without-icu \
  --without-curl

make ${JOBS:+-j$JOBS}
make install
