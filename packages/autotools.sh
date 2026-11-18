package: autotools
version: "1.5"
variables:
 m4_version: "1.4.19"
 autoconf_version: "2.72"
 automake_version: '1.16.5'
 libtool_version: "2.5.4"
 gettext_version: "0.22"
 pkg_config_version: "0.29.2"
sources:
 - https://mirror.ibcp.fr/pub/gnu/m4/m4-%(m4_version)s.tar.gz
 - https://mirror.ibcp.fr/pub/gnu/autoconf/autoconf-%(autoconf_version)s.tar.gz
 - https://mirror.ibcp.fr/pub/gnu/automake/automake-%(automake_version)s.tar.gz
 - https://mirror.ibcp.fr/pub/gnu/libtool/libtool-%(libtool_version)s.tar.gz
 - https://mirror.ibcp.fr/pub/gnu/gettext/gettext-%(gettext_version)s.tar.gz
 - https://pkgconfig.freedesktop.org/releases/pkg-config-%(pkg_config_version)s.tar.gz
env:
 M4: "$AUTOTOOLS_ROOT/bin/m4"
requires:
 - gcc
---
for f in "$SOURCEDIR"/*; do
    case "$f" in    
        *.tar.gz|*.tgz) tar -xzf "$f" -C "$BUILDDIR";;
    esac
done

pushd $BUILDDIR/m4-%(m4_version)s
  ./configure --disable-dependency-tracking --prefix="$INSTALLROOT"
  make ${JOBS:+-j$JOBS}
  make install
popd

pushd $BUILDDIR/autoconf-%(autoconf_version)s
  ./configure --disable-dependency-tracking --prefix="$INSTALLROOT"
  make ${JOBS:+-j$JOBS}
  make install
popd

pushd $BUILDDIR/automake-%(automake_version)s
  ./configure --disable-dependency-tracking --prefix="$INSTALLROOT"
  make ${JOBS:+-j$JOBS}
  make install
popd

pushd $BUILDDIR/libtool-%(libtool_version)s
  ./configure --disable-dependency-tracking --prefix="$INSTALLROOT"  --enable-ltdl-install
  make ${JOBS:+-j$JOBS}
  make install
popd

pushd $BUILDDIR/gettext-%(gettext_version)s
  ./configure \
    --prefix="$INSTALLROOT" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-rpath \
    --disable-nls \
    --disable-acl \
    --disable-curses \
    --disable-openmp \
    --disable-native-java \
    --disable-java \
    --enable-relocatable \
    --without-xz \
    --without-bzip2 \
    --with-included-libxml \
    --with-included-glib \
    --with-included-libunistring \
    --with-included-libcroco

  make ${JOBS:+-j$JOBS} 
  make install
popd

pushd $BUILDDIR/pkg-config-%(pkg_config_version)s 
  ./configure \
    --prefix="$INSTALLROOT" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-host-tool \
    --disable-shared \
    --with-internal-glib
  
  make ${JOBS:+-j$JOBS} 
  make install
popd

grep -l -R '/bin/perl' $INSTALLROOT | xargs -n1 sed -ideleteme -e 's;^#!.*perl;#!/usr/bin/perl;'
find $INSTALLROOT -name '*deleteme' -delete
grep -l -R '/bin/perl' $INSTALLROOT | xargs -n1 sed -ideleteme -e 's;exec [^ ]*/perl;exec /usr/bin/perl;g'
find $INSTALLROOT -name '*deleteme' -delete
