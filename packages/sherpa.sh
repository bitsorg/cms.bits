package: sherpa
version: "2.2.16"
sources:
 - git+https://gitlab.com/sherpa-team/sherpa.git?obj=master/v%(version)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
patches:
 - sherpa-2.2.16-hepmcshort.patch
 - sherpa-setenv.patch
 - sherpa-disable-manual.patch
build_requires:
 - mcfm
 - swig
 - autotools
requires:
 - gcc
 - hepmc
 - hepmc3
 - lhapdf
 - blackhat
 - sqlite
 - Python
 - fastjet
 - openmpi
prepend_path:
 LD_LIBRARY_PATH: $SHERPA_ROOT/lib/SHERPA-MC
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
patch -p1 < "$SOURCEDIR/$PATCH2"

autoreconf -i --force

if [[ $(uname -m) =~ ^x86_64.*$ ]]; then
  ARCH_CMSPLATF="-m64"
fi

export PYTHON=$(which python3)

./configure --prefix=$INSTALLROOT --enable-analysis --disable-silent-rules \
            --enable-fastjet=$FASTJET_ROOT \
            --enable-hepmc2=$HEPMC_ROOT \
            --enable-hepmc3=$HEPMC3_ROOT \
            --enable-lhapdf=$LHAPDF_ROOT \
            --enable-blackhat=$BLACKHAT_ROOT \
            --enable-pyext \
            --enable-ufo \
            ${OPENLOOPS_ROOT+--enable-openloops=$OPENLOOPS_ROOT} \
            --enable-mpi \
            --with-sqlite3=$SQLITE_ROOT \
            --enable-analysis \
            CC="mpicc" \
            CXX="mpicxx" \
            MPICXX="mpicxx" \
            FC="mpifort" \
            CXXFLAGS="-fuse-cxa-atexit $ARCH_CMSPLATF -O2 -std=c++0x -I$LHAPDF_ROOT/include -I$BLACKHAT_ROOT/include -I$RIVET_ROOT/include" \
            LDFLAGS="-ldl -L$BLACKHAT_ROOT/lib/blackhat -L$QD_ROOT/lib"

make ${JOBS:+-j $JOBS}
make install

find $INSTALLROOT/lib -name '*.la' -delete
sed -i -e 's|^#!/.*|#!/usr/bin/env python3|' $INSTALLROOT/bin/Sherpa-generate-model
