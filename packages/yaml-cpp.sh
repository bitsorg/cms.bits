package: yaml-cpp
version: "v%(tag_basename)s"
tag: "0.8.0"
build_requires:
- CMake
- ninja
requires:
- gcc
sources:
- https://github.com/jbeder/yaml-cpp/archive/refs/tags/%(tag_basename)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

rm -rf build
mkdir build
cd build

cmake \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DYAML_BUILD_SHARED_LIBS=ON \
  -DYAML_CPP_BUILD_TESTS=OFF \
  ..

ninja -v ${JOBS:+-j$JOBS} 
ninja install
