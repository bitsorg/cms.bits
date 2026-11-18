package: ucx
version: "1.18.1"
tag: v1.18.1
source: https://github.com/openucx/ucx
build_requires:
 - autotools
requires:
 - gcc
 - numactl
 - rdma-core
 - xpmem
 - cuda
 - rocm
 - gdrcopy
---
export without_rocm="yes"

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

./autogen.sh

CONFIGURE_OPTS="\
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --enable-openmp \
  --enable-shared \
  --disable-static \
  --enable-ucg \
  --disable-doxygen-doc \
  --disable-doxygen-man \
  --disable-doxygen-html \
  --enable-compiler-opt \
  --enable-cma \
  --enable-mt \
  --with-pic \
  --with-gnu-ld \
  --with-avx \
  --with-sse41 \
  --with-sse42 \
  --without-go \
  --without-java"

# Conditionally enable CUDA
if [ -z "$without_cuda" ]; then
  CONFIGURE_OPTS+=" --with-cuda=$CUDA_ROOT"
  CONFIGURE_OPTS+=" --with-gdrcopy=$GDRCOPY_ROOT"
else
  CONFIGURE_OPTS+=" --without-cuda"
  CONFIGURE_OPTS+=" --without-gdrcopy"
fi

# Conditionally enable ROCM
if [ -z "$without_rocm" ]; then
  CONFIGURE_OPTS+=" --with-rocm=$ROCM_ROOT"
else
  CONFIGURE_OPTS+=" --without-rocm"
fi

CONFIGURE_OPTS+=" \
  --with-verbs=$RDMA_CORE_ROOT \
  --with-rc \
  --with-ud \
  --with-dc \
  --with-mlx5-dv \
  --with-ib-hw-tm \
  --with-dm \
  --with-rdmacm=$RDMA_CORE_ROOT \
  --without-knem \
  --with-xpmem=$XPMEM_ROOT \
  --without-ugni"

export CPPFLAGS="-I$NUMACTL_ROOT/include"
export LDFLAGS="-L$NUMACTL_ROOT/lib"

./configure $CONFIGURE_OPTS
make ${JOBS:+-j$JOBS}
make install

rm -rf $INSTALLROOT/lib/pkgconfig
rm -f $INSTALLROOT/lib/lib*.la
rm -f $INSTALLROOT/lib/ucx/lib*.la
rm -rf $INSTALLROOT/share/ucx/examples
