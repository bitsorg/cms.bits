package: valgrind
version: "3.24.0"
build_requires:
- autotools
- gmake
requires:
- gcc
sources:
-  https://sourceware.org/pub/valgrind/valgrind-%(version)s.tar.bz2
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CONF_OPTS="--enable-only64bit"

if [[ "$(uname)" == "Darwin" ]]; then
  CFLAGS="-D__private_extern__=extern"
fi

./autogen.sh
./configure --prefix=$INSTALLROOT --without-mpicc --disable-static ${CONF_OPTS}


make ${JOBS:+-j $JOBS}
make install
