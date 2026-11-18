package: opencv
version: 4.9.0
variables:
  branch: master
  github_user: opencv
  override_microarch: ""
  package_vectorization: ""
sources:
- git+https://github.com/%(github_user)s/opencv.git?obj=%(branch)s/%(version)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(version)s.tgz
build_requires:
- CMake
- ninja
requires:
- gcc
- Python
- py-numpy
- libpng
- libjpeg-turbo
- libtiff
- zlib
- eigen
- OpenBLAS
---
export CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"

if [ "$(uname -m)" = "aarch64" ]; then
  export CMS_EIGEN_CXX_FLAGS="-DEIGEN_NEON_GEBP_NR=4 ${CMS_EIGEN_CXX_FLAGS}"
fi

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

mkdir $BUILDROOT/build
cd $BUILDROOT/build

cmake_args=(
  -G Ninja \
  -DCMAKE_CXX_STANDARD=$CXXSTD \
  -DCLHEP_BUILD_CXXSTD="-std=c++$CXXSTD" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DWITH_EIGEN=ON \
  -DWITH_EXAMPLES=OFF \
  -DWITH_QT=OFF \
  -DWITH_GTK=OFF \
  -DPYTHON3_EXECUTABLE:FILEPATH="${PYTHON_ROOT}/bin/python3" \
  -DPYTHON3_INCLUDE_DIR:PATH="${PYTHON_ROOT}/include/python3.12/" \
  -DPYTHON3_LIBRARY:FILEPATH="${PYTHON_ROOT}/lib/libpython3.12.so" \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_CXX_FLAGS="$CMS_EIGEN_CXX_FLAGS $default_microarch_name"\
  -DCMAKE_PREFIX_PATH="${PYTHON_ROOT};${LIBPNG_ROOT};${LIBTIFF_ROOT};${LIBJPEG_TURBO_ROOT};${ZLIB_ROOT};${PYTHON3_ROOT};${PY2_NUMPY_ROOT};${PY3_NUMPY_ROOT};${EIGEN_ROOT};${OPENBLAS_ROOT}"
)

cmake "${cmake_args[@]}" $BUILDDIR

ninja -v ${JOBS:+-j$JOBS} 
ninja install
