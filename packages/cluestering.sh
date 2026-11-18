package: cluestering
version: 2.7.2
sources:
  - https://gitlab.cern.ch/kalos/%(package)s/-/archive/%(version)s/%(package)s-%(version)s.tar.gz
requires:
  - alpaka
  - boost
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$INSTALLROOT/include"
cp -ar include "$INSTALLROOT/"

