package: fastjet-contrib
version: "1.101"
variables:
  tag: 079bab22b9d4852c6a2f868b86a559f3f871f648
  branch: cms/v"%%(version)s"
  github_user: cms-externals
sources:
- git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
requires:
 - gcc
 - fastjet
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure --prefix=$INSTALLROOT --fastjet-config=${FASTJET_ROOT}/bin/fastjet-config CXXFLAGS="-I${FASTJET_ROOT}/include"

make
make check
make install
make fragile-shared
make fragile-shared-install
find $INSTALLROOT/lib -type f | xargs chmod 0755
