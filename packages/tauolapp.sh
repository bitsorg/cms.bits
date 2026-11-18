package: tauolapp
version: "1.1.8"
sources:
 - http://tauolapp.web.cern.ch/tauolapp/resources/TAUOLA.%(version)s/TAUOLA.%(version)s-LHC.tar.gz
requires:
  - hepmc
  - gcc
  - pythia8
  - boost
  - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

export HEPMCLOCATION=${HEPMC_ROOT}
export HEPMCVERSION=${HEPMC_VERSION}
export LHAPDF_LOCATION=${LHAPDF_ROOT}
export PYTHIA8_LOCATION=${PYTHIA8_ROOT}

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/config"
rm -f "$TMPDIR"/config.{sub,guess}

curl -L -k -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
chmod +x "$TMPDIR"/config.{sub,guess}

./configure --prefix=$INSTALLROOT --without-hepmc3 --with-hepmc=$HEPMC_ROOT --with-pythia8=$PYTHIA8_ROOT --with-lhapdf=$LHAPDF_ROOT CPPFLAGS="-I${BOOST_ROOT}/include"

make
make install

mkdir -p $INSTALLROOT/share
cp TauSpinner/examples/CP-tests/Z-pi/*.txt $INSTALLROOT/share/