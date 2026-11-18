package: mozsearch
version: "20251022"
variables:
 tag: 1c886cc95c4e811709e97f711d7691ff8b87bda9
 branch: master
 github_user: mozsearch
sources: 
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
patches:
 - mozsearch-gcc-toolchain.patch
 - mozsearch-clang21.patch
build_requires:
 - gmake
requires:
 - llvm
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0
patch -p1 <$SOURCEDIR/$PATCH1

cd clang-plugin
GCC_ROOT=${GCC_ROOT} make ${JOBS:+-j$JOBS} build

mkdir -p $INSTALLROOT/lib64
cp $BUILDDIR/clang-plugin/libclang-index-plugin.so $INSTALLROOT/lib64
