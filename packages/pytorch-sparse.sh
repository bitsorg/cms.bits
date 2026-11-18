package:       pytorch-sparse
version:       0.6.18
variables:
  tag:         2d559810c6af7f8b2cf88553dd5a5824a667a07d
  branch:      master
  github_user: rusty1s
sources:
 - git+https://github.com/%(github_user)s/pytorch_sparse.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
build_requires:
 - CMake
requires:
 - py-torch
 - cuda
 - cuda-flags
 - gcc
---
export build_flags="-Wall -Wextra -pedantic $arch_build_flags"
export cuda_arch_float="$(echo "$cuda_arch" | tr ' ' '\n' | sed -E 's|([0-9])$|.\1|' | tr '\n' ' ')"

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q 'CMAKE_CXX_STANDARD  *14' CMakeLists.txt
sed -i -e "s|CMAKE_CXX_STANDARD  *14|CMAKE_CXX_STANDARD ${CXXSTD}|" CMakeLists.txt

rm -rf ../build && mkdir ../build && cd ../build

cmake_args=(
  "$BUILDDIR"
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_INSTALL_LIBDIR=lib
  -DCMAKE_PREFIX_PATH="${GCC_ROOT};${PYTORCH_ROOT};${CUDA_ROOT}"
  -DCMAKE_CXX_STANDARD="${CXXSTD}"
  -DCMAKE_CXX_FLAGS="$build_flags"
  -DBUILD_TEST=OFF
  -DWITH_PYTHON=OFF
  -DBUILD_SHARED_LIBS=ON
)

if [[ "$USE_CUDA" -eq 1 ]]; then
  cmake_args+=(
    -DWITH_CUDA=ON
    -DTORCH_CUDA_ARCH_LIST="${cuda_arch_float}"
    -Dnvtx3_dir="${CUDA_ROOT}/include"
  )
fi

cmake "${cmake_args[@]}"

make ${JOBS:+-j$JOBS} VERBOSE=1
make ${JOBS:+-j$JOBS} install VERBOSE=1
