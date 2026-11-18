package: pyquen
version: 1.5.4
sources:
 - https://github.com/akritkbehera/pyquen/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - pythia6
 - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake . -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE -DPYTHIA6_DIR=${PYTHIA6_ROOT} -DLHAPDF_ROOT_DIR=${LHAPDF_ROOT}
cmake --build . --clean-first -- ${JOBS:+-j $JOBS}
cmake --build . --target install --  ${JOBS:+-j $JOBS}
