package: google-benchmark
version: 1.7.x
variables:
 benchmarkCommit: b177433f3ee2513b1075140c723d73ab8901790f
 benchmarkBranch: main
 googletestCommit: 0bdaac5a1401fffac6b64581efc639734aded793
 googletestBranch: main
sources:
 - git+https://github.com/google/benchmark.git?obj=%(benchmarkBranch)s/%(benchmarkCommit)s&export=benchmark-%(version)s-%(benchmarkCommit)s&module=benchmark-%(version)s-%(benchmarkCommit)s&output=/benchmark-%(version)s-%(benchmarkCommit)s.tgz
 - git+https://github.com/google/googletest.git?obj=%(googletestBranch)s/%(googletestCommit)s&export=googletest-%(version)s-%(googletestCommit)s&module=googletest-%(version)s-%(googletestCommit)s&output=/googletest-%(version)s-%(googletestCommit)s.tgz
build_requires:
 - CMake
 - ninja
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/${SOURCE1}" \
    -C "$BUILDDIR"
mv $BUILDDIR/googletest-%(version)s-%(googletestCommit)s googletest
mv $BUILDDIR/googletest $BUILDDIR/benchmark-%(version)s-%(benchmarkCommit)s/
rm -rf ../build && mkdir -p ../build && cd ../build

cmake $BUILDDIR/benchmark-%(version)s-%(benchmarkCommit)s \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_CXX_FLAGS="-fPIE" \
  -DCMAKE_BUILD_TYPE:STRING=Release

ninja -v ${JOBS:+-j$JOBS}
ninja -v ${JOBS:+-j$JOBS} install
