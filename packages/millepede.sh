package: millepede
version: V04-16-00
sources:
 - https://gitlab.desy.de/claus.kleinwort/millepede-ii/-/archive/%(version)s/%(package)s-ii-%(version)s.tar.gz
requires:
 - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
make \
  ZLIB_INCLUDES_DIR="${ZLIB_ROOT}/include" \
  ZLIB_LIBS_DIR="${ZLIB_ROOT}/lib"

make install PREFIX=$INSTALLROOT
