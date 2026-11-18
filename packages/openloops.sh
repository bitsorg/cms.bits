package: openloops
version: "2.1.2"
variables:
  branch: cms/v%%(version)s
  github_user: cms-externals
  tag: 4247179369144b0134c7b8014a5d38a90dc9b6ba
  process_src: process_src.tgz
patches:
 - openloops-py3.patch
requires:
 - py-scons
 - openloops-sources
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$OPENLOOPS_SOURCES_ROOT/openloops_source/"/ "$BUILDDIR"/

patch -p1 -i "$SOURCEDIR/$PATCH0"

if [ "$(uname -m)" = "aarch64" ]; then
    drop_process="pplljj_ew"
    sed -i -e 's|^ *cmodel *=.*|cmodel = small|' pyol/config/default.cfg
else
    drop_process=""
fi

cat <<EOF > openloops.cfg
[OpenLoops]
fortran_compiler = gfortran
gfortran_f90_flags = -ffixed-line-length-0 -ffree-line-length-0 $gcc10_extra_flag
generic_optimisation = -O2
born_optimisation = -O2
loop_optimisation = -O0
link_optimisation = -O2
EOF

export SCONSFLAGS="-j$JOBS"
cp $OPENLOOPS_SOURCES_ROOT/openloops-user.coll.file openloops-user.coll
./openloops update --processes generator=0
tar -xzf $OPENLOOPS_SOURCES_ROOT/process_src.tgz

for xproc in $drop_process; do
  sed -i -e "/^${xproc}\$/d" openloops-user.coll
  sed -i -e "/^${xproc} .*/d" process_src/downloaded.dat
  rm -rf "process_src/${xproc}"
done

./openloops libinstall openloops-user.coll

mkdir -p $INSTALLROOT/{lib,proclib}
cp lib/*.so $INSTALLROOT/lib
cp proclib/*.so $INSTALLROOT/proclib
cp proclib/*.info $INSTALLROOT/proclib
