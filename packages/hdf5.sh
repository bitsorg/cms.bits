package: hdf5
version: "1.14.6"
sources:
 - https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_%(version)s.tar.gz
requires:
 - zlib
 - openmpi
 - gcc
 - autotools
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"

CONFIGDIR="$BUILDDIR/bin/"
rm -f "$CONFIGDIR"/config.{sub,guess}

curl -L -k -s -o "$CONFIGDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$CONFIGDIR"/config.sub "$CONFIG_SUB_URL"

CXXFLAGS=-I${OPENMPI_ROOT}/include \
LDFLAGS="-L${OPENMPI_ROOT}/lib -lmpi" \
./configure --prefix=$INSTALLROOT \
            --disable-sharedlib-rpath \
            --enable-parallel \
            --enable-threadsafe --enable-unsupported \
            --with-zlib=${ZLIB_ROOT}
make  ${JOBS:+-j $JOBS} V=1
make install V=1
