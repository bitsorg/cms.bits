package: crab
version: "1.0"
requires:
 - crab-prod
 - crab-pre
 - crab-dev
architecture: share
sources:
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/crab/crab.sh.file
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/crab/crab-proxy-package.file
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/crab/crab-setup.csh.file
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/crab/crab-setup.sh.file
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/crab/crab-env.csh.file
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/crab/crab-env.sh.file
---
cp $SOURCEDIR/$SOURCE0 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE1 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE2 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE3 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE4 $INSTALLROOT/

for f in "$INSTALLROOT"/*.file; do
  mv "$f" "${f%.file}"
done

chmod +x $INSTALLROOT/crab.sh

sed -i -e "s|@CMS_PATH@|$BITS_WORK_DIR|g" "$INSTALLROOT"/crab*
sed -i -e "s|@CRAB_COMMON_VERSION@|$PKG_VERSION-$PKGREVISION|g" "$INSTALLROOT"/crab*

cat >$INSTALLROOT/etc/profile.d/post-relocate.sh <<EoF
revision_copy() {
  local SRC="\$1"
  local DST="\$2"
  mkdir -p "\$(dirname "\$2")"

  local OLD_REV=0
  local NEW_REV=0

  # Read revision from destination if it exists
  if [ -f "\$DST" ]; then
    OLD_REV=\$(grep '^#CMSDIST_FILE_REVISION=' "\$DST" | tail -1 | sed 's|.*=||;s| ||g')
    [ -z "\$OLD_REV" ] && OLD_REV=0
  fi

  # Read revision from source
  NEW_REV=\$(grep '^#CMSDIST_FILE_REVISION=' "\$SRC" | tail -1 | sed 's|.*=||;s| ||g')
  [ -z "\$NEW_REV" ] && NEW_REV=0

  # Only copy if source is newer
  if [ "\$OLD_REV" -lt "\$NEW_REV" ]; then
    cp "\$SRC" "\$DST.tmp"
    mv "\$DST.tmp" "\$DST"
  fi
}

cd \$WORK_DIR
  crab=\$WORK_DIR/\$PP
  mkdir -p \${crab}/{bin,lib,etc} \${crab}/share/etc/profile.d
  for f in crab-env.csh crab-env.sh ; do
    revision_copy "\$WORK_DIR/\$PP/\$f" "\$WORK_DIR/share/etc/profile.d/S99\$f"
  done

  for f in crab-setup.csh crab-setup.sh ; do
    revision_copy "\$WORK_DIR/\$PP/\$f" "\$WORK_DIR/common/\$f"
  done

  revision_copy "\$WORK_DIR/\$PP/crab.sh"            "\$WORK_DIR/\$PP/bin/crab.sh"
  revision_copy "\$WORK_DIR/\$PP/crab-proxy-package" "\$WORK_DIR/\$PP/lib/crab-proxy-package"
  for pkg in $(echo $REQUIRES | grep -o 'crab-[^ ]*' | tr '\n' ' '); do
    crab_name=\$pkg
    crab_type=\$(echo \$crab_name | sed -e 's|^crab-||')                                                                                      
    for p in $(cat share/\${pkg}/etc/crab_py_pkgs.txt); do
      mkdir -p \${crab}/lib/\${crab_type}/\$p
      rm -rf \${crab}/lib/\${crab_type}/\$p/__init__.py*
      ln -s ../../crab-proxy-package \${crab}/lib/\${crab_type}/\$p/__init__.py
    done
    ls -d share/cms/\${crab_name}/v*/bin/crab | sed 's|/bin/crab$||;s|.*/||' | sort -n | tail -1 > \${crab}/etc/\${crab_name}.latest
    ln -rsf \${crab}/bin/crab.sh \$WORK_DIR/common/\${crab_name}
  done
  ln -rsf \$WORK_DIR/\$PP/bin/crab.sh \$WORK_DIR/common/crab
EoF
