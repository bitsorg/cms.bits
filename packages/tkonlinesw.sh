package: tkonlinesw
version: "4.2.0-1_gcc7"
variables:
  projectname: trackerDAQ
  releasename: trackerDAQ-4.2-tkonline
sources:
  - http://cmsrep.cern.ch/cmssw/download/trackerDAQ-4.2.0-1_gcc7.tgz
patches:
  - tkonlinesw-4.0-clang-hash_map.patch
  - tkonlinesw-bring-pvf.patch
  - tkonlinesw-deprecated-warn.patch
requires:
  - oracle
  - xerces-c
  - gmake
  - ROOT
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=0 \
    -C "$BUILDDIR"

cd "$BUILDDIR/%(releasename)s"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
patch -p1 < "$SOURCEDIR/$PATCH2"

rm -rf TrackerOnline/Fed9U/Fed9USoftware/Fed9UUtils/2.4/slc3_ia32_gcc323
perl -p -i -e "s|-Werror||" FecSoftwareV3_0/generic/Makefile

export ENV_TRACKER_DAQ="$BUILDDIR/%(releasename)s/opt/trackerDAQ"
export XDAQ_ROOT="$PWD/FecSoftwareV3_0/generic"
export XDAQ_RPMBUILD=yes
export USBFEC=no
export PCIFEC=yes
export ENV_CMS_TK_BASE="$BUILDDIR/%(releasename)s"
export ENV_CMS_TK_DIAG_ROOT="$BUILDDIR/%(releasename)s/DiagSystem"
export ENV_CMS_TK_ONLINE_ROOT="$BUILDDIR/%(releasename)s/TrackerOnline/"
export ENV_CMS_TK_COMMON="$BUILDDIR/%(releasename)s/TrackerOnline/2005/TrackerCommon/"
export ENV_CMS_TK_XDAQ="$BUILDDIR/%(releasename)s/TrackerOnline/2005/TrackerXdaq/"
export ENV_CMS_TK_APVE_ROOT="$BUILDDIR/%(releasename)s/TrackerOnline/APVe"
export ENV_CMS_TK_FEC_ROOT="$BUILDDIR/%(releasename)s/FecSoftwareV3_0"
export ENV_CMS_TK_FED9U_ROOT="$BUILDDIR/%(releasename)s/TrackerOnline/Fed9U/Fed9USoftware"
export ENV_CMS_TK_ICUTILS="$BUILDDIR/%(releasename)s/TrackerOnline/2005/TrackerCommon/ICUtils"
export ENV_CMS_TK_LASTGBOARD="$BUILDDIR/%(releasename)s/LAS"

mkdir -p "$INSTALLROOT/dummy/Linux/lib"
export ENV_CMS_TK_HAL_ROOT="$INSTALLROOT/dummy/Linux"
export ENV_CMS_TK_CAEN_ROOT="$INSTALLROOT/dummy/Linux"
export ENV_CMS_TK_SBS_ROOT="$INSTALLROOT/dummy/Linux"
export ENV_CMS_TK_TTC_ROOT="$INSTALLROOT/dummy/Linux"

export XDAQ_OS=linux
export XDAQ_PLATFORM=x86_slc4
export ENV_CMS_TK_ORACLE_HOME="${ORACLE_ROOT}"
export ENV_ORACLE_HOME="${ORACLE_ROOT}"
export XERCESCROOT="${XERCES_C_ROOT}"

chmod +x ./configure && ./configure --with-xdaq-platform=x86_64
cd "${ENV_CMS_TK_FEC_ROOT}" && chmod +x ./configure && ./configure --with-xdaq-platform=x86_64 && cd -
cd "${ENV_CMS_TK_FED9U_ROOT}" && chmod +x ./configure && ./configure --with-xdaq-platform=x86_64 && cd -

export CPPFLAGS="-fPIC"
export CFLAGS="-O2 -fPIC"
export CXXFLAGS="-O2 -fPIC"
make cmssw
make cmsswinstall

tar -c -C "$BUILDDIR/%(releasename)s/opt/%(projectname)s" include lib | tar -x -C "$INSTALLROOT"
rm -rf "$INSTALLROOT/dummy"

