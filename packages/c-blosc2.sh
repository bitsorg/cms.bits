package: c-blosc2
version: 2.20.0
sources:
 - https://github.com/Blosc/c-blosc2/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - ninja
 - CMake
requires:
 - zlib
 - zstd
 - lz4
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build; cd ../build

cmake $BUILDDIR \
 -G Ninja \
 -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
 -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT \
 -DDEACTIVATE_LZ4:BOOL=OFF \
 -DDEACTIVATE_SNAPPY:BOOL=ON \
 -DDEACTIVATE_ZLIB:BOOL=OFF \
 -DDEACTIVATE_ZSTD:BOOL=OFF \
 -DDEACTIVATE_AVX2:BOOL=ON \
 -DDEACTIVATE_SSE2:BOOL=ON \
 -DPREFER_EXTERNAL_ZSTD=ON \
 -DPREFER_EXTERNAL_LZ4=ON \
 -DPREFER_EXTERNAL_ZLIB=ON \
 -DCMAKE_PREFIX_PATH="$ZLIB_ROOT;$ZSTD_ROOT;$LZ4_ROOT"

ninja -v ${JOBS:+-j$JOBS} 
ninja -v ${JOBS:+-j$JOBS} install
