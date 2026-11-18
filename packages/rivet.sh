package: rivet
version: 4.1.0
requires:
 - hepmc3
 - fastjet
 - fastjet-contrib
 - yoda
 - hdf5
 - highfive
 - Python
 - gcc
 - zlib
 - openmpi
build_requires:
 - py-cython
 - autotools
sources:
 - https://gitlab.com/hepcedar/rivet/-/archive/rivet-%(version)s/rivet-rivet-%(version)s.tar.gz
patches:
 - rivet-duplicate-libs.patch
 - rivet-pyextfjcontrib.patch
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"

export ROOT_CXXMODULES="0"
export PKG_VECTORIZATION='$(package_vectorization)s'
export CMSDISTDIR=$BITS_REPO_DIR
export CMS_CXX_STANDARD=$CXXSTD
export COMPILER_CXXFLAGS="$arch_build_flags"
if [[ -z $arch_build_flags ]]; then
    export COMPILER_CXXFLAGS='$selected_microarch'
fi
export ORACLE_ENV_ROOT=""
export CUDA_FLAGS="$nvcc_cuda_flags"
export LTO_FLAGS="$lto_build_flags"
export PGO_FLAGS="$pgo_build_flags" 

if [[ " $REQUIRES " == *" Python "* ]]; then
  export PYTHON3_LIB_SITE_PACKAGES
fi

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/tmp"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
    ls -la "$TMPDIR"/config.{guess,sub}
else
    exit 1
fi
for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_GUESS_FILE"
    cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE"
    chmod +x "$CONFIG_GUESS_FILE"
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_SUB_FILE"
    cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE"
    chmod +x "$CONFIG_SUB_FILE"
done

autoreconf -fiv

if [[ "$(uname -m)" == "aarch64" ]]; then
  sed -i -e 's|^ax_openmp_flags=".*"|ax_openmp_flags="none"|' ./configure
fi
CXXFLAGS="-std=c++$CXXSTD $CMS_EIGEN_CXX_FLAGS $selected_microarch"
sed -i "/_pow10 only defined for positive powers/d" include/Rivet/Tools/ParticleIdUtils.hh
PYTHON=$(which python3) ./configure --disable-silent-rules --prefix=$INSTALLROOT --with-hepmc=${HEPMC3_ROOT} \
            --with-fastjet=${FASTJET_ROOT} --with-fjcontrib=${FASTJET_CONTRIB_ROOT} --with-yoda=${YODA_ROOT} \
            --disable-doxygen --with-pic --enable-h5 \
            CXX="mpicxx" CPPFLAGS="-I${BOOST_ROOT}/include" CXXFLAGS="${CXXFLAGS}"

perl -p -i -e "s|LIBS = $|LIBS = -lHepMC3|g" bin/Makefile

make ${JOBS:+-j $JOBS} all
make install
sed -i -e 's|^#!.*python.*|#!/usr/bin/env python3|' $INSTALLROOT/bin/*
