package:           coral_old
version:           "CORAL_2_3_21"
variables:
  tag:             "4fc6c24175682aff2d4299765b47b603a7b218d2"
  branch:          "cms/CORAL_2_3_21py3"
  github_user:     "cms-externals"
  subpackageDebug: "yes"
  srctree:         "src"
  configtag:       "V09-08-10"
  pgo_generate:    ""
  enable_biglib:   ""
  build_target:    ""
  scram_compiler:  ""
  buildarch:       ""
  ucprojtype:      ""
  configtype:      ""
  toolconf:        ""
  gitcommit:       ""
  pgo_build_flags: ""
  release_usercxxflags: ""
  release_userldflags: ""
  nolibscheck:   ""
  prebuildtarget: ""
  additionalBuildTarget: ""
  postbuildtarget: ""
  saveDeps:       ""
sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
 - git+https://github.com/%(github_user)s/coral.git?protocol=https&obj=%(branch)s/%(tag)s&module=coral&export=%(srctree)s&output=/src.tar.gz
patches:
 - coral-2_3_20-macosx.patch
 - coral-2_3_21-gcc8.patch
build_requires:
 - SCRAMV1
requires:
 - coral-tools
 - coral-tool-conf
 - pcre
 - Python
 - gcc
 - expat
 - boost
 - frontier-client
 - sqlite
 - libuuid
 - zlib
 - bz2lib
 - xerces-c
---
echo $SOURCEDIR
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/${SOURCE1}" -C "$BUILDDIR"
#ADD CHECKS THAT SCRAMV1 exists in REQUIRES OTHERWISE FAIL

export cmssw_libs="biglib/$ARCHITECTURE lib/$ARCHITECTURE"
export scram_home_suffix=$(echo "$REQUIRES" | grep -q /SCRAMV1/V2_ && echo /src || true)
export scram_home_prefix=$(echo "$REQUIRES" | grep -q /SCRAMV1/V2_ && echo .pl || echo .py)
export pkgrel=$ARCHITECTURE/$PKGNAME/$PKGVERSION-$PKGREVISION

# if [[ -z '%(pgo_generate)s' ]]; then
#   unset runGlimpse
#   unset saveDeps
#   unset subpackageDebug
# fi

# Requires: SCRAMV1
# BuildRequires: gcc
# The above two lines are handled outside of this script by the header defining the package.

if [[ -z '%(enable_biglib)s' ]]; then 
  export enable_biglib=1
else
  export enable_biglib='%(enable_biglib)s'
fi

# Detect OS
if [[ -n "%(subpackageDebug)s" ]]; then
  if [[ "$(uname)" == "Linux" ]]; then
    # On Linux, DWZ_ROOT must be defined
    if [[ -z "${DWZ_ROOT:-}" ]]; then
      echo "Error: DWZ_ROOT is required on Linux." >&2
      #exit 1
    fi
  else
    # On non-Linux, remove subpackageDebug
    unset subpackageDebug
  fi
fi

#export initenv
export scramcmd="$SCRAMV1_ROOT/bin/scram --arch $ARCHITECTURE"
export srctree=src

if [[ -z '%(build_target)s' ]]; then
  export build_target="release_build"
else
  export build_target="%(build_target)s"
fi

if [[ -z '%(scram_compiler)s' ]]; then
  export scram_compiler=gcc
else
  export scram_compiler="%(scram_compiler)s"
fi

export bootstrapfile="config/bootsrc.xml"

if [[ -z "%(subpackageDebug)s" ]]; then
  extraOptions="export USER_CXXFLAGS=\"-fdebug-prefix-map=\$BITS_WORK_DIR=/opt/cmssw -g $(usercxxflags)\""
else
  if [[ -z $(usercxxflags) ]]; then
    extraOptions="export USER_CXXFLAGS="
  else
    extraOptions=""
  fi
fi

echo "$extraOptions"

if [[ -z '%(configtag)s' ]]; then
  export configtag='V09-08-10'
else
  export configtag='%(configtag)s'
fi

if [[ -z '%(buildarch)s' ]]; then
  export buildarch=""
fi

if [[ -z "%(ucprojtype)s" ]]; then
    export ucprojtype=$(echo "$PKG_NAME" | sed -e "s|-patch||" | tr 'a-z' 'A-Z')
fi

export lcprojtype=$(echo "$ucprojtype" | tr 'A-Z' 'a-z')

if [[ -z "$toolconf" ]]; then
  varname="$(echo "$PKGNAME" | sed 's|-|_|g' | tr 'a-z' 'A-Z')_TOOL_CONF_ROOT"
  export toolconf="${!varname}"
fi
echo $toolconf
exit 1

#rm -rf config $srctree poison

cd $BUILDDIR
# Write config tag
echo "$configtag" > "$BUILDDIR/config/config_tag"

# Base arguments
args=(
  --keys SCRAM_COMPILER="$scram_compiler"
  --keys ENABLE_LTO="$enable_lto"
)

# Git commit logic
if [[ -z "%(gitcommit)s" ]]; then
  args+=( --keys PROJECT_GIT_HASH="%(version)s" )
else
  args+=( --keys PROJECT_GIT_HASH="%(gitcommit)s" )
fi

# PGO flags logic
if [[ -z "%(pgo_build_flags)s" ]]; then
  args+=( --keys ENABLE_PGO=0 )
else
  args+=( --keys ENABLE_PGO=1 )
fi

# Run the update config script
"$BUILDDIR/config/updateConfig.py" \
  -p $ucprojtype \
  -v "$PKG_VERSION" \
  -s "$SCRAMV1_VERSION" \
  -t "$toolconf" \
  "${args[@]}"

sed -i -e 's| SCRAM_TARGETS=.*"| SCRAM_TARGETS=""|' $BUILDDIR/config/Self.xml
if [[ $PKG_NAME == "CORAL" ]]; then
  sed -i -e "s|</tool>|<runtime name=\"SCRAM_DEFAULT_MICROARCH\" value=\"$default_microarch_name\"/>\\
</tool>|" "$BUILDDIR/config/Self.xml"
fi

if [[ -n '%(release_usercxxflags)s' ]]; then
  release_usercxxflags='%(release_usercxxflags)s'
  echo "<flags CXXFLAGS=\"${release_usercxxflags}\"/>" >> "$BUILDDIR/config/BuildFile.xml"
fi

if [[ -n '%(release_userldflags)s' ]]; then
  release_userldflags='%(release_userldflags)s'
  echo "<flags LDFLAGS=\"${release_userldflags}\"/>" >> "$BUILDDIR/config/BuildFile.xml"
fi

# rm -rf $INSTALLROOT
# mkdir -p $INSTALLROOT
$scramcmd project -d $INSTALLROOT -b $bootstrapfile
# %if "%{?pgo_build_flags}"
# sed -i -e 's|@LOCALTOP@|%{i}|' %i/config/toolbox/%{cmsplatf}/tools/selected/gcc-cxxcompiler.xml
# %endif

# Remove cmt stuff that brings unwanted dependencies:
rm -rf `find $INSTALLROOT/$PKGNAME_$PKGVERSION/$srctree -type d -name cmt`
#grep -r -l -e "^#!.*perl.*" $INSTALLROOT/$PKGNAME_$PKGVERSION/$srctree | xargs perl -p -i -e "s|^#!.*perl(.*)|#!/usr/bin/env perl\$1|"


if [[ -z "%(subpackageDebug)s" ]]; then
  export subpackageDebug="%(subpackageDebug)s"
fi

# %if "%{package_vectorization}"
# %if "%{?scram_target_default:set}" != "set"
# %define scram_target_default auto
# %endif
# %endif
# if [ "%{n}" != "coral" ]; then
#   if [ -e ${%{toolconf}}/vectorized_packages.txt ] ; then
#     sed -i -e 's| SCRAM_TARGETS=.*"| SCRAM_TARGETS="%{package_vectorization}"|' %_builddir/config/Self.xml
#     sed -i -e 's|</tool>| <runtime name="SCRAM_MIN_SUPPORTED_MICROARCH" value="%{default_microarch_name}"/>\n</tool>|' %_builddir/config/Self.xml
#     sed -i -e 's|</tool>| <runtime name="SCRAM_TARGET" value="%{scram_target_default}"/>\n <runtime name="USER_TARGETS_ALL" value="1"/>\n</tool>|' %_builddir/config/Self.xml
#   fi
# fi

# %{?PartialBootstrapPatch:%PartialBootstrapPatch}
# %{?patchsrc:%patchsrc}
# %{expand:%(for i in {2..20..1} ; do echo %%{?patchsrc$i:%%patchsrc$i}; done)}

$scramcmd arch
cd $INSTALLROOT/$PKGNAME_$PKGVERSION/$srctree
if [[ $enable_biglib == 0 ]]; then
  $scramcmd build disable-biglib || true
fi

if [[ -z $extra_tools ]]; then
  for t in $extra_tools; do
    $scramcmd tool remove $t; done
fi

echo -e "<tool name=\"cmssw-config\" version=\"$configtag\" revision=\"1\">\n</tool>" > "$INSTALLROOT/$PKGNAME_$PKGVERSION/config/toolbox/$ARCHITECTURE/tools/selected/cmssw-config.xml"
$scramcmd setup cmssw-config

if [[ -z '%(buildarch)s' ]]; then
  export buildarch='%(buildarch)s'
fi

export BUILD_LOG=yes
export SCRAM_NOPLUGINREFRESH=yes

$scramcmd b clean

if [[ $(uname)==Darwin ]]; then
  $scramcmd b echo_null
  eval `$scramcmd runtime -sh`
  export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH
fi

if [[ -z '%(nolibscheck)s' ]]; then
  export SCRAM_NOLOADCHECK=true
  export SCRAM_NOSYMCHECK=true
fi

if declare -F preBuildCommand >/dev/null 2>&1; then
  echo ">>>Running preBuildCommand...<<<"
  preBuildCommand
fi

$scramcmd b -r echo_CXX </dev/null

# %{?PatchReleasePythonSymlinks:%PatchReleasePythonSymlinks}

if [[ -n "%(prebuildtarget)s" ]]; then
  $scramcmd b --verbose -f '%(prebuildtarget)s' </dev/null
fi

# %if "%{?pgo_generate:set}" != "set"
# case %{n} in (cmssw|cmssw-patch) %scramcmd b -f -k %{makeprocesses} llvm-ccdb </dev/null || true ;; esac
# %endif
# if grep 'name="SCRAM_TARGET"' %{i}/config/Self.xml ; then
#   touch %{i}/.SCRAM/%{cmsplatf}/multi-targets
# fi
# %scramcmd b --verbose -f %{compileOptions} %{extraOptions} %{makeprocesses} %{buildtarget} </dev/null || { touch ../build-errors && %scramcmd b -f outputlog && [ "%{?ignore_compile_errors:set}" == "set" ]; }

if [[ -n '%(additionalBuildTarget)s' ]]; then
  $scramcmd b --verbose -f '%(additionalBuildTarget)s' </dev/null
fi

if [[ -n '%(postbuildtarget)s' ]]; then
  $scramcmd b --verbose -f '%(postbuildtarget)s' </dev/null
fi

# Move the debug logs into the builddir, so that they do not get packaged.
# LOG_WEB_DIR=%cmsroot/WEB/build-logs/%{cmsplatf}/%{v}
# rm -rf ${LOG_WEB_DIR}
# mkdir -p ${LOG_WEB_DIR}/logs/src
# if [ -d %{i}/tmp/%{cmsplatf}/cache/log/src ]; then
#   pushd %{i}/tmp/%{cmsplatf}/cache/log/src
#     tar czf ${LOG_WEB_DIR}/logs/src/src-logs.tgz ./
#   popd
# fi

#if [[ -z '%(saveDeps)s' ]]; then
#  mkdir -p $INSTALLROOT/$PKGNAME_$PKGVERSION/etc/dependencies
#  SCRAM_TOOL_HOME=$SCRAMV1_ROOT${scram_home_prefix} $INSTALLROOT/$PKGNAME_$PKGVERSION/config/SCRAM/findDependencies${scram_script_prefix} -rel $INSTALLROOT/$PKGNAME_$PKGVERSION -arch $ARCHITECTURE
#  gzip -f $INSTALLROOT/$PKGNAME_$PKGVERSION/etc/dependencies/*.out
#fi

eval `$scramcmd run -sh`
for cmd in edmPluginRefresh ; do
  cmdpath=`which $cmd 2> /dev/null || echo ""`
  if [ "X$cmdpath" != X ] ; then
    for lib in ${cmssw_libs} ; do
      if [ -d $INSTALLROOT/$PKGNAME_$PKGVERSION/$lib ] ; then
        rm -f $INSTALLROOT/$PKGNAME_$PKGVERSION/$lib/.edmplugincache
        $cmd $INSTALLROOT/$PKGNAME_$PKGVERSION/$lib
  # if "%{package_vectorization}"
  #       for arch in %{package_vectorization} ; do
  #         arch_dir=$INSTALLROOT/$lib/scram_${arch}
  #         [ -d ${arch_dir} ] || continue
  #         rm -f ${arch_dir}/.edmplugincache
  #         if [ -e $INSTALLROOT/$lib/.edmplugincache ] ; then
  #           cp $INSTALLROOT/$lib/.edmplugincache ${arch_dir}/.edmplugincache
  #         fi
  #       done
  # fi
      fi
    done
  fi
done

###<<<<INSTALL>>>>>###
export SCRAM_ARCH=$ARCHITECTURE
cd $INSTALLROOT/$PKGNAME_$PKGVERSION
$scramcmd install -f
#rm -rf external/$ARCHITECTURE; SCRAM_TOOL_HOME=$SCRAMV1_ROOT${scram_home_prefix} ./config/SCRAM/linkexternal${scram_script_prefix} --arch $ARCHITECTURE


# %{?PartialReleasePackageList:%PartialReleasePackageList}
# %{?PatchReleaseSourceSymlinks:%PatchReleaseSourceSymlinks}


tar czf ${srctree}.tar.gz ${srctree}
rm -fR ${srctree} tmp

if [[ -z '%(subpackageDebug)s' ]]; then
  touch $INSTALLROOT/$PKGNAME_$PKGVERSION/.SCRAM/$ARCHITECTURE/subpackage-debug
fi
if [ $PKGNAME == "coral" ]; then
  ELF_DIRS="$INSTALLROOT/$PKGNAME_$PKGVERSION/$ARCHITECTURE/lib $INSTALLROOT/$ARCHITECTURE/tests/bin"
  DROP_SYMBOLS_DIRS=""
else
  ELF_DIRS="$INSTALLROOT/$PKGNAME_$PKGVERSION/$ARCHITECTURE/lib $INSTALLROOT/$PKGNAME_$PKGVERSION/$ARCHITECTURE/biglib $INSTALLROOT/$PKGNAME_$PKGVERSION/$ARCHITECTURE/bin $INSTALLROOT/$PKGNAME_$PKGVERSION/$ARCHITECTURE/test"
  DROP_SYMBOLS_DIRS="$INSTALLROOT/$PKGNAME_$PKGVERSION/$ARCHITECTURE/objs"
fi

#optimise the debug symbols, compress them and split them into separate file
for DIR in $ELF_DIRS $DROP_SYMBOLS_DIRS; do
  pushd $DIR
  mkdir -p .debug
  # ELF binaries
  ELF_BINS=$(file * | grep ELF | cut -d':' -f1)
  if [ ! -z "$ELF_BINS" ]; then
    if [ $(echo $ELF_BINS | wc -w) -gt 1 ] ; then
      dwz -m .debug/common-symbols.debug -M common-symbols.debug $ELF_BINS || true
    fi
    #echo "$ELF_BINS" | xargs -t -n1 -P%{compiling_processes} -I% sh -c 'objcopy --compress-debug-sections --only-keep-debug % .debug/%.debug; objcopy --strip-debug --add-gnu-debuglink=.debug/%.debug %'
  fi
  popd
done

for DIR in $DROP_SYMBOLS_DIRS; do
  rm -rf $DIR/.debug
done

rm -f $BUILDDIR/files.debug $BUILDDIR/files
touch $BUILDDIR/files.debug $BUILDDIR/files
for DIR in $ELF_DIRS; do
  DIR=$(echo "$DIR" | sed "s|^$INSTALLROOT/$PKGNAME_$PKGVERSION/|/opt/cmssw/$ARCHITECTURE/$PKGNAME/$PKGVERSION-$PKGREVISION/|")
  echo "%exclude $DIR/.debug" >> "$BUILDDIR/files"
  echo "$DIR/.debug"          >> "$BUILDDIR/files.debug"
done

cd $INSTALLROOT/$PKGNAME_$PKGVERSION/
if [[ -e $srctree.tar.gz ]]; then
  tar -xzf $srctree.tar.gz
  rm -rf $srctree
fi

scramver=`cat config/scram_version`
#SCRAMV1_ROOT=$BITS_WORK_DIR/$ARCHITECTURE/SCRAMV1/$scramver


scram_patches() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    patchsrc2="perl -p -i -e 's!(<classpath.*/tests\\+.*>)!!;' config/BuildFile.xml"
    patchsrc3='patch -p1 -s -i "$SOURCEDIR/$PATCH0"'
  fi

  if [[ "$(uname -m)" == "x86_64" ]]; then
    patchsrc2='rm -rf ./src/OracleAccess'
  fi

  patchsrc4='patch -p1 -s -i "$SOURCEDIR/$PATCH1"'
}

#source scram-project-build.sh
