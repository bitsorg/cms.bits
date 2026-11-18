package: pythia6
version: "426"
sources:
 - http://cern.ch/service-spi/external/MCGenerators/distribution/%(package)s/%(package)s-%(version)s-src.tgz
patches:
 - pythia6-gcc14.patch
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR" 

pushd $BUILDDIR/$PKGNAME/$PKGVERSION
  patch -p1 <$SOURCEDIR/$PATCH0
popd 

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/$PKGNAME/$PKGVERSION/config"
cd $TMPDIR
rm -f "$TMPDIR"/config.{sub,guess}

curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"

cd "$BUILDDIR/$PKGNAME/$PKGVERSION"
  ./configure \
    --disable-shared \
    --enable-static \
    --with-hepevt=4000 \
    --prefix="$INSTALLROOT" \
    F77="$(which gfortran)" FFLAGS="-fPIC"
perl -p -i -e 's|^CC=.*$|CC="gcc -fPIC"|' libtool

make ${JOBS:+-j$JOBS} CFLAGS="-fPIC -fcommon"
make install
