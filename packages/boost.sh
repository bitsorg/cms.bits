package: boost
version: "1.80.0"
tag: 66e4a726b4ac46155ef33553b65172900660dde5
variables:
  github_user: "cms-externals"
  branch: "cms/v%(version)s"
sources:
  - git+https://github.com/%(github_user)s/boost.git?obj=%(branch)s/%(tag_basename)s&export=boost-%(version)s&output=/boost-%(version)s.tgz
requires:
  - gcc
  - Python
  - bz2lib
  - zlib
  - openmpi
  - xz
  - zstd
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Detect toolset
if [[ "$(uname)" == "Darwin" ]]; then
    TOOLSET=darwin
else
    TOOLSET=gcc
fi

# Bootstrap b2 build tool
pushd "$BUILDDIR/tools/build"
    sh bootstrap.sh "${TOOLSET}"
    mkdir -p ./tmp-boost-build
    ./b2 install --prefix=./tmp-boost-build
    export PATH="${PWD}/tmp-boost-build/bin:${PATH}"
popd

# Configure python and mpi
PYTHONV=$(echo "$PYTHON_VERSION" | sed 's/^v//' | cut -f1,2 -d.)
echo "using mpi ;" >> "$BUILDDIR/user-config.jam"
echo "using python : ${PYTHONV} : ${PYTHON_ROOT}/bin/python3 : ${PYTHON_ROOT}/include/python${PYTHONV} : ${PYTHON_ROOT}/lib ;" >> "$BUILDDIR/user-config.jam"

# Build
b2_args=(
    -q
    -d2
    define=BOOST_FILESYSTEM_DISABLE_STATX
    ${JOBS:+-j$JOBS}
    --build-dir="$BUILDDIR/build-boost"
    --disable-icu
    --without-atomic
    --without-container
    --without-context
    --without-coroutine
    --without-exception
    --without-graph
    --without-graph_parallel
    --without-locale
    --without-log
    --without-math
    --without-random
    --without-wave
    --user-config="$BUILDDIR/user-config.jam"
    toolset="${TOOLSET}"
    link=shared
    threading=multi
    variant=release
    python="${PYTHONV}"
    -sBZIP2_INCLUDE="${BZ2LIB_ROOT}/include"
    -sBZIP2_LIBPATH="${BZ2LIB_ROOT}/lib"
    -sZLIB_INCLUDE="${ZLIB_ROOT}/include"
    -sZLIB_LIBPATH="${ZLIB_ROOT}/lib"
    -sLZMA_INCLUDE="${XZ_ROOT}/include"
    -sLZMA_LIBPATH="${XZ_ROOT}/lib"
    -sZSTD_INCLUDE="${ZSTD_ROOT}/include"
    -sZSTD_LIBPATH="${ZSTD_ROOT}/lib"
    stage
)
b2 "${b2_args[@]}"

# Install libraries, cmake files and headers
mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/include"
find "$BUILDDIR/stage/lib" \( -name "*.so*" -o -name "*.cmake" \) \
    -exec cp -a {} "$INSTALLROOT/lib/" \;
cp -r "$BUILDDIR/boost" "$INSTALLROOT/include/"

