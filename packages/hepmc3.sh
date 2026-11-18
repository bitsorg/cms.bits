package: hepmc3
version: "3.2.7"
sources:
 - https://gitlab.cern.ch/hepmc/HepMC3/-/archive/%(version)s/HepMC3-%(version)s.tar.gz
build_requires:
  - CMake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build && mkdir ../build && cd ../build

cmake $BUILDDIR \
  -DHEPMC3_ENABLE_ROOTIO:BOOL=OFF -DHEPMC3_ENABLE_TEST:BOOL=OFF \
  -DHEPMC3_INSTALL_INTERFACES:BOOL=ON -DHEPMC3_ENABLE_PYTHON:BOOL=OFF \
  -DHEPMC3_BUILD_STATIC_LIBS:BOOL=OFF -DHEPMC3_BUILD_DOCS:BOOL=OFF \
  -DCMAKE_CXX_STANDARD=$CXXSTD -DHEPMC3_CXX_STANDARD=$CXXSTD \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT

make ${JOBS:+-j $JOBS}
make install
