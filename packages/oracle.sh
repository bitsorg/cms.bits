package: oracle
version: 19.11.0.0.0dbru
variables:
  aarch64_version: "191000"
  x86_64_version: "1911000"
  selected_version: "%%(%(platform_machine)s_version)s"
  mirror: download.oracle.com/otn_software/linux/instantclient/%(selected_version)s
  aarch64_src: "linux.arm64-%%(version)s"
  x86_64_src: "linux.x64-%%(version)s"
  selected_src: "%%(%(platform_machine)s_src)s"
  occi_lib: "19.1"
sources:
 - https://%(mirror)s/instantclient-basic-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-basiclite-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-jdbc-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-odbc-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-sdk-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-sqlplus-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-tools-%(selected_src)s.zip
 - https://%(mirror)s/instantclient-tools-%(selected_src)s.zip
 - http://cmsrep.cern.ch/cmssw/download/oracle-mirror/x64/libocci.so.19.1.zip
env:
  ORACLE_HOME: $ORACLE_ROOT
prepend_path:
  SQLPATH: $ORACLE_ROOT/bin
requires:
 - gcc
---
export client_dir=instantclient_$(echo "%(version)s" | cut -d. -f1,2 | tr '.' "_")

unzip -o -x $SOURCEDIR/$SOURCE0
unzip -o -x $SOURCEDIR/$SOURCE1
unzip -o -x $SOURCEDIR/$SOURCE2
unzip -o -x $SOURCEDIR/$SOURCE3
unzip -o -x $SOURCEDIR/$SOURCE4
unzip -o -x $SOURCEDIR/$SOURCE5
unzip -o -x $SOURCEDIR/$SOURCE6

if [[ $(uname -m) == "x86_64" ]]; then
  unzip -o -x $SOURCEDIR/$SOURCE7 -d $client_dir
fi

chmod -Rf a+rX,u+w,g-w,o-w $client_dir
cd $client_dir

if [[ $(uname -m) == "aarch64" ]]; then
  chmod +x libocci_gcc53.so.%(occi_lib)s
  ln -sf libocci_gcc53.so.%(occi_lib)s libocci.so.%(occi_lib)s
fi

mkdir -p $INSTALLROOT/{bin,lib,java,demo,include,doc,etc}
#cp $SOURCEDIR/oracle-license   $INSTALLROOT/etc/LICENSE
mv *_LICENSE                      $INSTALLROOT/etc
mv *README*                       $INSTALLROOT/doc
mv lib*                           $INSTALLROOT/lib
mv glogin.sql                     $INSTALLROOT/bin
mv *.jar sdk/*.zip                $INSTALLROOT/java
mv sdk/demo/*                     $INSTALLROOT/demo
mv sdk/include/*                  $INSTALLROOT/include

for f in * sdk/*; do
  [ -f $f ] || continue
  [ -x $f ] || continue
  mv $f $INSTALLROOT/bin
done


mv sdk network help               $INSTALLROOT
cd $INSTALLROOT/lib
for f in lib*.{dylib,so}.[0-9]*; do
  [ -f $f ] || continue
  dest=$(echo $f | sed 's/\.[.0-9]*$//')
  rm -f $dest
  ln -s $f $dest
done
