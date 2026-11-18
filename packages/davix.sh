package: davix
version: "%(tag_basename)s"
tag: R_0_8_9
source: https://github.com/cern-fts/davix
build_requires:
 - CMake
requires:
 - gcc
 - libxml2
 - libuuid
 - curl
 - Python
 - zlib
---
cd $SOURCEDIR
git submodule update --recursive --init
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/
cd $BUILDDIR

soext="so"
if [[ "$(uname -s)" == "Darwin" ]]; then
    soext="dylib"
fi


rm -rf ../build; mkdir ../build; cd ../build

cmake ../davix \
  -DRAPIDJSON_HAS_STDSTRING=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DEMBEDDED_LIBCURL=FALSE \
  -DDAVIX_TESTS=FALSE \
  -DUUID_LIBRARY="${LIBUUID_ROOT}/lib64/libuuid.${soext}" \
  -DCMAKE_PREFIX_PATH="${LIBXML2_ROOT};${LIBUUID_ROOT};${CURL_ROOT}" \

make VERBOSE=1 ${JOBS:+-j$JOBS}
cd ../build
make install
