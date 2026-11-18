package: alpaka
version: 1.2.0
sources:
 - https://github.com/cms-externals/%(package)s/archive/%(version)s.tar.gz
requires:
 - boost
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cp -ar include $INSTALLROOT/include
