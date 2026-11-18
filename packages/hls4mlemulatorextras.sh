package: hls4mlemulatorextras
version: 1.1.4
build_requires:
 - gmake
sources:
 - https://github.com/cms-hls4ml/%(package)s/archive/refs/tags/v%(version)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS}
make PREFIX=$INSTALLROOT install 
