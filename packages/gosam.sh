package: gosam
version: 2.1.0
variables:
  branch: master
  github_user: gudrunhe
sources:
  - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(version)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
requires:
  - qgraf
  - form
  - gosamcontrib
  - Python
  - py-cython
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q '^VERSION *=' setup.py && grep -q '^GIT_REVISION *=' setup.py && grep -q '^TAR_VERSION *=' setup.py

sed -i -r -e "s#^VERSION *=.*#VERSION = \"$PKGVERSION\"#" setup.py
sed -i -r -e "s#^GIT_REVISION *=.*#GIT_REVISION = \"$PKGVERSION\"#" setup.py
sed -i -r -e "s#^TAR_VERSION *=.*#TAR_VERSION = \"$PKGVERSION\"#" setup.py

CXX="$(which c++) -fPIC"
CC="$(which gcc) -fPIC"
FC="$(which gfortran)"
PLATF_CONF_OPTS="--enable-shared --disable-static"
python3 setup.py install --prefix=$INSTALLROOT

perl -p -i -e "s|^#!.*python.*|#!/usr/bin/env python3|" $(grep -r -e "^#\!.*python.*" $INSTALLROOT | cut -d: -f1)
find $INSTALLROOT/lib -name '*.la' -exec rm -f {} \;
