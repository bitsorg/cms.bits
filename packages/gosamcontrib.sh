package: gosamcontrib
version: "2.0-20180708"
sources:
 - http://www.hepforge.org/archive/gosam/gosam-contrib-%(version)s.tar.gz
patches:
 - gosamcontrib-module-patch.patch
requires:
 - qgraf
 - form
 - gcc
build_requires:
 - gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0

CXX="$(which c++) -fPIC"
CC="$(which gcc) -fPIC"
FC="$(which gfortran) -std=legacy"
PLATF_CONF_OPTS="--enable-shared --enable-static"

./configure $PLATF_CONF_OPTS \
            --prefix="$INSTALLROOT" \
            --bindir="$INSTALLROOT/bin" \
            $( [[ $(uname -m) == riscv64 ]] && echo "--build=$(uname -m)-unknown-linux-gnu" ) \
            --libdir="$INSTALLROOT/lib" \
            CXX="$CXX" CC="$CC" FC="$FC" F77="$FC"

make ${JOBS:+-j$JOBS}
make install
rm $INSTALLROOT/lib/*.la
