package: triton-inference-client
version: "2.25.0"
variables:
  branch: "r22.08"
  github_user: "triton-inference-server"
  client_tag: "b4f10a4650a6c3acd0065f063fd1b9c258f10b73"
  common_tag: "d5c561841e9bd0818c40e5153bdb88e98725ee79"
sources:
  - git+https://github.com/%(github_user)s/client.git?obj=%(branch)s/%(client_tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
  - git+https://github.com/%(github_user)s/common.git?obj=%(branch)s/%(common_tag)s&export=common-%(version)s&output=/common-%(version)s.tgz
patches:
  - triton-inference-client-uint8.patch
build_requires:
  - CMake
  - git
  - py-wheel
requires:
  - protobuf
  - grpc
  - abseil-cpp
  - re2
  - rapidjson
  - py-numpy
  - py-grpcio-tools
  - py-python-rapidjson
  - cuda
  - gcc
  - zlib
  - c-ares
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/${SOURCE1}" \
    -C "$BUILDDIR"

PROJ_DIR="$PKGNAME-$PKGVERSION/src/c++"
COMMON_DIR="$BUILDDIR/common-$PKGVERSION"
CML_COM="common-$PKGVERSION/CMakeLists.txt"

pushd $PKGNAME-$PKGVERSION
patch -p1 -s -i "$SOURCEDIR/$PATCH0"
popd

sed -i -e 's|import os|import os,sys|' "$PKGNAME-$PKGVERSION/src/python/library/build_wheel.py"
sed -i '/^project/a option(BUILD_SHARED_LIBS "Build using shared libraries" ON)' ${CML_COM}

TRITON_ENABLE_GPU_VALUE="ON"

rm -rf ../build
mkdir ../build
cd ../build

cmake ../$PKGNAME/$PKGNAME-$PKGVERSION/src/c++ \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_CXX_STANDARD=$CXXSTD \
  -DTRITON_ENABLE_CC_HTTP=OFF \
  -DTRITON_ENABLE_CC_GRPC=ON \
  -DTRITON_ENABLE_PERF_ANALYZER=OFF \
  -DTRITON_ENABLE_EXAMPLES=OFF \
  -DTRITON_ENABLE_TESTS=OFF \
  -DTRITON_USE_THIRD_PARTY=OFF \
  -DRITION_KEEP_TYPEINFO=ON \
  -DTRITON_COMMON_REPO_TAG="%(version)s" \
  -DTRITON_ENABLE_GPU=${TRITON_ENABLE_GPU_VALUE} \
  -DCMAKE_CXX_FLAGS="-Wno-error -fPIC" \
  -DFETCHCONTENT_SOURCE_DIR_REPO-COMMON=${COMMON_DIR} \
  -DCMAKE_PREFIX_PATH="${GRPC_ROOT};${ABSEIL_CPP_ROOT};${RE2_ROOT};${RAPIDJSON_ROOT}"

make ${JOBS:+-j$JOBS} VERBOSE=1


cd $BUILDDIR
rm -rf ../buildpy ; mkdir ../buildpy ; cd ../buildpy
cmake ../$PKGNAME/$PKGNAME-$PKGVERSION/src/python \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_CXX_STANDARD=$CXXSTD \
  -DTRITON_ENABLE_PYTHON_HTTP=OFF \
  -DTRITON_ENABLE_PYTHON_GRPC=ON \
  -DTRITON_ENABLE_PERF_ANALYZER=OFF \
  -DTRITON_ENABLE_EXAMPLES=OFF \
  -DTRITON_ENABLE_TESTS=OFF \
  -DTRITON_COMMON_REPO_TAG="%(common_tag)s" \
  -DTRITON_ENABLE_GPU=${TRITON_ENABLE_GPU_VALUE} \
  -DTRITON_VERSION=${PKGVERSION} \
  -DCMAKE_CXX_FLAGS="-Wno-error -Wno-error=sign-compare -Wno-error=deprecated-declarations -fPIC" \
  -DFETCHCONTENT_SOURCE_DIR_REPO-COMMON=${COMMON_DIR} \
  -DCMAKE_PREFIX_PATH="${GRPC_ROOT};${ABSEIL_CPP_ROOT};${RE2_ROOT};${RAPIDJSON_ROOT}"

make ${JOBS:+-j$JOBS} VERBOSE=1

cd ../build
make install

cd ../buildpy
mkdir -p $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}

rsync -a library/linux/wheel/build/lib/ $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/

sed -i '/^#ifdef TRITON_ENABLE_GPU/i #define TRITON_ENABLE_GPU' $INSTALLROOT/include/ipc.h

rm $INSTALLROOT/include/triton/common/triton_json.h
