package: dip
version: 8693f00cc422b4a15858fcd84249acaeb07b6316
variables:
  xtag: f41e221f8fb95830fc001dad975b4db770f5d29d
sources:
  - git+https://:@gitlab.cern.ch:8443/acc-co/cmw/cmw-dip/dip.git?obj=develop/%(version)s&export=%(package)s&output=/%(package)s-%(version)s.tgz
  - git+https://:@gitlab.cern.ch:8443/acc-co/cmw/cmw-dip/platform-dependent.git?obj=develop/%(xtag)s&export=platform-dependent&output=/platform-dependent-%(xtag)s.tgz
build_requires:
  - CMake
  - gmake
requires:
  - log4cplus
  - gcc
---
tar -xzf "$SOURCEDIR/$SOURCE0" -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/$SOURCE1" -C "$BUILDDIR"

sed -i -e '/conanbuildinfo.cmake\|conan_basic_setup/d' "$BUILDDIR/dip/CMakeLists.txt"
sed -i -e 's|CONAN_PKG::||g;s|log4cplus|log4cplusS|' "$BUILDDIR/dip/CMakeLists.txt"
sed -i -e '/conanbuildinfo.cmake\|conan_basic_setup/d' "$BUILDDIR/platform-dependent/CMakeLists.txt"

cmake -S "$BUILDDIR/platform-dependent" -B "$BUILDROOT/build/platform-dependent" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
cmake --build "$BUILDROOT/build/platform-dependent" ${JOBS:+--parallel $JOBS} -- VERBOSE=1
cmake --install "$BUILDROOT/build/platform-dependent"

LDFLAGS="-L${LOG4CPLUS_ROOT}/lib64 -L$INSTALLROOT/lib" \
  CXXFLAGS="-I$INSTALLROOT/include -I${LOG4CPLUS_ROOT}/include" \
  cmake -S "$BUILDDIR/dip" -B "$BUILDROOT/build/dip" \
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
cmake --build "$BUILDROOT/build/dip" ${JOBS:+--parallel $JOBS} -- VERBOSE=1
cmake --install "$BUILDROOT/build/dip"

rm -rf "$INSTALLROOT/lib/cmake"
