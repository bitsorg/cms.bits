package: re2
version: "2021_06_01"
tag: "2021-06-01"
source: https://github.com/google/re2/
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$LLMV_BUILD_TYPE \
  -DBUILD_SHARED_LIBS=True \
  -DCMAKE_POSITION_INDEPENDENT_CODE=True \
  -DCMAKE_INSTALL_LIBDIR=lib

make VERBOSE=1 ${JOBS:+-j$JOBS} install
