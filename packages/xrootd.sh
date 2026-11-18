package: XRootD
version: "%(tag_basename)s"
tag: "v5.8.4"
source: https://github.com/xrootd/xrootd
requires:
  - zlib
  - libuuid
  - curl
  - davix
  - Python
  - setuptools
  - libxml2
  - isal
  - pip
  - gcc
build_requires:
  - CMake
  - gmake
  - pip
---
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
SOEXT="so"
if [[ "$OS" == "darwin" ]]; then
   SOEXT="dylib"
fi

sed -i \
  -e 's|^ *check_cxx_symbol_exists("uuid_generate_random" "uuid/uuid.h" _have_libuuid.*$|set(_have_libuuid TRUE)|' \
  $SOURCEDIR/cmake/Findlibuuid.cmake

unset PIP_ROOT
#SKIP_PIP_INSTALL=1
cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX=${INSTALLROOT} \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DFORCE_ENABLED=ON \
  -DENABLE_FUSE=FALSE \
  -DENABLE_VOMS=FALSE \
  -DXRDCL_ONLY=TRUE \
  -DENABLE_KRB5=TRUE \
  -DENABLE_READLINE=TRUE \
  -DCMAKE_SKIP_RPATH=TRUE \
  -DENABLE_PYTHON=TRUE \
  -DENABLE_HTTP=TRUE \
  -DENABLE_XRDEC=TRUE \
  -DXRD_PYTHON_REQ_VERSION=3 \
  -DPIP_OPTIONS="--verbose" \
  -DCMAKE_CXX_FLAGS="-I${LIBUUID_ROOT}/include" \
  -DCMAKE_SHARED_LINKER_FLAGS="-L${LIBUUID_ROOT}/lib64" \
  -DCMAKE_PREFIX_PATH="$CURL_ROOT;$ZLIB_ROOT;$EXPAT_ROOT;$BZ2LIB_ROOT;$DAVIX_ROOT;$PIP_ROOT"

make ${JOBS:+-j $JOBS}
make install
