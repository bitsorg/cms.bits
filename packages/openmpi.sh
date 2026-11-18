package: openmpi
version: "5.0.9"
variables:
 branch: v5.0.x
 tag: v%(version)s
 HFI_NO_BACKTRACE: "1"
 IPATH_NO_BACKTRACE: "1"
build_requires:
 - autotools
 - flex
requires:
 - gcc
 - libfabric
 - hwloc
 - rdma-core
 - xpmem
 - ucx
 - cuda
 - zlib
sources:
 - git://github.com/open-mpi/ompi.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
patches:
 - openmpi-setenv-fix.patch
env:
  OPAL_PREFIX: "$OPENMPI_ROOT"
  PMIX_PREFIX: "$OPENMPI_ROOT"
prepend_path:
  LD_LIBRARY_PATH: $OPENMPI_ROOT/lib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 
patch -p1 -i "$SOURCEDIR/$PATCH0"
echo "<runtime name=\"HFI_NO_BACKTRACE\" value=\"%(HFI_NO_BACKTRACE)s\"/>"
echo "<runtime name=\"HFI_NO_BACKTRACE\" value=\"%(IPATH_NO_BACKTRACE)s\"/>"
grep ' opal_setenv("IPATH_NO_BACKTRACE", "%(IPATH_NO_BACKTRACE)s", true, &environ)' opal/runtime/opal_init.c
grep ' opal_setenv("HFI_NO_BACKTRACE", "%(HFI_NO_BACKTRACE)s", true, &environ)' opal/runtime/opal_init.c

AUTOMAKE_JOBS=${JOBS:+-j$JOBS} ./autogen.pl
unset HWLOC_VERSION
CMS_BITS_MARCH=$(gcc -dumpmachine)
CONFIGURE_OPTS="\
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --enable-ipv6 \
  --enable-shared \
  --disable-static \
  --disable-mpi-java \
  --enable-openib-rdmacm-ibaddr \
  --with-zlib=$ZLIB_ROOT \
  --with-hwloc=$HWLOC_ROOT \
  --with-ofi=$LIBFABRIC_ROOT \
  --without-portals4 \
  --without-psm \
  --without-psm2 \
  --with-verbs=$RDMA_CORE_ROOT \
  --without-mxm \
  --with-ucx=$UCX_ROOT \
  --with-cma \
  --without-knem \
  --with-xpmem=$XPMEM_ROOT \
  --with-pic \
  --disable-io-romio \
  --with-gnu-ld \
  --with-pmix=internal \
  "
[ -z "$without_cuda" ] && CONFIGURE_OPTS+=" --with-cuda=$CUDA_ROOT"
./configure $CONFIGURE_OPTS
make ${JOBS:+-j$JOBS}
make install

#sed -i \
#  -e 's|-Wl,-rpath -Wl,@{libdir}||g' \
#  -e 's|\(.*-Wl,-rpath,\$ORIGIN/../lib\).*--enable-new-dtags|\1 -Wl,--enable-new-dtags|' \
#  $INSTALLROOT/share/openmpi/*wrapper-data.txt
find $INSTALLROOT/lib/ -name '*.la' -delete 
