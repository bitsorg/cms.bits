package: hydjet2
version: 2.4.4
sources:
 - https://github.com/akritkbehera/hydjet/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - ROOT
 - gcc
 - pyquen
 - pythia6
 - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake . -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE -DPYQUEN_DIR=${PYQUEN_ROOT} -DPYTHIA6_DIR=${PYTHIA6_ROOT} -DLHAPDF_ROOT_DIR=${LHAPDF_ROOT} -DROOTSYS=${ROOT_ROOT}
cmake --build . --clean-first --  ${JOBS:+-j$JOBS}

cmake --build . --target install --  ${JOBS:+-j$JOBS}
