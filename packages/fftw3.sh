package: FFTW3
version: "%(tag_basename)s"
tag: v3.3.9
source: https://github.com/alisw/fftw3
build_requires:
  - CMake
  - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

CONFIG_ARGS="--enable-maintainer-mode --with-pic --enable-shared --enable-threads --disable-fortran
             --disable-dependency-tracking --disable-mpi --disable-openmp --disable-doc
             --prefix=${INSTALLROOT}"

if [ "$(uname -m)" = "x86_64" ]; then
  CONFIG_ARGS="${CONFIG_ARGS} --enable-sse2"
fi

sh bootstrap.sh
./configure ${CONFIG_ARGS}
make ${JOBS:+-j$JOBS}
make install