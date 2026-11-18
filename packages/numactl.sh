package: numactl
version: "2.0.14"
tag: v%(version)s
source: https://github.com/numactl/numactl
build_requires:
 - autotools
requires:
 - gcc
prepend_path:
  MANPATH: $NUMACTL_ROOT/share/man
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

./autogen.sh
./configure \
  --prefix=$INSTALLROOT \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking \
  --with-pic \
  --with-gnu-ld
  
make ${JOBS:+-j $JOBS}
make install

rm -rf $INSTALLROOT/lib/pkgconfig
