package: lhapdf
version: 6.4.0
variables:
    setsversion: "6.5.1c"
sources:
 - http://www.hepforge.org/archive/lhapdf/LHAPDF-%(version)s.tar.gz
 - https://lhapdfsets.web.cern.ch/current/MSTW2008nlo68cl.tar.gz
 - file://lhapdf_makeLinks.file
 - file://lhapdf_pdfsetsindex.file
requires:
 - Python
 - gcc
 - py-cython
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

PYTHON=$(which python3) \
  ./configure --prefix=$INSTALLROOT \
  --enable-python

# Force Cython to regenerate lhapdf.cpp for Python 3.12 compatibility
touch wrappers/python/lhapdf.pyx

make all ${JOBS:+-j$JOBS}
make install

mkdir -p $INSTALLROOT/share/LHAPDF
tar -xzf "$SOURCEDIR/${SOURCE1}" \
    -C $INSTALLROOT/share/LHAPDF
cd $INSTALLROOT/share/LHAPDF
cp "$SOURCEDIR/${SOURCE2}" "$BUILDDIR/makeLinks"
chmod a+x "$BUILDDIR/makeLinks"
$BUILDDIR/makeLinks %(setsversion)s
rm -f pdsets.index
cp -f "$SOURCEDIR/${SOURCE3}" pdsets.index
cd -
find $INSTALLROOT -name '*.la' -exec rm -f {} \;
