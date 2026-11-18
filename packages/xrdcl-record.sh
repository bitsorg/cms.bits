package: xrdcl-record
version: "5.4.2"
build_requires:
- CMake
- gmake
requires:
- XRootD
- gcc
sources:
- https://github.com/xrootd/xrdcl-record/archive/refs/tags/v%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build ; cd ../build

cmake ../$PKGNAME \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_PREFIX_PATH="${XROOTD_ROOT}" \
  -DCMAKE_VERBOSE=1 \
  -DCMAKE_CXX_FLAGS="-L${XROOTD_ROOT}/lib64"

gmake ${JOBS:+-j$JOBS} VERBOSE=1
gmake install
