package: tensorflow-xla-runtime
version: 2.17.0
build_requires:
 - CMake
patches:
 - tensorflow-xla-runtime-absl.patch
requires:
 - gcc
 - Python
 - eigen
 - tensorflow
 - abseil-cpp
---
case "$TENSORFLOW_VERSION" in
  $PKG_VERSION|${PKG_VERSION}-*) ;;
  *) echo "ERROR: Mismatch tensorflow-xla-runtime ($PKG_VERSION) and tensorflow ($TENSORFLOW_VERSION) versions."
     exit 1 ;;
esac

rsync -a --no-o --no-g "$TENSORFLOW_ROOT/xla-aot-runtime/" ./xla-aot-runtime/
patch -p1 < "$SOURCEDIR/$PATCH0"

export CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"
if [ "$(uname -m)" == "aarch64" ]; then
  export CMS_EIGEN_CXX_FLAGS="-DEIGEN_NEON_GEBP_NR=4 ${CMS_EIGEN_CXX_FLAGS}"
fi

export CPATH="${CPATH}:${EIGEN_ROOT}/include/eigen3"
CXXFLAGS="-fPIC -Wl,-z,defs ${arch_build_flags} ${CMS_EIGEN_CXX_FLAGS} ${selected_microarch}"

pushd xla-aot-runtime/src
  find . -type f -path '*/service/cpu/runtime_fork_join.cc' | xargs rm -f

  cmake . \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -I${TENSORFLOW_ROOT}/include" \
    -DCMAKE_CXX_STANDARD="${CXXSTD}" \
    -DCMAKE_PREFIX_PATH="${ABSEIL_CPP_ROOT}" \
    -DCMAKE_SHARED_LINKER_FLAGS="-L../lib -Wl,--whole-archive -l:libfft_wrapper.pic.a -Wl,--no-whole-archive -l:libfft.pic.a -l:libmutex.pic.a -l:libnsync_cpp.pic.a" \
    -DBUILD_SHARED_LIBS=ON

  make ${JOBS:+-j$JOBS}
popd

mkdir -p "$INSTALLROOT/lib"
mv xla-aot-runtime/src/libtf_xla_runtime.so "$INSTALLROOT/lib/"
