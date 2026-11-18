package: xgboost
version: "%(tag_basename)s"
tag: 1.7.5
sources: 
- https://github.com/dmlc/xgboost/releases/download/v%(tag_basename)s/xgboost.tar.gz
build_requires:
- CMake
patches:
- xgboost-arm-and-ppc.patch
requires:
- gcc
---
ARCH="$(uname -m)"
mkdir -p $BUILDDIR/$PKGNAME-$PKGVERSION
tar -xzf "$SOURCEDIR"/$SOURCE0 \
    --strip-components=1 \
    -C "$BUILDDIR/$PKGNAME-$PKGVERSION"


pushd "$BUILDDIR/$PKGNAME-$PKGVERSION"
if [[ "$ARCH" == "x86_64" && -f "$SOURCEDIR/$PATCH0" ]]; then
    patch -p1 < "$SOURCEDIR/$PATCH0"
fi
popd

CMAKE_ARGS=(
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DUSE_CUDA=OFF
)

cmake "${CMAKE_ARGS[@]}" "$BUILDDIR/$PKGNAME-$PKGVERSION" 
make ${JOBS:+-j$JOBS}
make install
