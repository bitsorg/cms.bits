package: onnxruntime
version: 1.25.1
variables:
 tag: v%(version)s
 branch: main
 github_user: microsoft
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
patches:
 - cms-changes-onnxruntime.patch
build_requires:
 - CMake
 - ninja
requires:
 - gcc
 - protobuf
 - py-numpy
 - py-onnx
 - zlib
 - libpng
 - py-pybind11
 - re2
 - eigen
 - cuda
 - cudnn
 - cuda-flags
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

USE_CUDA=OFF
if [ "${cuda_gcc_support}" = "true" ]; then
  USE_CUDA=ON
fi

rm -rf $BUILDROOT/build && mkdir -p $BUILDROOT/build && cd $BUILDROOT/build

cmake_args=(
  -G Ninja
  -Wno-dev
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT
  -DCMAKE_INSTALL_LIBDIR=lib
  -Donnxruntime_ENABLE_PYTHON=ON
  -Donnxruntime_BUILD_SHARED_LIB=ON
  -Donnxruntime_USE_CUDA=${USE_CUDA}
  -Donnxruntime_BUILD_CSHARP=OFF
  -Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF
  -Donnxruntime_USE_TENSORRT=OFF
  -Donnxruntime_CROSS_COMPILING=OFF
  -Donnxruntime_USE_FULL_PROTOBUF=ON
  -Donnxruntime_DISABLE_CONTRIB_OPS=OFF
  -Donnxruntime_BUILD_UNIT_TESTS=OFF
  -DCMAKE_PREFIX_PATH="${ZLIB_ROOT};${LIBPNG_ROOT};${PROTOBUF_ROOT};${PY3_PYBIND11_ROOT};${RE2_ROOT};${EIGEN_ROOT}"
  -DCMAKE_CXX_FLAGS="-Wno-error=stringop-overflow -Wno-error=maybe-uninitialized -Wno-error=overloaded-virtual -Wno-error=cpp"
)

if [[ "${USE_CUDA}" == "ON" ]]; then
  cmake_args+=(
    -Donnxruntime_CUDA_HOME="${CUDA_ROOT}"
    -Donnxruntime_CUDNN_HOME="${CUDNN_ROOT}"
    -Donnxruntime_NVCC_THREADS=1
    -DCMAKE_CUDA_ARCHITECTURES=$(echo ${cuda_arch} | tr ' ' ';' | sed 's|;;*|;|')
    -DCMAKE_CUDA_FLAGS="-DTHRUST_IGNORE_DEPRECATED_API -DCUB_IGNORE_DEPRECATED_API -Wno-deprecated-gpu-targets --static-global-template-stub=false -cudart shared"
    -DCMAKE_CUDA_RUNTIME_LIBRARY=Shared
    -DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES="CMAKE_CUDA_RUNTIME_LIBRARY"
  )
fi

cmake "${cmake_args[@]}" $BUILDDIR/cmake
ninja -v ${JOBS:+-j$JOBS}
python3 $BUILDDIR/setup.py build

ninja -v ${JOBS:+-j$JOBS} install
mkdir -p $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}
mv build/lib/onnxruntime $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/
