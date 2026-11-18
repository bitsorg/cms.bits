package: coral
version: "CORAL_2_3_21"
variables:
  tag: "4fc6c24175682aff2d4299765b47b603a7b218d2"
  branch: "cms/CORAL_2_3_21py3"
  github_user: "cms-externals"
  subpackageDebug: "yes"
  configtag: "V09-08-10"
  buildtarget: "release-build"
  scram_compiler: "gcc"
  enable_biglib: "1"
  srctree: "src"
  bootstrapfile: "config/bootsrc.xml"
sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
 - git+https://github.com/%(github_user)s/coral.git?protocol=https&obj=%(branch)s/%(tag)s&module=coral&export=%(srctree)s&output=/src.tar.gz
patches:
 - coral-2_3_21-gcc8.patch
build_requires:
 - SCRAMV1
 - dwz
requires:
 - coral-tool-conf
 - pcre
 - Python
 - gcc
 - expat
 - boost
 - frontier_client
 - sqlite
 - libuuid
 - zlib
 - bz2lib
 - xerces-c
---
source $WORK_DIR/cmsset_default.sh
# scram-project-build.sh
# Converted from scram-project-build.file (RPM spec)
# This is a base/fragment meant to be used by CMSSW-like projects

# Export YAML variables
export CONFIGTAG="${CONFIGTAG:-%(configtag)s}"
export BUILDTARGET="${BUILDTARGET:-%(buildtarget)s}"
export SCRAM_COMPILER="${SCRAM_COMPILER:-%(scram_compiler)s}"
export ENABLE_BIGLIB="${ENABLE_BIGLIB:-%(enable_biglib)s}"
export SRCTREE="${SRCTREE:-%(srctree)s}"
export BOOTSTRAPFILE="${BOOTSTRAPFILE:-%(bootstrapfile)s}"
export SUBPACKAGEDEBUG="${SUBPACKAGEDEBUG:-%(subpackageDebug)s}"

# Derived variables
CMSSW_LIBS="biglib/$ARCHITECTURE lib/$ARCHITECTURE"
SCRAM_HOME_SUFFIX=""  # V2_ check skipped for now
SCRAM_SCRIPT_PREFIX=".py"  # modern SCRAM uses python

# SCRAM command helper
SCRAMCMD="$SCRAMV1_ROOT/bin/scram --arch $ARCHITECTURE"

# Project type detection (derived from package name)
UCPROJTYPE=$(echo "$PKGNAME" | sed -e "s|-patch||" | tr 'a-z' 'A-Z')
LCPROJTYPE=$(echo "$UCPROJTYPE" | tr 'A-Z' 'a-z')
TOOLCONF=$(echo "$PKGNAME" | sed "s|-|_|g" | tr 'a-z' 'A-Z')_TOOL_CONF_ROOT

# extraOptions handling
# TODO: subpackageDebug support - for now use simple path
if [ -n "${USERCXXFLAGS:-}" ]; then
  EXTRA_OPTIONS="USER_CXXFLAGS='$USERCXXFLAGS'"
else
  EXTRA_OPTIONS=""
fi

# buildarch - defaults to no-op
BUILDARCH="${BUILDARCH:-:}"

# =============================================================================
# PREP SECTION - Extract sources and setup config
# =============================================================================

# Clean previous build artifacts
rm -rf "$BUILDDIR/config" "$BUILDDIR/$SRCTREE" "$BUILDDIR/poison"

# Extract Source0 (cmssw-config) into config/
# In Bits, sources are in $SOURCEDIR - extract to $BUILDDIR
if [ -f "$SOURCEDIR/cmssw-config-${CONFIGTAG}.tgz" ]; then
  tar -xzf "$SOURCEDIR/cmssw-config-${CONFIGTAG}.tgz" -C "$BUILDDIR"
elif [ -d "$SOURCEDIR/config" ]; then
  cp -r "$SOURCEDIR/config" "$BUILDDIR/"
fi
# Extract Source1 (main source tree) into src/
# This is typically the CMSSW/CORAL source
# Try common names: src.tar.gz, source1.tgz, or SOURCE1 variable
for src_candidate in "$SOURCEDIR/src.tar.gz" "$SOURCEDIR/${SOURCE1:-source1.tgz}"; do
  if [ -f "$src_candidate" ]; then
    tar -xzf "$src_candidate" -C "$BUILDDIR"
    # Rename to srctree if extracted with different name
    [ -d "$BUILDDIR/$SRCTREE" ] || mv "$BUILDDIR"/*/ "$BUILDDIR/$SRCTREE" 2>/dev/null || true
    break
  fi
done
# Fallback: copy if source dir exists
if [ ! -d "$BUILDDIR/$SRCTREE" ] && [ -d "$SOURCEDIR/$SRCTREE" ]; then
  cp -r "$SOURCEDIR/$SRCTREE" "$BUILDDIR/"
fi

# Handle additional sources (additionalSrc0, additionalSrc1) if present
for src in "$SOURCEDIR"/src*.tar.gz; do
  [ -f "$src" ] && tar -xzf "$src" -C "$BUILDDIR/$SRCTREE"
done
sed -i '/<use[[:space:]]*name="boost_filesystem"/a <flags CXXFLAGS="-Wno-error=format-overflow"/>' "$BUILDDIR/src/CoralBase/BuildFile.xml"
sed -i 's/<use   name="python3"\/>/<use   name="Python"\/>/' "$BUILDDIR/src/PyCoral/BuildFile.xml"
sed -i 's/PyUnicode_GET_SIZE/PyUnicode_GET_LENGTH/g' $BUILDDIR/src/PyCoral/src/Attribute.cpp
#find "$BUILDROOT" -name "BuildFile.xml" -exec sed -i 's/name="python3"/name="Python"/g' {} +
# Write config tag
echo "$CONFIGTAG" > "$BUILDDIR/config/config_tag"

# Resolve toolconf variable (e.g., CMSSW_TOOL_CONF_ROOT -> actual path)
TOOLCONF_VAR="${TOOLCONF}"
TOOLCONF_PATH="${!TOOLCONF_VAR:-}"

# Build updateConfig.py arguments
UPDATE_CONFIG_ARGS=(
  -p "$UCPROJTYPE"
  -v "$PKGVERSION-$PKGREVISION"
  -s "$SCRAMV1_VERSION"
  -t "$TOOLCONF_PATH"
  --keys SCRAM_COMPILER="$SCRAM_COMPILER"
  --keys ENABLE_LTO="${ENABLE_LTO:-0}"
)

# Git commit hash for PROJECT_GIT_HASH
if [ -n "${GITCOMMIT:-}" ]; then
  UPDATE_CONFIG_ARGS+=(--keys PROJECT_GIT_HASH="$GITCOMMIT")
else
  UPDATE_CONFIG_ARGS+=(--keys PROJECT_GIT_HASH="$PKGVERSION")
fi

# PGO support (placeholder - skipped for now)
UPDATE_CONFIG_ARGS+=(--keys ENABLE_PGO=0)

# Run updateConfig.py
"$BUILDDIR/config/updateConfig.py" "${UPDATE_CONFIG_ARGS[@]}"

# Clear SCRAM_TARGETS in Self.xml
sed -i -e 's| SCRAM_TARGETS=.*"| SCRAM_TARGETS=""|' "$BUILDDIR/config/Self.xml"

# Add SCRAM_DEFAULT_MICROARCH for non-coral projects
if [ "$PKGNAME" != "coral" ]; then
  if [ -n "${DEFAULT_MICROARCH_NAME:-}" ]; then
    sed -i -e "s|</tool>| <runtime name=\"SCRAM_DEFAULT_MICROARCH\" value=\"$DEFAULT_MICROARCH_NAME\"/>\n</tool>|" "$BUILDDIR/config/Self.xml"
  fi
fi
# Skip vectorization/package_vectorization logic (placeholder)
# TODO: package_vectorization support

# Add release user flags if specified
if [ -n "${RELEASE_USERCXXFLAGS:-}" ]; then
  echo "<flags CXXFLAGS=\"${RELEASE_USERCXXFLAGS}\"/>" >> "$BUILDDIR/config/BuildFile.xml"
fi
if [ -n "${RELEASE_USERLDFLAGS:-}" ]; then
  echo "<flags LDFLAGS=\"${RELEASE_USERLDFLAGS}\"/>" >> "$BUILDDIR/config/BuildFile.xml"
fi

# Apply patches if defined (patchsrc hook)
# TODO: patchsrc hook support - caller can define patches

# Run buildarch if defined
eval "$BUILDARCH"

# Initialize SCRAM project
$SCRAMCMD project -d "$(dirname "$INSTALLROOT")" -b "$BUILDDIR/$BOOTSTRAPFILE"
# =============================================================================
# BUILD SECTION - Compile the project
# =============================================================================

# Remove cmt stuff that brings unwanted dependencies
find "$INSTALLROOT/$SRCTREE" -type d -name cmt -exec rm -rf {} + 2>/dev/null || true

# Fix perl shebangs
grep -r -l -e "^#!.*perl.*" "$INSTALLROOT/$SRCTREE" 2>/dev/null | \
  xargs -r perl -p -i -e 's|^#!.*perl(.*)|#!/usr/bin/env perl$1|' || true

# Show SCRAM architecture
$SCRAMCMD arch

cd "$INSTALLROOT/$SRCTREE"

# Disable biglib if requested
if [ "$ENABLE_BIGLIB" = "0" ]; then
  $SCRAMCMD build disable-biglib || true
fi

# Setup extra tools if specified
if [ -n "${EXTRA_TOOLS:-}" ]; then
  for t in $EXTRA_TOOLS; do
    $SCRAMCMD setup "$t"
  done
fi

# Remove tools if specified
if [ -n "${REMOVE_TOOLS:-}" ]; then
  for t in $REMOVE_TOOLS; do
    $SCRAMCMD tool remove "$t"
  done
fi

# Create and setup cmssw-config tool
cat > "$INSTALLROOT/config/toolbox/$ARCHITECTURE/tools/selected/cmssw-config.xml" <<EOF
<tool name="cmssw-config" version="$CONFIGTAG" revision="1">
</tool>
EOF
$SCRAMCMD setup cmssw-config

# Run buildarch if defined
eval "$BUILDARCH"

# Build environment settings
export BUILD_LOG=yes
export SCRAM_NOPLUGINREFRESH=yes

# Clean before building
$SCRAMCMD b clean

# Disable library checks if requested
if [ -n "${NOLIBCHECKS:-}" ]; then
  export SCRAM_NOLOADCHECK=true
  export SCRAM_NOSYMCHECK=true
fi

# Run pre-build command if defined
if declare -F preBuildCommand &>/dev/null; then
  preBuildCommand
fi

# Echo compiler info
$SCRAMCMD b -r echo_CXX </dev/null

# Run prebuild target if specified
if [ -n "${PREBUILDTARGET:-}" ]; then
  $SCRAMCMD b --verbose -f "$PREBUILDTARGET" </dev/null
fi

# Check for multi-target support
if grep -q 'name="SCRAM_TARGET"' "$INSTALLROOT/config/Self.xml"; then
  touch "$INSTALLROOT/.SCRAM/$ARCHITECTURE/multi-targets"
fi

# Fix boost_python.xml to use "Python" instead of "python3"
#sed -i 's#<use\([[:space:]]\+\)name="python3"\([[:space:]]*\)/>#<use\1name="python"\2/>#g' "$INSTALLROOT/config/toolbox/el9_amd64_gcc14/tools/selected/boost_python.xml"
# Insert <use name="Python"/> into PyCoral/BuildFile.xml
sed -i 's#<use\([[:space:]]\+\)name="python3"\([[:space:]]*\)/>#<use\1name="python"\2/>#g' "$INSTALLROOT/src/LCG/PyCoral/BuildFile.xml"
sed -i '/<use[[:space:]]*name="boost_filesystem"/a <flags CXXFLAGS="-Wno-error=format-overflow"/>' "$INSTALLROOT/src/LCG/CoralBase/BuildFile.xml"
# Main build command
BUILD_FAILED=0
$SCRAMCMD b --verbose -f ${COMPILE_OPTIONS:-} ${EXTRA_OPTIONS:-} ${JOBS:+-j $JOBS} "$BUILDTARGET" </dev/null || {
  BUILD_FAILED=1
  touch "$BUILDDIR/build-errors"
  $SCRAMCMD b -f outputlog || true
  if [ -z "${IGNORE_COMPILE_ERRORS:-}" ]; then
    exit 1
  fi
}

# Run additional build target if specified
if [ -n "${ADDITIONALBUILDTARGET0:-}" ]; then
  $SCRAMCMD b --verbose -f "$ADDITIONALBUILDTARGET0" </dev/null
fi

# Run post-build target if specified
if [ -n "${POSTBUILDTARGET:-}" ]; then
  $SCRAMCMD b --verbose -f "$POSTBUILDTARGET" </dev/null
fi

# Move debug logs to web directory
LOG_WEB_DIR="$WORK_DIR/WEB/build-logs/$ARCHITECTURE/$PKGVERSION"
rm -rf "$LOG_WEB_DIR"
mkdir -p "$LOG_WEB_DIR/logs/src"
if [ -d "$INSTALLROOT/tmp/$ARCHITECTURE/cache/log/src" ]; then
  tar czf "$LOG_WEB_DIR/logs/src/src-logs.tgz" -C "$INSTALLROOT/tmp/$ARCHITECTURE/cache/log/src" ./
fi

# Save dependencies if requested
if [ -n "${SAVEDEPS:-}" ]; then
  mkdir -p "$INSTALLROOT/etc/dependencies"
  SCRAM_TOOL_HOME="$SCRAMV1_ROOT$SCRAM_HOME_SUFFIX" \
    "$INSTALLROOT/config/SCRAM/findDependencies${SCRAM_SCRIPT_PREFIX}" \
    -rel "$INSTALLROOT" -arch "$ARCHITECTURE"
  gzip -f "$INSTALLROOT/etc/dependencies/"*.out 2>/dev/null || true
fi

# Setup runtime environment and run edmPluginRefresh
eval "$($SCRAMCMD run -sh)"
for cmd in edmPluginRefresh; do
  cmdpath=$(command -v "$cmd" 2>/dev/null || echo "")
  if [ -n "$cmdpath" ]; then
    for lib in $CMSSW_LIBS; do
      if [ -d "$INSTALLROOT/$lib" ]; then
        rm -f "$INSTALLROOT/$lib/.edmplugincache"
        "$cmd" "$INSTALLROOT/$lib"
        # TODO: package_vectorization support for arch-specific dirs
      fi
    done
  fi
done

# =============================================================================
# INSTALL SECTION - Finalize installation
# =============================================================================

export SCRAM_ARCH="$ARCHITECTURE"
cd "$INSTALLROOT"

# Run buildarch if defined
eval "$BUILDARCH"

# SCRAM install
$SCRAMCMD install -f

# Re-link externals
rm -rf "external/$ARCHITECTURE"
SCRAM_TOOL_HOME="$SCRAMV1_ROOT$SCRAM_HOME_SUFFIX" \
  ./config/SCRAM/linkexternal${SCRAM_SCRIPT_PREFIX} --arch "$ARCHITECTURE"

# TODO: PartialReleasePackageList hook
# TODO: PatchReleaseSourceSymlinks hook

# Run glimpse indexing if requested
if [ -n "${RUNGLIMPSE:-}" ]; then
  $SCRAMCMD b --verbose -f gindices </dev/null
fi

# TODO: RelocatePatchReleaseSymlinks hook

# Archive source tree and clean up
tar czf "${SRCTREE}.tar.gz" "$SRCTREE"
rm -rf "$SRCTREE" tmp

# Debug symbols handling (subpackageDebug)
if [ -n "${SUBPACKAGEDEBUG:-}" ]; then
  touch "$INSTALLROOT/.SCRAM/$ARCHITECTURE/subpackage-debug"

  if [ "$PKGNAME" = "coral" ]; then
    ELF_DIRS="$INSTALLROOT/$ARCHITECTURE/lib $INSTALLROOT/$ARCHITECTURE/tests/bin"
    DROP_SYMBOLS_DIRS=""
  else
    ELF_DIRS="$INSTALLROOT/lib/$ARCHITECTURE $INSTALLROOT/biglib/$ARCHITECTURE $INSTALLROOT/bin/$ARCHITECTURE $INSTALLROOT/test/$ARCHITECTURE"
    DROP_SYMBOLS_DIRS="$INSTALLROOT/objs/$ARCHITECTURE"
  fi

  # Optimize debug symbols, compress them, and split into separate files
  for DIR in $ELF_DIRS $DROP_SYMBOLS_DIRS; do
    [ -d "$DIR" ] || continue
    pushd "$DIR"
    mkdir -p .debug

    # Find ELF binaries
    ELF_BINS=$(file * 2>/dev/null | grep ELF | cut -d':' -f1 || true)
    if [ -n "$ELF_BINS" ]; then
      # Use dwz to optimize debug info if multiple binaries
      if [ $(echo $ELF_BINS | wc -w) -gt 1 ]; then
        dwz -m .debug/common-symbols.debug -M common-symbols.debug $ELF_BINS || true
      fi
      # Split debug symbols
      echo "$ELF_BINS" | xargs -t -n1 -P${JOBS:-1} -I%% sh -c \
        'objcopy --compress-debug-sections --only-keep-debug %% .debug/%%.debug; objcopy --strip-debug --add-gnu-debuglink=.debug/%%.debug %%'
    fi
    popd
  done

  # Remove debug symbols from drop dirs
  for DIR in $DROP_SYMBOLS_DIRS; do
    rm -rf "$DIR/.debug"
  done
fi

# Symlink relocation for externals
# Convert absolute symlinks to relative ones
for L in $(find "external/$ARCHITECTURE" -type l 2>/dev/null); do
  lnk=$(readlink -n "$L" 2>&1 || true)
  case "$lnk" in
    "$WORK_DIR"/*)
      # Calculate relative path
      rl=$(echo "$L" | sed -e 's|[^/]*/|../|g' | xargs dirname)
      al=$(echo "$lnk" | sed -e "s|^$WORK_DIR/|../../../../$rl/|")
      rm -f "$L"
      ln -sf "$al" "$L"
      ;;
  esac
done

# Debug: show external symlinks
find "external/$ARCHITECTURE" -type l 2>/dev/null | xargs ls -l || true

# TODO: PatchReleaseSymlinkRelocate hook

# Save SCRAM base directory reference
echo "$WORK_DIR" > "$INSTALLROOT/config/scram_basedir"

# =============================================================================
# POST-RELOCATE SCRIPT - SCRAM-specific relocation tasks
# =============================================================================
# This script handles SCRAM-specific tasks that can't be done generically:
#   1. Extract archived src.tar.gz
#   2. Run SCRAM's projectAreaRename script
#   3. Update edmplugincache timestamps
#   4. Create scramrc/*.map files
#   5. Site-specific SCRAM configuration

touch $INSTALLROOT/etc/profile.d/post-relocate.sh

cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<'POSTRELOCATE_EOF'
#!/bin/bash
# SCRAM-specific post-relocate script

cd "$(dirname "$0")/../.."  # Navigate to package root from etc/profile.d/

# Extract source tree if archived (SCRAM archives src during install)
if [ -e src.tar.gz ]; then
  tar xzf src.tar.gz
  rm -f src.tar.gz
fi

# Run SCRAM project area rename (handles SCRAM-internal path references)
if [ -x "./config/SCRAM/projectAreaRename.py" ]; then
  SCRAMVER=$(cat config/scram_version 2>/dev/null || echo "")
  ./config/SCRAM/projectAreaRename.py /cms "$WORK_DIR" "${SCRAM_ARCH:-$ARCHITECTURE}"
fi

# Touch edmplugincache to update timestamps after relocation
for lib in biglib/${SCRAM_ARCH:-$ARCHITECTURE} lib/${SCRAM_ARCH:-$ARCHITECTURE}; do
  [ -f "$lib/.edmplugincache" ] && {
    find "$lib" -name "*.edmplugin" -type f -exec touch {} \;
    touch "$lib/.edmplugincache"
  }
done

# Create SCRAM project map entry
SCRAMRC_DIR="${WORK_DIR}/etc/scramrc"
if [ -n "$PKGNAME" ] && [ ! -f "$SCRAMRC_DIR/${PKGNAME}.map" ]; then
  mkdir -p "$SCRAMRC_DIR"
  UCPROJ=$(echo "$PKGNAME" | sed 's|-patch||' | tr 'a-z' 'A-Z')
  echo "${UCPROJ}=\$SCRAM_ARCH/cms/$PKGNAME/${UCPROJ}_*" > "$SCRAMRC_DIR/${PKGNAME}.map"
fi
POSTRELOCATE_EOF

chmod +x "$INSTALLROOT/etc/profile.d/post-relocate.sh"

# =============================================================================
# BUILD COMPLETE
# =============================================================================
echo "SCRAM project build completed: $PKGNAME $PKGVERSION"
