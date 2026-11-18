package: madgraph5amcatnlo
version: 2.7.3
sources:
 - https://launchpad.net/mg5amcnlo/lts/2.7.x/+download/MG5_aMC_v%(version)s.py3.tar.gz
patches:
 - madgraph5amcatnlo-config.patch
 - madgraph5amcatnlo-py39.patch
 - madgraph5amcatnlo-py312.patch
variables:
 runpath_opts: "-m HEPTools -m basiceventgeneration"
 versiontag: "2_7_3"
requires:
 - autotools
 - Python
 - py-six
 - hepmc
 - ROOT
 - lhapdf
 - gosamcontrib
 - fastjet
 - pythia8
 - thepeg
 - collier 
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0
patch -p1 <$SOURCEDIR/$PATCH1
patch -p1 <$SOURCEDIR/$PATCH2

sed -i -e "s|\${HEPMC_ROOT}|${HEPMC_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|\${PYTHIA8_ROOT}|${PYTHIA8_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|\${LHAPDF_ROOT}|${LHAPDF_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|\${FASTJET_ROOT}|${FASTJET_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|\${GOSAMCONTRIB_ROOT}|${GOSAMCONTRIB_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|\${THEPEG_ROOT}|${THEPEG_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|\${COLLIER_ROOT}|${COLLIER_ROOT}|g" input/mg5_configuration.txt
sed -i -e "s|@MADGRAPH5AMCATNLO_ROOT@|$INSTALLROOT|g" input/mg5_configuration.txt
sed -i -e "s|SHFLAG = \-fPIC|SHFLAG = \-fPIC \-fcommon|g" vendor/StdHEP/src/stdhep_arch

export FC="$(which gfortran) -std=legacy"

cat <<EOF > basiceventgeneration.txt
generate p p > t t~ [QCD]
output basiceventgeneration
launch
set nevents 5
EOF
./bin/mg5_aMC ./basiceventgeneration.txt
rsync -avh $BUILDDIR/ $INSTALLROOT/
sed -ideleteme 's|#!.*/bin/python|#!/usr/bin/env python|' \
    $INSTALLROOT/Template/LO/bin/internal/addmasses_optional.py \
    $INSTALLROOT/madgraph/various/progressbar.py

find $INSTALLROOT -name '*deleteme' -delete
rm -f $INSTALLROOT/basiceventgeneration/*.log
rm -f $INSTALLROOT/basiceventgeneration/Source/StdHEP/log.mcfio.*
