package: ruff
version: "0.5.6"
sources:
 - https://github.com/astral-sh/ruff/releases/download/%(version)s/ruff-x86_64-unknown-linux-gnu.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
mkdir -p $INSTALLROOT/bin
cp -r $BUILDDIR/ruff $INSTALLROOT/bin
