package: yoda
version: "2.1.0"
tag: "yoda-2.1.0"
requires:
 - Python
 - gcc
 - ROOT
 - hdf5
 - highfive
 - zlib
 - openmpi
build_requires:
 - py-cython
 - autotools
source: https://gitlab.com/hepcedar/yoda.git
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
autoreconf -fiv
sed -i 's|/usr/bin/env python|/usr/bin/env python3|g' $(grep -rl '/usr/bin/env python' .)
PYTHON=$(which python3) ./configure --prefix=$INSTALLROOT --enable-root --with-highfive=${HIGHFIVE_ROOT} CXX="mpicxx"
make ${JOBS:+-j$JOBS}
make install
