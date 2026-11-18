package: L1METML
version: 1.0.1
sources:
 - https://github.com/cms-hls4ml/%(package)s/archive/refs/tags/v%(version)s.tar.gz
requires:
 - hls4mlemulatorextras
 - hls
 - gcc
build_requires:
 - gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}

make PREFIX=$INSTALLROOT install
