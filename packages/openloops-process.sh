package: openloops-process
version: 2.1.2
variables:
  branch: cms/v%%(version)s
  github_user: cms-externals
  tag: 4247179369144b0134c7b8014a5d38a90dc9b6ba
  process_src: process_src.tgz
sources:
 - git+https://github.com/%(github_user)s/openloops.git?obj=%(branch)s/%(tag)s&export=openloops-%(version)s&output=/openloops-%(version)s-%(tag)s.tgz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/master/openloops-user.coll.file
patches:
 - openloops-urlopen2curl.patch
requires:
 - Python
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"

cd "$BUILDDIR/openloops-%(version)s"
patch -p1 < "$SOURCEDIR/$PATCH0"

sed -i 's/SafeConfigParser/RawConfigParser/g' pyol/tools/OLBaseConfig.py
sed -i 's/SafeConfigParser/RawConfigParser/g; s/\.readfp(/.read_file(/g' pyol/tools/OLBaseConfig.py

python3 pyol/bin/download_process.py $(cat "$SOURCEDIR/$SOURCE1" | tr '\n' ' ')
tar -czf "%(process_src)s" process_src proclib
mv "%(process_src)s" "$INSTALLROOT/"
