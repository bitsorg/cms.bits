package: EMTF_NN
version: 1.0.0
tag: v%(version)s
source: https://github.com/cms-hls4ml/EMTF_NN
requires:
 - gcc
 - hls4mlemulatorextras
 - hls
build_requires:
 - gmake
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

make ${JOBS:+-j $JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}
make PREFIX=$INSTALLROOT install
