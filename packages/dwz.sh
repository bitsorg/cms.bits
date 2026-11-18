package: dwz
version: "0.15"
tag: 0171f3e7ac09fa44cb1eb299f2703faa113a207e
variables:
 dwz_branch: "master"
 dwz_commit: "0171f3e7ac09fa44cb1eb299f2703faa113a207e"
sources:
 - git://sourceware.org/git/dwz.git?obj=%(dwz_branch)s/%(dwz_commit)s&export=dwz-%(dwz_commit)s&output=/dwz-%(dwz_commit)s.tgz
requires:
 - xxhash
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j $JOBS} \
	CFLAGS="-I${XXHASH_ROOT}/include -O2" \
	LDFLAGS="-L${XXHASH_ROOT}/lib"

mkdir -p $INSTALLROOT/bin
cp dwz $INSTALLROOT/bin
