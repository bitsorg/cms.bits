package: mcfm
version: "6.3"
variables:
  tag: "d2e025ce8044976b95811b1a92e802f5e4eeb5ae"
  branch: "cms/%%(version)s"
  github_user: "cms-externals"
sources: 
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s
patches:
 - mcfm-6.3-opt-for-size.patch
requires:
 - ROOT
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

if [[ $(uname -m) =~ ^aarch.*$ ]]; then
    patch -p1 < "$SOURCEDIR/$PATCH0"
fi

mkdir -p $BUILDDIR/obj
pushd QCDLoop
	make FC="$(which gfortran) -std=legacy"
popd
make FC="$(which gfortran) -std=legacy"

mv $BUILDDIR/Bin $BUILDDIR/bin

mkdir -p $BUILDDIR/lib
ar cr $BUILDDIR/lib/libMCFM.a $BUILDDIR/obj/*.o

rm $BUILDDIR/bin/mcfm

cp -r $BUILDDIR/lib $INSTALLROOT
cp -r $BUILDDIR/bin $INSTALLROOT
