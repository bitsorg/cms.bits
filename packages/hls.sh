package: hls
version: "2025.05"
variables:
 tag: a3c0b0b444984aadba245a3b1fdffacaccea3141
 branch: cms/200a9ae
 github_user: cms-externals
 runpath_opts: -m examples
sources:
 - git+https://github.com/%(github_user)s/HLS_arbitrary_Precision_Types.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

pushd examples/ap_fixed > /dev/null
make
mv a.out ../ap_fixed.exe
popd > /dev/null
pushd examples/ap_int > /dev/null
make
mv a.out ../ap_int.exe
popd > /dev/null
rm -rf examples/ap_int examples/ap_fixed

cp -r * $INSTALLROOT/
