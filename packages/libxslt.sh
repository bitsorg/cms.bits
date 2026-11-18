package: libxslt
version: "1.1.42"
tag: v%(version)s
source: https://gitlab.gnome.org/GNOME/libxslt.git
build_requires:
- autotools
requires:
- gcc
- libxml2
- pkg-config
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

export CPPFLAGS="-I${LIBXML2_ROOT}/include/libxml2"
export LDFLAGS="-L${LIBXML2_ROOT}/lib"
export PKG_CONFIG_PATH="${LIBXML2_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"

export LIBS="-lxml2"

./autogen.sh \
--prefix=$INSTALLROOT \
--disable-silent-rules \
--with-libxml-prefix=$LIBXML2_ROOT \
--without-crypto --without-python

make ${JOBS:+-j${JOBS}}
make install
