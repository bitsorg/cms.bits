package: professor2
version: 2.4.2
sources:
  - git+https://gitlab.com/hepcedar/professor.git?obj=main/professor-%(version)s&export=professor-%(version)s&output=/professor-%(version)s.tgz
patches:
  - professor2-ppc64-flag-change.patch
requires:
  - py-matplotlib
  - ROOT
  - yoda
  - eigen
  - py-iminuit
  - setuptools
  - gcc
build_requires:
  - py-cython
  - pip
env:
  PYTHON3_LIB_SITE_PACKAGES: "lib/python$(echo $PYTHON_VERSION | cut -d. -f1,2 | sed 's|^v||')/site-packages"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

ARCH=$(uname -m)

if [[ "$ARCH" == "ppc64le" ]]; then
    patch -p1 < "$PATCH0"
fi

if [[ "$ARCH" == "riscv64" ]]; then
    sed -i -e 's|-march=native||' Makefile
fi

grep -q 'std=c[+][+]11' pyext/setup.py
sed -i -e "s|-std=c[+][+]11|-std=c++$CXXSTD|" pyext/setup.py
grep -q 'CXXSTD := c[+][+]11' Makefile
sed -i -e "s|CXXSTD := c[+][+]11|CXXSTD := c++$CXXSTD|" Makefile
sed -i -e "s|pip install -vv|pip install --no-build-isolation --target ../${PYTHON3_LIB_SITE_PACKAGES} -vv|" Makefile

for i in `ls bin`
do
   echo "bin/${i}"
   sed -i -e 's|/usr/bin/env python|/usr/bin/env python3|' "bin/${i}"
done

export build_flags="CPPFLAGS=-I${EIGEN_ROOT}/include/eigen3 PYTHON=$(which python3) PROF_VERSION=$PKG_VERSION PYTHONPATH=./${PYTHON3_LIB_SITE_PACKAGES}:./pyext/professor2:${PYTHON3PATH}"

make PREFIX="$INSTALLROOT" $build_flags
make install PREFIX="$INSTALLROOT" $build_flags

#mv $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/$PKGNAME-$PKG_VERSION*.dist* $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/$PKGNAME
rm -f $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/*.pth
