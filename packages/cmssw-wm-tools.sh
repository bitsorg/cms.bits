package: cmssw-wm-tools
version: "250417"
tag: cd271d3796bfd8d0eff6500f801a4367bfd1b5dc
source: https://github.com/cms-sw/cmssw-wm-tools
architecture: share
force_revision: ""
---
# Copy source tree to build directory, excluding git metadata.
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

# Install the entire source tree into the package directory.
rsync -a $BUILDDIR/ $INSTALLROOT/

# --- Post-relocate script ---
# Deploys bin/ and python/ overrides to the shared install area.
# Checks version to avoid downgrading a newer installation.
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
# Check if a newer version is already installed; skip if so.
if [ -f \$WORK_DIR/etc/$PKGNAME/version ] ; then
  if [ \$(cat \$WORK_DIR/etc/$PKGNAME/version) -ge $PKGVERSION ] ; then
    exit 0
  fi
fi

mkdir -p \$WORK_DIR/share/overrides \$WORK_DIR/etc/$PKGNAME

# Enter the installed package directory to use relative paths.
cd \$WORK_DIR/share/$PKGFAMILY/$PKGNAME/$PKGVERSION

# Sync bin/ and python/ directories to the shared overrides area.
for d in bin python ; do
  rsync -a ./\$d/ \$WORK_DIR/share/overrides/\$d/
done

# Record the installed version for future upgrade checks.
echo $PKGVERSION > \$WORK_DIR/etc/$PKGNAME/version
EoF
