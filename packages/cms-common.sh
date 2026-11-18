package: cms-common
version: "1259"
tag: fec24d23bd6c04dcdbebfe035ff63a22b299ee4a
source: https://github.com/cms-sw/cms-common
force_revision: ""
---
# Copy source tree to build directory, excluding git metadata.
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

# Substitute CMS install prefix and architecture in all source files.
# @CMS_PREFIX@ is replaced with the global install root (not the package dir).
# @SCRAM_ARCH@ is replaced with the architecture string.
find . -type f | xargs sed -i -e "s|@CMS_PREFIX@|$WORK_DIR|g;s|@SCRAM_ARCH@|$ARCHITECTURE|"

rsync -a $BUILDDIR/ $INSTALLROOT/

# --- Post-relocate script ---
# cms-common files are deployed to the root of the install area ($WORK_DIR).
# This script copies package contents there, handling revision checks and
# special directories (scramrc, share).
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
mkdir -p \$WORK_DIR/etc/$PKGNAME \$WORK_DIR/$ARCHITECTURE/etc/profile.d
# Check if a newer revision is already installed.
# Also force installation if older revision has deleted cmsset_default.csh.
if [ -f \$WORK_DIR/cmsset_default.csh ] && [ -f \$WORK_DIR/etc/cms-common/revision ] ; then
  existing_rev=\$(cat \$WORK_DIR/etc/cms-common/revision)
  if [ \$existing_rev -ge $PKGVERSION ] ; then
    exit 0
  fi
fi

# Enter the installed package directory to use relative paths for file operations.
cd \$WORK_DIR/\$PP

mkdir -p \$WORK_DIR/share \$WORK_DIR/etc/scramrc
# Sync SCRAM configuration database if present.
[ -d ./etc/scramrc/SCRAM ] && rsync -a --delete \$(pwd)/etc/scramrc/SCRAM/ \$WORK_DIR/etc/scramrc/SCRAM/
# Sync shared data files if present.
[ -d ./share ] && rsync -a \$(pwd)/share/ \$WORK_DIR/share/

# Copy all remaining files to the install root, skipping the scramrc/SCRAM
# directory (already handled above with --delete).
for file in \$(find . -name '*' | grep -v '^./etc/scramrc/SCRAM'); do
  if [ -d \$file ] ; then
    mkdir -p \$WORK_DIR/\$file
  else
    rm -f \$WORK_DIR/\$file
    cp -P \$file \$WORK_DIR/\$file
  fi
done

# Record the installed revision for future upgrade checks.
echo $PKGVERSION > \$WORK_DIR/etc/cms-common/revision
EoF
