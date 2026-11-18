package: jemalloc
version: 5.3.0
variables:
  github_user: cms-externals
  branch: cms/%%(version)s
  tag: 54eaed1d8b56b1aa528be3bdd1877e59c56fa90c
sources: 
 - git+https://github.com/%(github_user)s/jemalloc.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - autotools
 - gmake
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

args=(
  --prefix="$INSTALLROOT"
  --disable-doc
  --enable-shared
  --disable-static
  --enable-stats
)
if [[ "$(uname -m)" == "aarch64" ]]; then
  args+=(--with-lg-page=16)
  args+=(--with-lg-hugepage=24)
fi
$BUILDDIR/autogen.sh "${args[@]}"

make ${JOBS:+-j$JOBS}
make install

#mv $INSTALLROOT/lib/libjemalloc.so.2 $INSTALLROOT/lib/lib${PKGNAME}.so.2
#rm $INSTALLROOT/lib/libjemalloc.so
ln -sf $INSTALLROOT/lib$PKGNAME.so.2 $INSTALLROOT/lib/lib$PKGNAME.so
patchelf --set-soname lib$PKGNAME.so.2 $INSTALLROOT/lib/lib$PKGNAME.so.2
# We make sure there are no other libs. 
# If there are then we should fail and update the recipe
if [ $(ls $INSTALLROOT/lib/lib* | grep -v lib$PKGNAME. | wc -l) -gt 0 ] ; then exit 1; fi
