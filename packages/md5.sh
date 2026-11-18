package: md5
version: 1.0.0
variables:
  tag: d97a571864a119cd5408d2670d095b4410e926cc
  branch: cms/%(version)s
  github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

if [ "$(uname)" == "Darwin" ]; then
  gcc md5.c -shared -fPIC -o libcms-md5.dylib
else
  gcc md5.c -shared -fPIC -o libcms-md5.so
fi

mkdir -p $INSTALLROOT/lib $INSTALLROOT/include
cp $BUILDDIR/libcms-md5.* $INSTALLROOT/lib/
cp $BUILDDIR/md5.h $INSTALLROOT/include/