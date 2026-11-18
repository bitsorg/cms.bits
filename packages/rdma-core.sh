package: rdma-core
version: "%(tag_basename)s"
tag: v57.0
source: https://github.com/linux-rdma/rdma-core
build_requires:
 - CMake
 - ninja
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$PKGNAME-$PKGVERSION"/

cmake $PKGNAME-$PKGVERSION \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_INSTALL_RUNDIR=/var/run \
  -DENABLE_RESOLVE_NEIGH=FALSE \
  -DENABLE_STATIC=FALSE \
  -DNO_MAN_PAGES=TRUE \

cmake -L .

ninja -v ${JOBS:+-j$JOBS}
ninja install

rm -rf $INSTALLROOT/lib64/pkgconfig
rm -rf $INSTALLROOT/etc/infiniband-diags
rm -rf $INSTALLROOT/etc/init.d
rm -rf $INSTALLROOT/etc/modprobe.d
rm -rf $INSTALLROOT/etc/rdma
rm -rf $INSTALLROOT/lib
rm -rf $INSTALLROOT/libexec
rm -rf $INSTALLROOT/sbin
rm -rf $INSTALLROOT/share/perl5

sed -e's#driver \(\w\+\)#driver $INSTALLROOT/lib64/libibverbs/lib\1#' -i $INSTALLROOT/etc/libibverbs.d/*