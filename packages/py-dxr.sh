package: py-dxr
version: "1.0"
variables:
  tag: b55cf0eeacc494adc575562eac290b3e4871a6ac
  branch: cms/clang21
  github_user: cms-externals
sources:
  - git+https://github.com/%(github_user)s/dxr.git?obj=%(branch)s/%(tag)s&export=dxr-%(tag)s&output=/dxr-%(tag)s.tgz
build_requires:
  - gmake
requires:
  - gcc
  - zlib
  - llvm
  - sqlite
  - py-Jinja2
  - py-parsimonious
  - py-pysqlite3
  - py-Pygments
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
LDFLAGS="-L${ZLIB_ROOT}/lib" make ${JOBS:+-j$JOBS}
make ${JOBS:+-j$JOBS} install PREFIX="$INSTALLROOT"

# Fix python shebangs
find "$INSTALLROOT/bin" -name "*.py" \
    -exec sed -i 's|^#!.*|#!/usr/bin/env python3|' {} +
