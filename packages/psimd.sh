package: psimd
version: "v1"
tag: 072586a71b55b7f8c584153d223e95687148a900
sources: 
- https://github.com/Maratyszcza/psimd/archive/%(tag_basename)s.tar.gz
build_requires:
- gmake
- CMake
requires:
- gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

cmake -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
    -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE

make install
