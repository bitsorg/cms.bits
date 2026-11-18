package: fastjet
version: "3.4.1"
variables:
    github_user: "cms-externals"
    branch: cms/v%%(version)s
    tag: "e843c303828cd0b882d386decc35ad8c1b19df3d"
sources:
  - git+https://github.com/%(github_user)s/fastjet.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
patches:
  - fastjet-deprecated-warn.patch
requires:
  - gcc
  - autotools
  - Python
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR"
rm -f "$TMPDIR"/config.{sub,guess}
rm -rf "$BUILDDIR/plugins/SISCone/siscone/config.{sub,guess}"

curl -L -k -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
chmod +x "$TMPDIR"/config.{sub,guess}
cp "$TMPDIR"/config.{sub,guess} "$BUILDDIR"/plugins/SISCone/siscone/

export CXXFLAGS="-O3 -Wall -ffast-math -ftree-vectorize -march=x86-64-v3"
echo "CXXFLAGS: $CXXFLAGS"
echo "arch_flags: $arch_flags"

if [[ -n "$arch_flags" ]]; then
    export CXXFLAGS="$CXXFLAGS $arch_flags"
fi

PYTHON=$PYTHON_ROOT/bin/python$PYTHON_MAJOR_MINOR_VERSION \
CC=$GCC_ROOT/bin/gcc \
CXX=$GCC_ROOT/bin/g++ \
  ./configure \
  --enable-shared \
  --enable-atlascone \
  --enable-cmsiterativecone \
  --enable-siscone \
  --prefix=$INSTALLROOT \
  --enable-allcxxplugins \
  --enable-pyext \
  --enable-limited-thread-safety \
  CXXFLAGS="$CXXFLAGS"

make ${JOBS:+-j$JOBS}
make install

rm -rf $INSTALLROOT/lib/*.la
