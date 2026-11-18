package: heaptrack
version: "1.4.0"
sources:
 - https://github.com/KDE/heaptrack/archive/refs/tags/v%(version)s.tar.gz
 - https://invent.kde.org/sdk/heaptrack/-/commit/c6c45f3455a652c38aefa402aece5dafa492e8ab.patch
build_requires:
 - CMake
requires:
 - boost
 - libunwind
 - zstd
 - bz2lib
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/${SOURCE1}"

cmake -S "$BUILDDIR" -B "$BUILDROOT/build" \
   -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
   -DCMAKE_VERBOSE_MAKEFILE=TRUE \
   -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-g -O3" \
   -DCMAKE_PREFIX_PATH="${LIBUNWIND_ROOT};${BOOST_ROOT};${ZSTD_ROOT};${BZ2LIB_ROOT};${ZLIB_ROOT}" \
   -DHEAPTRACK_BUILD_GUI=off \
   -DHEAPTRACK_USE_LIBUNWIND=on \
   -DHEAPTRACK_BUILD_PRINT=on

cmake --build "$BUILDROOT/build" ${JOBS:+--parallel $JOBS} -- DEBUG=1 VERBOSE=1
cmake --install "$BUILDROOT/build"
