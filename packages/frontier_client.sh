package: frontier_client
version: 2.10.2
sources: 
 - http://frontier.cern.ch/dist/frontier_client__%(version)s__src.tar.gz
requires:
 - gcc
 - expat
 - pacparser
 - zlib
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

export MAKE_ARGS="EXPAT_DIR=${EXPAT_ROOT} PACPARSER_DIR=${PACPARSER_ROOT} COMPILER_TAG=gcc_$(gcc -dumpversion) ZLIB_DIR=${ZLIB_ROOT}"

make $MAKE_ARGS CXXFLAGS="-ldl" CFLAGS=""
mkdir -p $INSTALLROOT/lib
mkdir -p $INSTALLROOT/include
make $MAKE_ARGS CXXFLAGS="-ldl" distdir=$INSTALLROOT dist

cp -r python $INSTALLROOT

if [[ "$(uname)" == "Darwin" ]]; then
    so="dylib"
    ln -sf "libfrontier_client.${PKG_VERSION}.${so}" \
        "$INSTALLROOT/lib/libfrontier_client.${so}"

    ln -sf "libfrontier_client.${so}.${PKG_VERSION}" \
        "$INSTALLROOT/libfrontier_client.$(echo "$PKG_VERSION" | sed -e 's/\([0-9]*\)\..*/\1/').${so}"
else
    so="so"
    ln -sf "libfrontier_client.${so}.${PKG_VERSION}" \
        "$INSTALLROOT/lib/libfrontier_client.${so}"

    ln -sf "libfrontier_client.${so}.${PKG_VERSION}" \
        "$INSTALLROOT/lib/libfrontier_client.$(echo "$PKG_VERSION" | sed -e 's/\([0-9]*\)\..*/\1/')"
fi
