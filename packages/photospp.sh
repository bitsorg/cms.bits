package: photospp
version: "3.64"
tag: v%(version)s
requires:
 - hepmc
 - hepmc3
 - gcc
source: https://gitlab.cern.ch/photospp/photospp.git
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

rm -f ./config.{sub,guess}

./configure --prefix=$INSTALLROOT --with-hepmc=${HEPMC_ROOT} --with-hepmc3=$HEPMC3_ROOT

if [[ $(uname) == "Darwin" ]]; then
  perl -p -i -e "s|-shared|-dynamiclib -undefined dynamic_lookup|" make.inc
fi

make
make install ${JOBS:+-j$JOBS}
ls $INSTALLROOT/lib/
