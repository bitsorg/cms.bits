package: cms-git-tools
version: "251202"
tag: 3a9b0d4071871bf3a7ba4cfc105f8935978562f2
source: https://github.com/cms-sw/cms-git-tools
variables:
  fakerevision: "251202"
build_requires:
 - gmake
force_architecture: share
force_revision: ""
hook: disable
---
# Copy source tree to build directory, excluding git metadata.
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

# Install git-cms-* commands to common/ and man pages to share/man/.
mkdir -p $INSTALLROOT/common $INSTALLROOT/share/man/man1
cp -pR $BUILDDIR/git-cms-* $INSTALLROOT/common
cp $BUILDDIR/docs/man/man1/*.1 $INSTALLROOT/share/man/man1
find $INSTALLROOT/common -name '*' -type f -exec chmod +x {} \;

# --- Post-relocate script ---
# Deploys git-cms-* commands and man pages to the shared install area.
# Checks revision to avoid downgrading a newer installation.
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
mkdir -p \$WORK_DIR/share \$WORK_DIR/common \$WORK_DIR/etc/cms-git-tools \$WORK_DIR/share/man/man1

# Check if a newer revision is already installed; skip if so.
if [ -f \$WORK_DIR/etc/cms-git-tools/version ] ; then
  oldrev=\$(cat \$WORK_DIR/etc/cms-git-tools/version)
  if [ \$oldrev -ge $PKG_VERSION ] ; then
    exit 0
  fi
fi

# Enter the installed package directory to use relative paths (matches spec's
cd \$WORK_DIR/share/$PKGNAME/$PKGVERSION

# Sync man pages and git-cms-* commands to the shared install area.
[ -d ./share ]  && rsync -a ./share/  \$WORK_DIR/share/
[ -d ./common ] && rsync -a ./common/ \$WORK_DIR/common/

# Remove deprecated commands that are no longer maintained.
rm -f \$WORK_DIR/common/git-addpkg
rm -f \$WORK_DIR/common/git-checkdeps

# Record the installed version for future upgrade checks.
echo $PKG_VERSION > \$WORK_DIR/etc/cms-git-tools/version
EoF

