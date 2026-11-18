package: ittnotify
version: 16.06.18
sources:
 - https://github.com/01org/IntelSEAPI/archive/%(version)s.tar.gz
build_requires:
 - CMake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" -DARCH_64=1 \
  -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration" \
  ittnotify

make ${JOBS:+-j $JOBS} VERBOSE=1 all
mkdir $INSTALLROOT/lib $INSTALLROOT/include
cp libittnotify64.a  $INSTALLROOT/lib/libittnotify.a
cp ittnotify/include/ittnotify.h $INSTALLROOT/include
