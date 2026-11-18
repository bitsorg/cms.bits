package: crab-pre
version: vCMS_pre
variables:
  version_suffix:     "00"
  crabclient_version: "v3.250522"
  crabserver_version: "v3.250401"
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

bash -ex $(get_file_from_configDir crab-build.sh)
