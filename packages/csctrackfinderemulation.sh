package: CSCTrackFinderEmulation
version: "1.2"
variables:
 tag: 8c0287fde4739d96fd3fd4a03e5ce5e6b986052e
 branch: cms/CMSSW_8_1_X
 github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS}
make install
cp -r installDir/* $INSTALLROOT/
