package: gdrcopy
version: "%(tag_basename)s"
tag: v2.4.4
source: https://github.com/NVIDIA/gdrcopy
requires:
 - cuda
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
make ${JOBS:+-j$JOBS} prefix=$INSTALLROOT libdir=$INSTALLROOT/lib64 CUDA=$CUDA_ROOT lib
make ${JOBS:+-j$JOBS} prefix=$INSTALLROOT libdir=$INSTALLROOT/lib64 CUDA=$CUDA_ROOT lib_install