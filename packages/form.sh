package: form
version: 4.2.1
sources:
 - https://github.com/vermaseren/form/releases/download/v%(version)s/form-%(version)s.tar.gz
build_requires:
 - gmake
requires:
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CXX="$(which g++)"
CC="$(which gcc)"

./configure --prefix="$INSTALLROOT" \
            --bindir="$INSTALLROOT/bin" \
            --without-gmp \
            $( [[ $(uname -m) == riscv64 ]] && echo "--build=$(uname -m)-unknown-linux-gnu" ) \
            --with-zlib="$ZLIB_ROOT" \
            CXX="$CXX" CC="$CC" CXXFLAGS=-fpermissive

make ${JOBS:+-j$JOBS}
make install
