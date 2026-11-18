package: icx
version: "2025.0"
---
export year=$(echo $PKGVERSION | cut -d. -f1)
cat << EoF > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
ln -s /cvmfs/projects.cern.ch/intelsw/oneAPI/linux/x86_64/$year/compiler/$PKGVERSION \$WORK_DIR/\$PP/installation
EoF
