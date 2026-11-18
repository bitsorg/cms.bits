package: hydjet
version: 1.9.3
sources:
 - https://github.com/akritkbehera/hydjet/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - pyquen
 - pythia6
 - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake . -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE -DPYQUEN_DIR=${PYQUEN_ROOT} -DPYTHIA6_DIR=${PYTHIA6_ROOT} -DLHAPDF_ROOT_DIR=${LHAPDF_ROOT}
cmake --build . --clean-first -- ${JOBS:+-j$JOBS}

cmake --build . --target install --  ${JOBS:+-j$JOBS}
