package: grpc
version: "%(tag_basename)s"
tag: v1.35.0
sources:
 - https://github.com/grpc/grpc/archive/refs/tags/%(tag_basename)s.tar.gz
build_requires:
 - CMake
 - ninja
 - go
requires:
 - protobuf
 - zlib
 - pcre
 - c-ares 
 - abseil-cpp
 - re2
 - gcc
patches:
 - grpc-mno-outline-atomics.patch
 - 28212.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -i $SOURCEDIR/$PATCH1
mkdir build
cd build
cmake -S .. -B . build -G Ninja \
  -DgRPC_INSTALL:BOOL=ON \
  -DCMAKE_BUILD_TYPE:STRING="${LLVM_RELEASE_TYPE}" \
  -DCMAKE_CXX_STANDARD:STRING="${CXXSTD}" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_INSTALL_LIBDIR:PATH=lib \
  -DgRPC_ABSL_PROVIDER:STRING=package \
  -DgRPC_CARES_PROVIDER:STRING=package \
  -DgRPC_PROTOBUF_PROVIDER:STRING=package \
  -DgRPC_SSL_PROVIDER:STRING=package \
  -DgRPC_ZLIB_PROVIDER:STRING=package \
  -DgRPC_RE2_PROVIDER:STRING=package \
  -DZLIB_ROOT:PATH="${ZLIB_ROOT}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${INSTALLROOT}" \
  -DCMAKE_PREFIX_PATH:PATH="${PCRE_ROOT};${PROTOBUF_ROOT};${ZLIB_ROOT};${C_ARES_ROOT};${ABSEIL_CPP_ROOT};${RE2_ROOT}"
ninja -v ${JOBS:+-j$JOBS} install
ln -sf ../../../abseil-cpp/${ABSEIL_CPP_VERSION}/include/absl $INSTALLROOT/include/absl
