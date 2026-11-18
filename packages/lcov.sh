package: lcov
version: "1.9"
sources:
 - https://sourceforge.net/projects/ltp/files/Coverage%%20Analysis/LCOV-%(version)s/lcov-%(version)s.tar.gz/download
patches:
 - lcov-merge-files-in-same-dir.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0

if [[ $(uname) == Darwin ]]; then
  sed -i.bak 's/install -p -D/install -p/g' bin/install.sh
fi

make ${JOBS:+-j$JOBS}
mkdir -p $INSTALLROOT/bin
make PREFIX=$INSTALLROOT BIN_DIR=$INSTALLROOT/bin install
