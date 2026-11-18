package: acts
version: v44.0.1
tag: 30fb4ea
source: https://github.com/cms-externals/acts
build_requires:
  - CMake
requires:
  - boost
  - gcc
  - bz2lib
  - dd4hep
  - eigen
  - expat
  - geant4
  - json
  - Python
  - ROOT
  - xerces-c
  - zlib
  - cuda
  - rocm
  - hepmc3
  - TBB
  - cuda-flags
  - rocm-flags
---
# Configuration
export build_test="0"
export CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"

# Detect CUDA and ROCm
cuda_enabled="OFF"; [ -n "$CUDA_ROOT" ] && cuda_enabled="ON"
rocm_enabled="OFF"; [ -n "$ROCM_ROOT" ] && rocm_enabled="ON"

# ROCm support is not yet building correctly
export rocm_enabled="OFF"

# Sync source
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

# Build cmake_args array
cmake_args=(
    "-DCMAKE_PREFIX_PATH=$GCC_ROOT;$BOOST_ROOT;$BZ2LIB_ROOT;$DD4HEP_ROOT;$EIGEN_ROOT;$EXPAT_ROOT;$GEANT4_ROOT;$JSON_ROOT;$PYTHON_ROOT;$ROOT_ROOT;$XERCES_C_ROOT;$ZLIB_ROOT;$CUDA_ROOT;$ROCM_ROOT;$HEPMC3_ROOT;$TBB_ROOT"
    "-DCMAKE_CXX_COMPILER=$GCC_ROOT/bin/g++"
    "-DCMAKE_CXX_STANDARD=$CXXSTD"
    "-DCMAKE_CXX_FLAGS=-fPIC $CMS_EIGEN_CXX_FLAGS ${arch_build_flags} $selected_microarch ${lto_build_flags}"
    "-DCMAKE_AR=$GCC_ROOT/bin/gcc-ar"
    "-DCMAKE_RANLIB=$GCC_ROOT/bin/gcc-ranlib"
    "-DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE"
    "-DCMAKE_INSTALL_PREFIX=$INSTALLROOT"
    "-DCMAKE_SKIP_INSTALL_RPATH=ON"
    "-DBUILD_SHARED_LIBS=ON"
    "-DACTS_NLOHMANNJSON_SOURCE="
    "-DACTS_USE_SYSTEM_NLOHMANN_JSON=ON"
    "-DACTS_BUILD_PLUGIN_ACTSVG=ON"
    "-DACTS_BUILD_PLUGIN_JSON=ON"
    "-DACTS_BUILD_PLUGIN_ROOT=ON"
    "-DACTS_BUILD_PLUGIN_DD4HEP=ON"
    "-DACTS_BUILD_PLUGIN_GEANT4=ON"
    "-DACTS_BUILD_PLUGIN_TRACCC=ON"
    "-DACTS_ENABLE_LOG_FAILURE_THRESHOLD=ON"
    "-DCOVFIE_PLATFORM_CPU=ON"
    "-DCOVFIE_PLATFORM_CUDA=${cuda_enabled}"
    "-DCOVFIE_PLATFORM_HIP=${rocm_enabled}"
    "-DDETRAY_SETUP_NLOHMANN=ON"
    "-DDETRAY_USE_SYSTEM_NLOHMANN=ON"
    "-DDETRAY_BUILD_HOST=ON"
    "-DDETRAY_BUILD_CUDA=${cuda_enabled}"
    "-DDETRAY_BUILD_HIP=${rocm_enabled}"
    "-DTRACCC_BUILD_CUDA=${cuda_enabled}"
    "-DTRACCC_BUILD_HIP=${rocm_enabled}"
    "-DTRACCC_SETUP_THRUST=${cuda_enabled}"
    "-DTRACCC_SETUP_ROCTHRUST=${rocm_enabled}"
    "-DTRACCC_USE_SYSTEM_THRUST=${cuda_enabled}"
    "-DTRACCC_USE_SYSTEM_ROCTHRUST=${rocm_enabled}"
    "-DVECMEM_BUILD_CUDA_LIBRARY=${cuda_enabled}"
    "-DVECMEM_BUILD_HIP_LIBRARY=${rocm_enabled}"
)

# Add CUDA args if enabled
[ -n $CUDA_ROOT ] && cmake_args+=(
    "-DCMAKE_CUDA_ARCHITECTURES=$(echo ${cuda_arch} | sed 's/ \+/;/g')"
    "-DCMAKE_CUDA_FLAGS=-Wno-deprecated-gpu-targets --threads 0"
)

# Add ROCm args if enabled
[ -n $ROCM_ROOT ] && cmake_args+=(
    "-DCMAKE_HIP_ARCHITECTURES=$(echo ${rocm_archs} | sed 's/ \+/;/g')"
    "-DAMDGPU_TARGETS=$(echo ${rocm_archs} | sed 's/ \+/;/g')"
)

# Add test args if enabled
[ "$build_test" = "1" ] && cmake_args+=(
    "-DACTS_BUILD_UNITTESTS=ON"
    "-DACTS_BUILD_INTEGRATIONTESTS=ON"
    "-DPython_EXECUTABLE=$(which python3)"
    "-DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON"
    "-DTRACCC_BUILD_TESTING=ON"
)

# Run CMake
cmake "${cmake_args[@]}" -L

make ${JOBS:+-j "$JOBS"}
make install VERBOSE=1

rm $INSTALLROOT/bin/this_acts.sh
rm $INSTALLROOT/bin/this_acts_withdeps.sh
rm $INSTALLROOT/python/setup.sh