package: coral-tools
version: "1.0"
sources:
 - https://github.com/akritkbehera/scram-tools.file/archive/refs/tags/SCRAM/CMSSW_16_0_X/g14.tar.gz
variables:
  skipreqtools: jcompiler
  override_microarch: "-march=x86-64-v2"
  package_vectorization: ""
requires:
 - compilation_flags_lto
 - compilation_flags
 - cuda-flags
 - microarch-flag
 - SCRAMV1
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
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"

export UCTOOL=$(echo "$PKG_NAME" | tr 'a-z-' 'A-Z_')

mkdir -p $INSTALLROOT/tools/selected $INSTALLROOT/tools/available

skipreqtools="%(skipreqtools)s"

for tool in $FULL_REQUIRES; do
  echo ">> Copying tool files from: $tool"
  uctool=`echo $tool | tr '[a-z-]' '[A-Z_]'`
  toolbase=$(eval echo \$${uctool}_ROOT)
  toolver=$(eval echo \$${uctool}_VERSION)
  $BUILDDIR/bin/get_tools "$toolbase" "$toolver" $INSTALLROOT "${tool}"
done
$BUILDDIR/bin/get_tools "" "system" $INSTALLROOT "systemtools"

for stool in $(echo $skipreqtools | tr '[A-Z]' '[a-z]') ; do
  [ -f $INSTALLROOT/tools/selected/${stool}.xml ] || continue
  mv $INSTALLROOT/tools/selected/${stool}.xml $INSTALLROOT/tools/available
done

if [ -e $SCRAMV1_ROOT/bin/chktool ] ; then
  touch $INSTALLROOT/errors.log
  find $INSTALLROOT/tools -name '*.xml' -type f | (xargs $SCRAMV1_ROOT/bin/chktool >> $INSTALLROOT/errors.log 2>&1 || true)
  if [ $(grep 'ERROR:' $INSTALLROOT/errors.log | wc -l) -gt 0 ] ; then
    cat $INSTALLROOT/errors.log
    exit 1
  fi
  rm -f $INSTALLROOT/errors.log
fi

echo '<tool name="python-paths" version="1.0" revision="1">' > $INSTALLROOT/tools/selected/python-paths.xml

if [ "${PYTHON3PATH}" != "" ] ; then
  py3List=`echo ${PYTHON3PATH} | tr ':' '\n'`
  mkdir -p $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}
  touch $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/tool-deps.pth
  for pkg in ${py3List} ; do
     echo "adding $pkg"
     echo "$pkg" >> $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/tool-deps.pth
  done
  echo '  <runtime name="PYTHON3PATH"  value="'$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}'" type="path"/>' >> $INSTALLROOT/tools/selected/python-paths.xml
fi

#if [ "${PYTHON2PATH}" != "" ] ; then
#  py2List=`echo ${PYTHON2PATH} | tr ':' '\n'`
#  mkdir -p $INSTALLROOT/${PYTHON2_LIB_SITE_PACKAGES}
#  touch $INSTALLROOT/${PYTHON2_LIB_SITE_PACKAGES}/tool-deps.pth
#  for pkg in ${py2List} ; do
#     echo "adding $pkg"
#     echo "$pkg" >> $INSTALLROOT/${PYTHON2_LIB_SITE_PACKAGES}/tool-deps.pth
#  done
#  echo '  <runtime name="PYTHON2PATH"  value="'$INSTALLROOT/${PYTHON2_LIB_SITE_PACKAGES}'" type="path"/>' >> $INSTALLROOT/tools/selected/python-paths.xml
#fi

for item in PYTHON3PATH:${PYTHON3_LIB_SITE_PACKAGES} PYTHON2PATH:${PYTHON2_LIB_SITE_PACKAGES}; do
  pydir=$(echo $item | sed 's|.*:||')
  dir=$INSTALLROOT/${pydir}/default
  [ -f ${dir}/tool-deps.pth ] ||  continue
  var=$(echo $item | sed 's|:.*||')
  xvar=`echo default_${var} | tr '[a-z-]' '[A-Z_]'`
  echo '  <runtime name="'${xvar}'"  value="'${dir}'" type="path"/>' >> $INSTALLROOT/tools/selected/python-paths.xml
done

echo '</tool>' >> $INSTALLROOT/tools/selected/python-paths.xml

ALL_PY_BIN=""
ALL_PY_BIN_PKGS=""
for pkg in  $(echo $FULL_REQUIRES | tr ' ' '\n' | grep '/py-') ; do
  pk_name=$(echo $pkg | cut -d/ -f2 | tr '[A-Z]' '[a-z]')
  if [ -f $INSTALLROOT/tools/selected/${pk_name}.xml ] ; then continue ; fi
  pk_ver=$(echo $pkg | cut -d/ -f3)
  uctool=`echo ${pk_name} | tr '[a-z-]' '[A-Z_]'`
  echo "<tool name=\"$pk_name\" version=\"$pk_ver\" revision=\"1\">" > $INSTALLROOT/tools/selected/${pk_name}.xml
    set -- $BITS_WORK_DIR/$ARCHITECTURE/$pkg/*/bin
    if [ -e "$1" ] ; then
      for b in $(ls $BITS_WORK_DIR/$ARCHITECTURE/$pkg/*/bin) ; do
        ALL_PY_BIN="${ALL_PY_BIN} ${b}"
        ALL_PY_BIN_PKGS="${ALL_PY_BIN_PKGS} ${b}:${pk_name}"
      done
      echo "  <client>" >> $INSTALLROOT/tools/selected/${pk_name}.xml
      echo "    <environment name=\"${uctool}_BASE\" default=\"$INSTALLROOT/${pk_name}\"/>" >> $INSTALLROOT/tools/selected/${pk_name}.xml
      echo "  </client>" >> $INSTALLROOT/tools/selected/${pk_name}.xml
      echo "  <runtime name=\"PATH\" value=\"\$${uctool}_BASE/bin\" type=\"path\"/>" >> $INSTALLROOT/tools/selected/${pk_name}.xml
    fi
    echo "</tool>" >> $INSTALLROOT/tools/selected/${pk_name}.xml
done
if [ -e $INSTALLROOT/tools/selected/cuda-gcc-support.xml ] ; then
  if [ "$cuda_gcc_support" != "true" ] ; then
    rm -f $INSTALLROOT/tools/selected/cuda-gcc-support.xml
    echo "WARNING: CUDA does not support this GCC version, removing cuda-gcc-support.xml tool file"
  fi
fi

mkdir -p $INSTALLROOT/tools
for type in selected available ; do
  rm -f $INSTALLROOT/tools/${type}.tmpl
  touch $INSTALLROOT/tools/${type}.tmpl
  [ -d $INSTALLROOT/tools/${type} ] || continue
  for xml in $(ls $INSTALLROOT/tools/${type}/*.xml) ; do
    tool=$(basename $xml)
    echo "cat << \\EOF_TOOLFILE >> $INSTALLROOT/tools/${type}/${tool}" >> $INSTALLROOT/tools/${type}.tmpl
    cat $xml            >> $INSTALLROOT/tools/${type}.tmpl
    echo "EOF_TOOLFILE" >> $INSTALLROOT/tools/${type}.tmpl
    echo ""             >> $INSTALLROOT/tools/${type}.tmpl
  done
  #rm -rf $INSTALLROOT/tools/${type}
done
