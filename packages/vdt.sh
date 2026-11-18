package: vdt
version: "0.4.3"
build_requires:
- CMake
- Python
requires:
- gcc
sources: 
- https://github.com/dpiparo/vdt/archive/v%(version)s.tar.gz
patches:
- vdt-integer-overflow.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < $SOURCEDIR/$PATCH0

cmake_args=(
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT
  -DPYTHONLIBS_VERSION_STRING=%(python_major_minor)s
  -DNEON:BOOL=OFF
  )

if [[ "$(uname -m)" == "x86_64" ]]; then
  cmake_args+=(
    -DSSE:BOOL=ON
  )
else
  cmake_args+=(
    -DSSE:BOOL=OFF
  )
fi

cmake "${cmake_args[@]}" $BUILDDIR

make ${JOBS:+-j$JOBS} VERBOSE=1
make install
