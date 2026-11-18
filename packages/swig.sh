package: swig
version: "4.0.2"
sources:
  - http://prdownloads.sourceforge.net/swig/swig-%(version)s.tar.gz
requires:
  - zlib
  - gcc
env:
  SWIG_HOME: "$SWIG_ROOT"
  SWIG_LIB: "$SWIG_ROOT/share/swig/$SWIG_VERSION"
prepend_path:
  LD_LIBRARY_PATH: $SWIG_ROOT/lib/SHERPA-MC/lib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CFLAGS="-I${ZLIB_ROOT}/include" \
LDFLAGS="-L${ZLIB_ROOT}/lib" \
./configure --prefix=$INSTALLROOT --without-pcre

make ${JOBS:+-j$JOBS} 
make install
