package: cepgen
version: 1.2.5
sources:
 - https://github.com/cepgen/cepgen/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - CMake
 - ninja
requires:
 - gcc
 - GSL
 - OpenBLAS
 - hepmc
 - hepmc3
 - lhapdf
 - pythia6
 - ROOT
 - bz2lib
 - zlib
 - xz
 - Python
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i -e 's|add_subdirectory(BoostWrapper)||' "$BUILDDIR/CepGenAddOns/CMakeLists.txt"

# Export package roots for cmake discovery
export GSL_DIR="${GSL_ROOT}"
export OPENBLAS_DIR="${OPENBLAS_ROOT}"
export HEPMC_DIR="${HEPMC_ROOT}"
export HEPMC3_DIR="${HEPMC3_ROOT}"
export LHAPDF_PATH="${LHAPDF_ROOT}"
export PYTHIA6_DIR="${PYTHIA6_ROOT}"
export ROOTSYS="${ROOT_ROOT}"

cmake_args=(
    -G Ninja
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"
    -DBoost_NO_SYSTEM_PATHS=ON
    -DCMAKE_PREFIX_PATH="${BZ2LIB_ROOT};${ZLIB_ROOT};${XZ_ROOT}"
)
cmake "${cmake_args[@]}"
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS}
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS} install

# Remove unversioned addon libraries
rm -f "$INSTALLROOT/lib/libCepGen"-[A-Z]*-"%(version)s.so"
