package: highfive
version: "%(tag_basename)s"
tag: v2.3.1
sources:
 - https://github.com/BlueBrain/HighFive/archive/refs/tags/%(tag_basename)s.tar.gz 
build_requires:
 - CMake
requires:
 - boost
 - hdf5
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build; cd ../build

cmake $BUILDDIR \
    -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
    -DHIGHFIVE_EXAMPLES=OFF \
    -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
    -DHIGHFIVE_UNIT_TESTS=OFF \
    -DCMAKE_PREFIX_PATH="${BOOST_ROOT};${HDF5_ROOT}" \
    -DCMAKE_INSTALL_RPATH="\$\$ORIGIN/../lib"

make install
