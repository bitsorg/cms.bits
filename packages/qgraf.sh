package: qgraf
version: 3.4.2
sources:
 - https://herwig.hepforge.org/downloads?f=mirror/qgraf-%(version)s.tgz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
FC="$(which gfortran)"
${FC} qgraf*.f -o qgraf -O2
mkdir $INSTALLROOT/bin
cp qgraf $INSTALLROOT/bin
