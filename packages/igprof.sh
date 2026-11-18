package: igprof
version: 5.9.16
variables:
  git_repo: igprof
  git_user: cms-externals
  git_branch: cms/master/c6882f4
  git_commit: 16da627e12a806cd8ab072e7288223c91086ea25
sources:
 - git://github.com/%(git_user)s/igprof.git?obj=%(git_branch)s/%(git_commit)s&export=igprof-%(git_commit)s&output=/igprof-%(git_commit)s.tgz
patches: 
 - igprof-gcc12.patch
build_requires:
 - CMake
requires:
 - pcre
 - libunwind
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0

rm -rf ../build && mkdir -p ../build && cd ../build

cmake $BUILDDIR \
   -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DCMAKE_VERBOSE_MAKEFILE=TRUE \
   -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-g -O3 -Wno-error=deprecated-declarations" \
   -DCMAKE_PREFIX_PATH="$LIBUNWIND_ROOT;$PCRE_ROOT"
make DEBUG=1 VERBOSE=1 ${JOBS:+-j $JOBS} 
make ${JOBS:+-j $JOBS} install
