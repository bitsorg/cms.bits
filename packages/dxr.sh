package: dxr
version: 1.0.x
variables:
  dxrCommit: 737d3b0570e5e4a7845e8cba7c0b000d2911f24e
  branch: cms/6ea764102a/clang18
sources:
 - git+https://github.com/cms-externals/dxr.git?obj=%(branch)s/%(dxrCommit)s&export=dxr-%(dxrCommit)s&module=dxr-%(dxrCommit)s&output=/dxr-%(dxrCommit)s.tgz
requires:
 - gcc
 - zlib
 - llvm
 - sqlite
 - py-Jinja2
 - py-parsimonious
 - py-pysqlite3
 - py-Pygments
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

export SQLITE_ROOT
LDFLAGS="-L${ZLIB_ROOT}/lib" make  ${JOBS:+-j$JOBS}

make  ${JOBS:+-j$JOBS} install PREFIX=$INSTALLROOT
perl -p -i -e "s|^#!$BITS_WORK_DIR/.*|#!/usr/bin/env python3|" $INSTALLROOT/bin/*.py
