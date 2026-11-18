package: alpgen
version: "214"
sources:
 - https://alpgen.web.cern.ch/V2.1/v%(version)s.tgz
 - file://config.sub-amd64.file
patches:
 - alpgen-214.patch
 - alpgen-214-Darwin-x86_84-gfortran.patch
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
cp "$SOURCEDIR/${SOURCE1}" "$BUILDDIR/config.sub"
patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
sed -i -e 's|-fno-automatic|-fno-automatic -std=legacy|' "$BUILDDIR/compile.mk"

# Build simple work directories
for dir in 2Qphwork 2Qwork 4Qwork hjetwork QQhwork topwork vbjetwork wcjetwork wphjetwork wphqqwork wqqwork zqqwork; do
    make ${JOBS:+-j$JOBS} -C "$BUILDDIR/$dir" gen
done

# Build Njetwork (first pass)
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/Njetwork" gen

# Build phjetwork with USRF variants
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/phjetwork" gen
for USRF in 120_180bin 180_240bin 20_60bin 240_300bin 300_5000bin 60_120bin; do
    make ${JOBS:+-j$JOBS} -C "$BUILDDIR/phjetwork" gen -f cmsMakefile USRF=$USRF
done

# Build wjetwork with USRF variants
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/wjetwork" gen
for USRF in 0ptw100 100ptw300 300ptw800 800ptw1600 1600ptw3200 3200ptw5000 VBFHiggsTo2Tau 2j_vbf_inv 3j_vbf_inv 1600ptw; do
    make ${JOBS:+-j$JOBS} -C "$BUILDDIR/wjetwork" gen -f cmsMakefile USRF=$USRF
done

# Build zjetwork with USRF variants
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/zjetwork" gen
for USRF in 0ptz100 100ptz300 300ptz800 800ptz1600 1600ptz3200 3200ptz5000 VBFHiggsTo2Tau 2j_vbf_inv 3j_vbf_inv 1600ptz; do
    make ${JOBS:+-j$JOBS} -C "$BUILDDIR/zjetwork" gen -f cmsMakefile USRF=$USRF
done

# Build Njetwork with USRF variants (second pass)
for USRF in 100_160 100_180 140_180 140_5600 160_200 180_250 180_5600 200_250 20_100 20_80 250_400 400_5600 80_140; do
    make ${JOBS:+-j$JOBS} -C "$BUILDDIR/Njetwork" gen -f cmsMakefile USRF=$USRF
done

# Install
mkdir -p "$INSTALLROOT/bin"
mkdir -p "$INSTALLROOT/alplib"
cp "$BUILDDIR/zjetwork/zjet_"*gen "$INSTALLROOT/bin/"
cp "$BUILDDIR/wjetwork/wjet_"*gen "$INSTALLROOT/bin/"
cp "$BUILDDIR/phjetwork/phjet_"*gen "$INSTALLROOT/bin/"
cp "$BUILDDIR/Njetwork/Njet_"*gen "$INSTALLROOT/bin/"
cp "$BUILDDIR/2Qphwork/2Qphgen"     "$INSTALLROOT/bin/"
cp "$BUILDDIR/2Qwork/2Qgen"         "$INSTALLROOT/bin/"
cp "$BUILDDIR/4Qwork/4Qgen"         "$INSTALLROOT/bin/"
cp "$BUILDDIR/hjetwork/hjetgen"     "$INSTALLROOT/bin/"
cp "$BUILDDIR/Njetwork/Njetgen"     "$INSTALLROOT/bin/"
cp "$BUILDDIR/phjetwork/phjetgen"   "$INSTALLROOT/bin/"
cp "$BUILDDIR/QQhwork/QQhgen"       "$INSTALLROOT/bin/"
cp "$BUILDDIR/topwork/topgen"       "$INSTALLROOT/bin/"
cp "$BUILDDIR/vbjetwork/vbjetgen"   "$INSTALLROOT/bin/"
cp "$BUILDDIR/wcjetwork/wcjetgen"   "$INSTALLROOT/bin/"
cp "$BUILDDIR/wjetwork/wjetgen"     "$INSTALLROOT/bin/"
cp "$BUILDDIR/wphjetwork/wphjetgen" "$INSTALLROOT/bin/"
cp "$BUILDDIR/wphqqwork/wphqqgen"   "$INSTALLROOT/bin/"
cp "$BUILDDIR/wqqwork/wqqgen"       "$INSTALLROOT/bin/"
cp "$BUILDDIR/zjetwork/zjetgen"     "$INSTALLROOT/bin/"
cp "$BUILDDIR/zqqwork/zqqgen"       "$INSTALLROOT/bin/"
cp -R "$BUILDDIR/alplib/"* "$INSTALLROOT/alplib/"
