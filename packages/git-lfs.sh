package: git-lfs
version: 3.6.0
tag: v%(version)s
source: https://github.com/git-lfs/git-lfs
build_requires:
 - gmake
 - go
requires:
 - git
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

make ${JOBS:+-j$JOBS} VERSION=v$PKGVERSION GIT_LFS_SHA=$PKGVERSION
mkdir -p $INSTALLROOT/bin
mv bin/git-lfs $INSTALLROOT/bin
