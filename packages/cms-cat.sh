package: cms-cat
version: "250627.0"
variables: 
  commit: 5cf28195a12d7c98bfccdb36a5fffa7b36247af5
  branch: master
  fakerevision: "shell(echo %(version)s | cut -d. -f1)"
sources:
  - git://gitlab.cern.ch/cms-analysis/services/cms.cern.ch-cat.git?obj=%(branch)s/%(commit)s&export=cms-cat&output=/cms-cat-%(commit)s.tgz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p $INSTALLROOT/cat
mv * $INSTALLROOT/cat
