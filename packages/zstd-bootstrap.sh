package: zstd-bootstrap
version: "1.5.4"
sources:
 - https://github.com/facebook/zstd/releases/download/v%(version)s/zstd-%(version)s.tar.gz
requires:
 - gcc
---
# extract
tar -xzf "$SOURCEDIR/$SOURCE0" \
  --strip-components=1 \
  -C "$BUILDDIR"

# configure
cmake -S "$BUILDDIR/build/cmake" -B "$BUILDDIR" \
  -DZSTD_BUILD_CONTRIB=OFF \
  -DZSTD_BUILD_STATIC=ON \
  -DZSTD_BUILD_SHARED=OFF \
  -DZSTD_BUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE="$DCMAKE_BUILD_TYPE" \
  -DZSTD_BUILD_PROGRAMS=OFF \
  -DZSTD_LEGACY_SUPPORT=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -Dzstd_VERSION="%(version)s"

# build & install
make -C "$BUILDDIR" ${JOBS:+-j"$JOBS"}
make -C "$BUILDDIR" install

