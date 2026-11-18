package: icc
version: "2020"
---
cat << EoF > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
ln -s /cvmfs/projects.cern.ch/intelsw/oneAPI/linux/x86_64/2022/compiler/latest/linux/ \$WORK_DIR/\$PP/installation
EoF
