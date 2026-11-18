package: setuptools
version: "82.0.0"
sources:
 - https://pypi.io/packages/source/s/setuptools/setuptools-%(version)s.tar.gz
requires:
 - Python
 - gcc
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf  ${SOURCEDIR}/${SOURCE0}
cd setuptools-${PKGVERSION}
python3 setup.py build
python3 setup.py egg_info
python3 setup.py install --single-version-externally-managed \
    --record=/dev/null --skip-build --prefix="$INSTALLROOT"
