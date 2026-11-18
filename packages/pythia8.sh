package: pythia8
version: "311"
sources:
 - https://pythia.org/download/pythia83/%(package)s%(version)s.tgz
requires:
 - gcc
 - hepmc
 - hepmc3
 - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure --prefix=$INSTALLROOT \
            --with-hepmc2=$HEPMC_ROOT \
            --with-hepmc3=$HEPMC3_ROOT \
            --with-lhapdf6=$LHAPDF_ROOT \
            --enable-shared \
            --enable-mg5mes
make ${JOBS:+-j$JOBS}
make install
test -f $INSTALLROOT/lib/libpythia8lhapdf6.so || exit 1
rm -rf $INSTALLROOT/share/Pythia8/examples