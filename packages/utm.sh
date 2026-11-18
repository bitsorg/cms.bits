package: utm
version: "%(tag_basename)s"
tag: "utm_0.13.0"
build_requires:
- gmake
requires:
- xerces-c
- boost
- gcc
source: https://gitlab.cern.ch/cms-l1t-utm/utm
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

export XERCES_C_BASE=${XERCES_C_ROOT}
export BOOST_BASE=${BOOST_ROOT}
./configure

make ${JOBS:+-j $JOBS} all

make ${JOBS:+-j $JOBS} install
cp -r lib $INSTALLROOT/lib
cp -r include $INSTALLROOT/include
cp -r xsd-type $INSTALLROOT/xsd-type
cp -r menu.xsd $INSTALLROOT/menu.xsd
