package: mpich
version: 4.3.2
sources: 
 - https://github.com/pmodels/mpich/releases/download/v%(version)s/mpich-%(version)s.tar.gz
build_requires:
 - autotools
 - cuda
 - rocm
requires:
 - Python
 - gcc
 - cuda-flags
 - rocm-flags
 - libfabric
 - ucx
 - hwloc
 - xpmem
---
export PYTHONHOME=$PYTHON_ROOT
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
export j=$(echo $cuda_arch | sed -e's/ \+/,/g')
rm -rf modules/hwloc
sed -e's/do_hwloc=.*/do_hwloc=no/' -i autogen.sh
rm -rf modules/libfabric
sed -e's/do_ofi=.*/do_ofi=no/' -i autogen.sh
rm -rf modules/ucx
sed -e's/do_ucx=.*/do_ucx=no/' -i autogen.sh

./autogen.sh
configure_args=(
  --prefix="$INSTALLROOT"
  --enable-error-checking="all"
  --enable-tag-error-bits=yes
  --enable-fast=O2,ndebug,sse2
  --enable-cxx
  --enable-romio
  --disable-mpi-abi
  --enable-versioning
  --enable-threads=multiple
  --enable-thread-cs=default
  --disable-dependency-tracking
  --disable-silent-rules
  --disable-maintainer-mode
  --enable-shared
  --disable-static
  --enable-nemesis-shm-collectives
  --without-hip
  --without-ze
  --with-pic
  --with-gnu-ld
  --with-libfabric="$LIBFABRIC_ROOT"
  --with-ucx="$UCX_ROOT"
  --with-hwloc="$HWLOC_ROOT"
  --without-netloc
  --with-xpmem="$XPMEM_ROOT"
  --with-yaksa=embedded
  --with-device=ch4:ucx
  )

if [[ -z $CUDA_ROOT ]]; then
  configure_args+=("--without-cuda")
else
  configure_args+=("--with-cuda=$CUDA_ROOT")
  configure_args+=("--with-cuda-sm=$j")
fi

./configure "${configure_args[@]}"

make ${JOBS:+-j$JOBS} V=1
make install
