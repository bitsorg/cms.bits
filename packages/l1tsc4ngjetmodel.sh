package: L1TSC4NGJetModel
version: 0.0.0
sources:
 - https://github.com/cms-hls4ml/%(package)s/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - gmake
requires:
 - hls
 - hls4mlemulatorextras
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j $JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}
make PREFIX=$INSTALLROOT install
