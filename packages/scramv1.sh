package: SCRAMV1
version: V3_00_92
tag: d324a51fc7b7ee32cf230189cde3a376977fc2bd
branch: SCRAMV3
source: https://github.com/cms-sw/SCRAM
architecture: share
force_revision: ""
env:
  SCRAMV1_VERSION: "$PKGVERSION"
requires:
 - cms-common
---
if ! [[ "$PKGVERSION" =~ ^(V([0-9]+)_([0-9]+))_([0-9]+) ]]; then
  echo "You are trying to build SCRAM version $PKGVERSION which does not follow the SCRAM version policy."
  echo "Valid SCRAM versions should be of the form V[0-9]+_[0-9]+_[0-9].*"
  exit 1
fi

SCRAM_REL_MINOR="${BASH_REMATCH[1]}"   # e.g. V3_12
SCRAM_REL_MAJOR="V${BASH_REMATCH[2]}"  # e.g. V3

# Copy source tree to build directory, excluding git metadata.
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

# Substitute CMS install path and SCRAM version in the Python module.
# @CMS_PATH@ becomes the install root and @SCRAM_VERSION@ becomes the version string.
sed -i -e "s|@CMS_PATH@|$INSTALLROOT|g;s|@SCRAM_VERSION@|$PKGVERSION|g" SCRAM/__init__.py

# Install binaries, Python module, and documentation into the package directory.
mkdir $INSTALLROOT/bin $INSTALLROOT/docs
mv $BUILDROOT/$PKGNAME/SCRAM $INSTALLROOT/
mv $BUILDROOT/$PKGNAME/docs/man $INSTALLROOT/docs/
cp $BUILDROOT/$PKGNAME/cli/scram $INSTALLROOT/bin/
cp $BUILDROOT/$PKGNAME/cli/scram.py $INSTALLROOT/bin/

# --- Post-relocate script ---
# This runs after the package is installed at its final location. It handles
# environment setup, version tracking, and project database initialization.

# First heredoc (quoted): no variable expansion. Defines the SetLatestVersion helper.
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<'EoF'
#!/bin/bash -e

# SetLatestVersion: Scans installed SCRAM versions under a search directory,
# normalizes version strings for correct sorting, and writes the latest
# matching version to a tracking file under etc/.
#
# This enables the system to determine which SCRAM version should be the
# default for a given major version series.
#
# Arguments:
#   $1 - search directory containing <version>/bin/ subdirectories
#   $2 - version regexp to filter matching versions
#   $3 - output version file path (relative to etc/ in current directory)
function SetLatestVersion() {
  local search_dir="$1"
  local version_regexp="$2"
  local version_file="$3"
  local vers=""

  # Find all installed versions that have a bin/ directory
  for ver in $(find "$search_dir" -maxdepth 2 -mindepth 2 -name "bin" -type d \
      | sed 's|/bin$||' \
      | xargs -I '{}' basename '{}' \
      | grep "$version_regexp" \
      | sed 's|-local[1-9]||g'); do

    # Normalize version for sorting: zero-pad single-digit components
    # e.g., V3_0_9 -> V03_00_09_ so lexicographic sort gives correct order
    ver_str=$(echo "$ver" \
      | sed 's|-.\+$||' \
      | tr '_' '\n' \
      | sed 's|V\([0-9]\)$|V0\1|; s|^\([0-9]\)$|0\1|' \
      | tr '\n' '_')
    vers="${ver_str}zzz:${ver} ${vers}"
  done

  # Sort normalized strings and extract the latest original version name
  echo "$vers" \
    | tr ' ' '\n' \
    | grep -v '^$' \
    | sort \
    | tail -1 \
    | sed 's|.*:||' \
    > "etc/$version_file"
}
EoF

# Second heredoc (unquoted): build-time variables are expanded ($PKGNAME,
# $PKGVERSION, $SCRAM_*). Runtime variables are escaped (\$WORK_DIR,
# \$ARCHITECTURE, \$ver) so they remain as shell variables in the output.
cat >>"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF

# Update BASEPATH in the SCRAM Python module to the actual install prefix.
# At build time it is set to the build host path; this corrects it for the
# target installation.
sed -i -e "s|^BASEPATH = .*|BASEPATH = '\$WORK_DIR'|" \$WORK_DIR/\$PP/SCRAM/__init__.py
sed -i -e "s|^BASEPATH_RW = .*|BASEPATH_RW = '\$WORK_DIR'|" \$WORK_DIR/\$PP/SCRAM/__init__.py

# Create the SCRAM project database directory and default project maps if they
# don't already exist. These maps tell SCRAM where to find installed CMS
# projects (CMSSW, CMSSW-patch, CORAL).
if [ ! -d \$WORK_DIR/etc/scramrc ] ; then
  mkdir -p \$WORK_DIR/etc/scramrc
  touch \$WORK_DIR/etc/scramrc/links.db
  echo 'CMSSW=\$SCRAM_ARCH/cms/cmssw/CMSSW_*'       > \$WORK_DIR/etc/scramrc/cmssw.map
  echo 'CMSSW=\$SCRAM_ARCH/cms/cmssw-patch/CMSSW_*' > \$WORK_DIR/etc/scramrc/cmssw-patch.map
  echo 'CORAL=\$SCRAM_ARCH/cms/coral/CORAL_*'       > \$WORK_DIR/etc/scramrc/coral.map
fi

# Ensure site configuration file exists (may be empty).
touch \$WORK_DIR/etc/scramrc/site.cfg

# Create default-scram version tracking directories for both the architecture-
# specific and shared areas. These hold files recording the default SCRAM version.
mkdir -p \$WORK_DIR/\$ARCHITECTURE/etc/default-scram \$WORK_DIR/share/etc/default-scram

# --- Architecture-specific version tracking ---
# Maintain version files under the architecture directory for backward
# compatibility. Tools may look here to find the default SCRAM version.
# Since the package lives in shared/ (force_architecture: shared), we point
# the search at the shared directory.
pushd \$WORK_DIR/\$ARCHITECTURE
SetLatestVersion "\$WORK_DIR/share/lcg/$PKGNAME" "$PKG_VERSION" "default-scramv1-version"
SetLatestVersion "\$WORK_DIR/share/lcg/$PKGNAME" "${SCRAM_REL_MAJOR}_" "default-scram/${SCRAM_REL_MAJOR}"

# Backward compatibility version policy for the architecture area:
# Ensure each minor-version file (e.g., V3_00) contains the same default as
# the major-version file (e.g., V3). This lets tools that look up defaults by
# minor version get the correct result. V2_0 and V2_1 are excluded as legacy.
touch etc/default-scram/${SCRAM_REL_MINOR}
for ver in \$(find etc/default-scram -maxdepth 1 -mindepth 1 -name "${SCRAM_REL_MAJOR}_[0-9]*" -type f | xargs -I '{}' basename '{}' | grep 'V[0-9][0-9]*_[0-9][0-9]*\$'); do
  case \$ver in
    V2_[01] ) ;;
    * )
      if [ -f etc/default-scram/${SCRAM_REL_MAJOR} ] ; then
        cp etc/default-scram/${SCRAM_REL_MAJOR} etc/default-scram/\$ver
      else
        rm -f etc/default-scram/\$ver
      fi;;
  esac
done

# --- Shared area version tracking ---
# Update default version tracking in the shared area where the package lives.
cd \$WORK_DIR/share
SetLatestVersion "\$WORK_DIR/share/lcg/$PKGNAME" "$PKG_VERSION" "default-scramv1-version"
SetLatestVersion "\$WORK_DIR/share/lcg/$PKGNAME" "${SCRAM_REL_MAJOR}_" "default-scram/${SCRAM_REL_MAJOR}"

# If this version is the latest overall default, install its man page to the
# shared man directory so it is available system-wide.
if [ \$(cat \$WORK_DIR/share/etc/default-scramv1-version) == '$PKGVERSION' ] ; then
  mkdir -p \$WORK_DIR/share/man/man1
  cp -f \$WORK_DIR/\$PP/docs/man/man1/scram.1 \$WORK_DIR/share/man/man1/scram.1
fi
EoF
