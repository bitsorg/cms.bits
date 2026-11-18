package: crab-prod
version: vCMS_prod
variables:
  version_suffix:     "00"
  crabclient_version: "v3.250820"
  crabserver_version: "v3.250818"
  crabserver_packages: ""
sources:
  - git://github.com/dmwm/CRABClient.git?obj=master/%(crabclient_version)s&export=CRABClient&output=/CRABClient-%(crabclient_version)s.tar.gz
  - git://github.com/dmwm/CRABServer.git?obj=master/%(crabserver_version)s&export=CRABServer&output=/CRABServer-%(crabserver_version)s.tar.gz
architecture: shared
---

if [ -n "%(crabserver_packages)s" ]; then
  export crabserver_packages=%(crabserver_packages)s
else
  export crabserver_packages="ServerUtilities.py"
fi

export crab_type=$(echo $PKG_NAME | sed -e 's|crab-||')
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/${SOURCE1}" -C "$BUILDDIR"

#Copy CRABClient
rsync -a "$BUILDDIR/CRABClient/src/python/" "$INSTALLROOT/lib/"
sed -i -e 's|"development"|"%(crabclient_version)s"|' "${INSTALLROOT}/lib/CRABClient/__init__.py"
rsync -a "$BUILDDIR/CRABClient/bin/" "$INSTALLROOT/bin/"
rsync -a "$BUILDDIR/CRABClient/etc/" "$INSTALLROOT/etc/"

#List of CRAB python packages for which we need to create ProxyPackage symlink
ls "${BUILDDIR}/CRABClient/src/python/"*"/__init__.py" | sed 's|/__init__.py$||;s|.*/||' > "${INSTALLROOT}/etc/crab_py_pkgs.txt"
echo dbs >> "${INSTALLROOT}/etc/crab_py_pkgs.txt"
echo RestClient >> "${INSTALLROOT}/etc/crab_py_pkgs.txt"

#Create fake WMCore
mkdir "${INSTALLROOT}/lib/WMCore"
cp "${BUILDDIR}/CRABClient/src/python/CRABClient/WMCoreConfiguration.py" "${INSTALLROOT}/lib/WMCore/Configuration.py"
touch "${INSTALLROOT}/lib/WMCore/__init__.py"

#Copy CRABServer
for pkg in $crabserver_packages; do
  if [ -d $BUILDDIR/CRABServer/src/python/$pkg ]; then
    rsync -a $BUILDDIR/CRABServer/src/python/$pkg/ "$INSTALLROOT/lib/"
  else
    cp -a $BUILDDIR/CRABServer/src/python/$pkg "$INSTALLROOT/lib/"
  fi
done

#complete command in crab-bash-completion.sh should match '^\s*complete\s+-F\s+.*\s<Crab-function-Name>\s.*\scrab\s*$'
COMPLETE_CMD=$(grep '^\s*complete\s\s*-F\s' "${INSTALLROOT}/etc/crab-bash-completion.sh" | grep '\scrab\s*$' | sed 's|-o\s\s*nosort||')
if [ "${COMPLETE_CMD}" != "" ] ; then
  CRAB_FUNC=$(echo "${COMPLETE_CMD}" | sed 's|^.*\s-F\s\s*||;s|\s.*||')
  sed -i -e 's|^\s*complete\s\s*-F\s.*$|@COMPLETE_CMD@|' "${INSTALLROOT}/etc/crab-bash-completion.sh"
  if [ $crab_type == "prod" ]; then
    COMPLETE_CMD=$(echo "${COMPLETE_CMD}" | sed "s/\scrab\s*$/ crab-${crab_type}\\\n${COMPLETE_CMD}/")
  else
    COMPLETE_CMD=$(echo "${COMPLETE_CMD}" | sed "s/\scrab\s*$/ crab-${crab_type}/")
  fi
  sed -i -e "s/@COMPLETE_CMD@/${COMPLETE_CMD}/;s|${CRAB_FUNC}|${CRAB_FUNC}_${crab_type}|g" "${INSTALLROOT}/etc/crab-bash-completion.sh"
else
  echo "ERROR: Unable to fix crab use function _UseCrab"
  exit 1
fi
