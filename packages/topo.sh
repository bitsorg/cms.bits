package: TOPO
version: 5.0.0
variables:
  smp_flags: ""
tag: a0e40c6a4dd9aa2184aaaf5edab6b8d2fb8ebd4d
source: https://github.com/cms-hls4ml/TOPO.git
build_requires:
 - gmake
requires:
 - gcc
 - hls4mlemulatorextras
 - hls
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

make ${JOBS:+-j$JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}

make PREFIX=$INSTALLROOT install
