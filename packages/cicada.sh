package: CICADA
version: 1.4.0
build_requires:
 - gmake
requires:
 - hls4mlemulatorextras
 - hls
 - gcc
sources:
- https://github.com/cms-hls4ml/%(package)s/archive/refs/tags/%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}
make PREFIX=$INSTALLROOT install
