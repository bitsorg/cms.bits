package: fftjet
version: 1.5.0
sources:
 - http://www.hepforge.org/archive/fftjet/%(package)s-%(version)s.tar.gz
requires:
 - gcc
 - FFTW3
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

PLATF_CONF_OPTS="--enable-static --disable-shared"
F77="$(which gfortran) -fPIC"
CXX="$(which g++) -fPIC"
CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/config"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
    ls -la "$TMPDIR"/config.{guess,sub}
else
    exit 1
fi
touch pkg-config ; chmod +x pkg-config

configure_args=(
  $PLATF_CONF_OPTS
  --prefix="$INSTALLROOT"
  --disable-dependency-tracking
  --enable-threads
  F77="$F77"
  CXX="$CXX"
  DEPS_CFLAGS="-I$FFTW3_ROOT/include"
  DEPS_LIBS="-L$FFTW3_ROOT/lib -lfftw3" 
  PKG_CONFIG=$PWD/pkg-config
  )
if [[ -z $arch_build_flags ]]; then
  configure_args+=(
    CXXFLAGS="-O2"
    )
else
  configure_args+=(
    CXXFLAGS="$arch_build_flags -O2"
    )
fi

./configure "${configure_args[@]}"
make ${JOBS:+-j$JOBS}
make install
