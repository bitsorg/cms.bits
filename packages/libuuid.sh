package: libuuid
version: "%(tag_basename)s"
tag: "2.34"
sources: 
- http://www.kernel.org/pub/linux/utils/util-linux/v%(tag_basename)s/util-linux-%(tag_basename)s.tar.gz 
requires:
  - gcc
---
tar -xzf "$SOURCEDIR"/*.tar.gz -C "$BUILDDIR"
cd $BUILDDIR/util-linux-*
export CFLAGS="-Wno-error=implicit-function-declaration"

./configure \
    $([ $(uname) == Darwin ] && echo --disable-shared) \
    --libdir=$INSTALLROOT/lib64 \
    --prefix=$INSTALLROOT \
    --disable-silent-rules \
    --disable-tls \
    --disable-rpath \
    --disable-libblkid \
    --disable-libmount \
    --disable-mount \
    --disable-losetup \
    --disable-fsck \
    --disable-partx \
    --disable-mountpoint \
    --disable-fallocate \
    --disable-unshare \
    --disable-eject \
    --disable-agetty \
    --disable-cramfs \
    --disable-wdctl \
    --disable-switch_root \
    --disable-pivot_root \
    --disable-kill \
    --disable-utmpdump \
    --disable-rename \
    --disable-login \
    --disable-sulogin \
    --disable-su \
    --disable-schedutils \
    --disable-wall \
    --disable-makeinstall-setuid \
    --without-ncurses \
    --enable-libuuid

make ${JOBS:+-j $JOBS}

mkdir -p $INSTALLROOT/lib64
cp -p $BUILDDIR/util-linux-*/.libs/libuuid.a* $INSTALLROOT/lib64

if [ "$(uname -s)" = "Linux" ]; then
	cp -p $BUILDDIR/util-linux-*/.libs/libuuid.so* $INSTALLROOT/lib64
fi

mkdir -p $INSTALLROOT/include
make install-uuidincHEADERS
