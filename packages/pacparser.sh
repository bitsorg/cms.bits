package: pacparser
version: 1.4.5
sources:
 - https://github.com/manugarg/pacparser/archive/refs/tags/v%(version)s.tar.gz
patches:
 - pacparser-gcc14.patch
requires:
 - Python
 - gcc
 - pip
build_requires:
 - setuptools
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -s -i "$SOURCEDIR/$PATCH0"

make -C src all pymod \
  PREFIX=$INSTALLROOT \
  PYTHON=$(which python3)

make -C src install \
  PREFIX=$INSTALLROOT

$(which python3) -m pip install src/pymod/ \
  --prefix=$INSTALLROOT \
  --no-build-isolation

find $INSTALLROOT/lib -type f | xargs chmod 0755
