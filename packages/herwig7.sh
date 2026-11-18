package: herwig7
version: 7.2.2
sources:
 - https://www.hepforge.org/archive/herwig/Herwig-%(version)s.tar.bz2
patches: 
 - herwig_Matchbox_mg_py3.patch
 - herwig7-fxfx-fix.patch
 - LHEEventNumFxFx.patch
 - herwig_MB.patch
build_requires:
 - autotools
requires:
 - lhapdf
 - boost
 - hepmc
 - yoda
 - thepeg
 - GSL
 - OpenBLAS
 - fastjet
 - gosamcontrib
 - gosam
 - madgraph5amcatnlo
 - Python
 - openloops
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
patch -p1 < "$SOURCEDIR/$PATCH2"
patch -p1 < "$SOURCEDIR/$PATCH3"

autoreconf -fiv

CXX="$(which g++) -fPIC -std=c++$CXXSTD"
CC="$(which gcc)  -fPIC -std=c++$CXXSTD"
PLATF_CONF_OPTS="--enable-shared --disable-static"
FCFLAGS=""
if [[ `gcc --version | head -1 | cut -d' ' -f3 | cut -d. -f1,2,3 | tr -d .` -gt 1000 ]] ; then FCFLAGS="-fallow-argument-mismatch" ; fi

if [ "$(uname -m)" != "x86_64" ]; then
  FCFLAGS="${FCFLAGS} -fno-range-check"
fi

sed -i -e "s|-lgslcblas|-lopenblas|" ./configure

PYTHON=python3 ./configure --prefix=$INSTALLROOT \
            --with-thepeg=$THEPEG_ROOT \
            --with-fastjet=$FASTJET_ROOT \
            --with-gsl=$GSL_ROOT \
            --with-boost=$BOOST_ROOT \
	    --with-madgraph=$MADGRAPH5AMCATNLO_ROOT \
            --with-gosam=$GOSAM_ROOT \
            --with-gosam-contrib=$GOSAMCONTRIB_ROOT \
            --with-hepmc=$HEPMC_ROOT \
            ${OPENLOOPS_ROOT+--with-openloops=$OPENLOOPS_ROOT} \
            $PLATF_CONF_OPTS \
            CXX="$CXX" CC="$CC" LDFLAGS="-L${OPENBLAS_ROOT}/lib" \
            FCFLAGS="$FCFLAGS"


make ${JOBS:+-j$JOBS} all V=1
export LHAPDF_DATA_PATH="$LHAPDF_ROOT/share/LHAPDF:$BUILDROOT/pdfsets"
make ${JOBS:+-j$JOBS} install LHAPDF_DATA_PATH=$LHAPDF_ROOT/share/LHAPDF

mv $INSTALLROOT/bin/Herwig  $INSTALLROOT/bin/Herwig-cms
cat <<HERWIG_WRAPPER > "$INSTALLROOT/bin/Herwig"
#!/bin/bash
REPO_OPT=""
if [ "$HERWIGPATH" != "" ] && [ -e "$HERWIGPATH/HerwigDefaults.rpo" ] ; then
  if [ $(echo " $@" | grep ' --repo' | wc -l) -eq 0 ] ; then REPO_OPT="--repo $HERWIGPATH/HerwigDefaults.rpo" ; fi
fi
$(dirname "$0")/Herwig-cms $REPO_OPT "$@"
HERWIG_WRAPPER
chmod +x $INSTALLROOT/bin/Herwig

sed -i -e 's|^#!.*python|#!/usr/bin/env python3|' $INSTALLROOT/bin/ufo2herwig $INSTALLROOT/bin/slha2herwig $INSTALLROOT/bin/herwig-mergegrids $INSTALLROOT/bin/gosam2herwig $INSTALLROOT/bin/mg2herwig
sed -i -e 's|^#!.*python|#!/usr/bin/env python3|' $INSTALLROOT/lib/Herwig/python/ufo2herwig $INSTALLROOT/lib/Herwig/python/slha2herwig
