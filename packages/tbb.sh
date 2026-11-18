package: TBB
version: "%(tag_basename)s"
tag: v2022.0.0
source: https://github.com/uxlfoundation/oneTBB
requires:
  - gcc
  - CMake
  - hwloc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_FLAGS="-Wno-error=array-bounds -Wno-error=use-after-free -Wno-error=address -Wno-error=uninitialized -Wno-error=stringop-overflow" \
      -DCMAKE_INSTALL_PREFIX=${INSTALLROOT} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DHWLOC_ROOT=$HWLOC_ROOT \
      -DHWLOC_INCLUDE_DIR=$HWLOC_ROOT/include \
      -DHWLOC_LIBRARY=$HWLOC_ROOT/lib/libhwloc.so \
      -DTBB_CPF=ON \
      -DTBB_TEST=OFF

make ${JOBS:+-j$JOBS}
make install