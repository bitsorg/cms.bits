package: openloops-sources
version: 2.1.2
variables:
  branch: cms/v%%(version)s
  github_user: cms-externals
  tag: 4247179369144b0134c7b8014a5d38a90dc9b6ba
  process_src: process_src.tgz
sources:
 - https://github.com/akritkbehera/openloops/archive/refs/tags/%(version)s.tar.gz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/master/openloops-user.coll.file
patches:
 - openloops-urlopen2curl.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"
cp $SOURCEDIR/$SOURCE1 .
cd openloops-2.1.2
patch -p1 -i "$SOURCEDIR/$PATCH0"
python pyol/bin/download_process.py $(cat $BUILDDIR/openloops-user.coll.file | tr '\n' ' ')
tar -czf %(process_src)s process_src proclib
rm -rf process_src proclib
mv %(process_src)s $INSTALLROOT/
cp $BUILDDIR/openloops-user.coll.file $INSTALLROOT/
mkdir -p $INSTALLROOT/openloops_source/
rsync -a $BUILDDIR/openloops-2.1.2/ $INSTALLROOT/openloops_source/
