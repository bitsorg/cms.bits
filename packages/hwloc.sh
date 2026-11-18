package: hwloc
version: "2.12.2"
sources:
 - https://download.open-mpi.org/release/%(package)s/v2.12/%(package)s-%(version)s.tar.gz
build_requires:
 - autotools
requires:
 - gcc
 - rocm
 - cuda
 - zlib
 - gcc
 - libpciaccess
 - libxml2
 - numactl
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

args=(
  --prefix "${INSTALLROOT}"
  --enable-shared
  --disable-static
  --disable-dependency-tracking
  --enable-cpuid
  --enable-libxml2
  --disable-cairo
  --disable-doxygen
  --disable-opencl
  --with-pic
  --with-gnu-ld
  --without-x
  HWLOC_PCIACCESS_CFLAGS="-I$LIBPCIACCESS_ROOT/include"
  HWLOC_PCIACCESS_LIBS="-L$LIBPCIACCESS_ROOT/lib -lpciaccess"
  HWLOC_LIBXML2_CFLAGS="-I$LIBXML2_ROOT/include/libxml2"
  HWLOC_LIBXML2_LIBS="-L$LIBXML2_ROOT/lib -lxml2"
  HWLOC_NUMA_CFLAGS="-I$NUMACTL_ROOT/include"
  HWLOC_NUMA_LIBS="-L$NUMACTL_ROOT/lib -lnuma"
)

if [[ -n "$CUDA_ROOT" ]]; then
  args+=(
    --with-cuda="$CUDA_ROOT"
    --enable-cuda
    --enable-nvml
  )
fi

if [[ -n "$ROCM_ROOT" ]]; then
  args+=(
    --with-rocm="$ROCM_ROOT"
    --enable-rsmi
  )
  if [[ -n "$CUDA_ROOT" ]]; then
    args+=(
      --enable-plugins=cuda,nvml,rsmi
    )
  else
    args+=(
      --enable-plugins=rsmi
    )
  fi
fi

./configure "${args[@]}"

make ${JOBS:+-j$JOBS}
make install

# remove the libtool library files
rm -f  $INSTALLROOT/lib/lib*.la
rm -f  $INSTALLROOT/lib/hwloc/*.la

# remove unnecessary or unwanted files
rm -rf $INSTALLROOT/sbin
rm -rf $INSTALLROOT/share/doc
rm -rf $INSTALLROOT/share/hwloc
rm -f  $INSTALLROOT/share/man/man1/hwloc-dump-hwdata.1
