package: clang-uml
version: 0.6.2
variables:
  tag: 5e2993e75ebc88af6cb239f2ffae88da7431cb0d
  branch: master
  github_user: bkryza
sources:
  - git+https://github.com/%(github_user)s/clang-uml.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
patches:
  - clang-uml-clang21.patch
  - clang-uml-yamlcpp.patch
build_requires:
  - CMake
  - ninja
requires:
  - gcc
  - yaml-cpp
  - llvm
  - zlib
  - zstd
  - libxml2
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"

cmake_args=(
    -G Ninja
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=Release
    -DGIT_VERSION="%(version)s"
    -DCMAKE_PREFIX_PATH="${YAML_CPP_ROOT};${ZLIB_ROOT}"
    -DBUILD_TESTING=OFF
)
if [ "$(uname -m)" = "aarch64" ]; then
    cmake_args+=(-DCMAKE_CXX_FLAGS="-Wno-sign-compare")
fi
cmake "${cmake_args[@]}"
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS}
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS} install
