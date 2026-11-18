package: blackhat
version: "0.9.9"
variables:
  branch: cms/v%%(version)s
  github_user: cms-externals
  tag: 3e8ac1f06ef3612088505de448c8e127157076a7
sources: 
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
patches:
 - blackhat.patch
requires:
 - qd
 - Python
 - gcc
 - py-disutils
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i -e 's|else return Cached_OLHA_user_normal|else return new Cached_OLHA_user_normal|' src/cached_OLHA.cpp

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
CONFIGDIR="$BUILDDIR"

rm -f "$CONFIGDIR"/config.{sub,guess}
curl -L -k -o "$CONFIGDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -o "$CONFIGDIR"/config.sub "$CONFIG_SUB_URL"
chmod +x "$CONFIGDIR"/config.{sub,guess}

PYTHON=$(which python3) ./configure --prefix=$INSTALLROOT \
  --with-QDpath=$QD_ROOT \
  --enable-pythoninterface=no \
  CXXFLAGS="-Wno-deprecated" \
  LDFLAGS="-L${PYTHON_ROOT}/lib"

make ${JOBS:+-j $JOBS}
make install
