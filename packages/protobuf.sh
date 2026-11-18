package: protobuf
version: "%(tag_basename)s"
tag: v3.21.9
sources: 
- https://github.com/protocolbuffers/protobuf/archive/refs/tags/%(tag_basename)s.tar.gz
requires:
- gcc
- zlib
build_requires:
- CMake
- ninja
patches:
- protobuf_text_format.patch
- protobuf-non-virtual-dtor.patch
---
rsync -a --chmod=ug=rwX --delete \
  --include='*/' \
  --include='*.patch' \
  --exclude='*' \
  "$SOURCEDIR"/ "$BUILDDIR"/

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

patch -p1 <$PATCH0
#patch -p1 <$PATCH1

./autogen.sh 
cd cmake
cmake -G Ninja \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
      -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
      -DCMAKE_CXX_STANDARD=17 \
      -Dprotobuf_BUILD_TESTS=OFF \
      -Dprotobuf_BUILD_SHARED_LIBS=ON \
      -Dutf8_range_ENABLE_INSTALL=ON \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_CXX_FLAGS="-I${ZLIB_ROOT}/include" \
      -DCMAKE_C_FLAGS="-I${ZLIB_ROOT}/include" \
      -DCMAKE_SHARED_LINKER_FLAGS="-L${ZLIB_ROOT}/lib" \
      -DCMAKE_PREFIX_PATH="${ZLIB_ROOT}"

ninja -v ${JOBS:+-j $JOBS} install
rm -rf $INSTALLROOT/lib/pkgconfig
