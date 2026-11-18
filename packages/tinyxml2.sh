package: tinyxml2
version: "6.2.0"
sources:
  - https://github.com/leethomason/%(package)s/archive/%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build ; cd ../build

cmake ../$PKGNAME \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE

gmake ${JOBS:+-j$JOBS} install