package: mctester
version: 1.25.1
sources:
 - https://gitlab.cern.ch/cvsmctst/mc-tester/-/archive/v%(version)s/mc-tester-v%(version)s.tar.gz
build_requires:
 - autotools
requires:
 - hepmc
 - ROOT
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

./configure \
  --with-HepMC=${HEPMC_ROOT} \
  --with-root=${ROOT_ROOT} \
  --prefix=$INSTALLROOT

make
make install

if [[ $(uname) == Darwin ]]; then
  find "$INSTALLROOT/lib" -name "*.dylib" -exec \
    install_name_tool -change '../lib/libHEPEvent.dylib' 'libHEPEvent.dylib' {} \;
fi
