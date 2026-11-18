package: tkonlinesw-fake
version: "4.2.0-1_gcc7"
variables:
  tag: 97afe74471b299148ac9ccdea21e9cda961ec885
sources:
  - https://github.com/cms-externals/%(package)s/archive/%(tag)s.tar.gz
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$INSTALLROOT/lib"
cp -r include "$INSTALLROOT/"

g++ -shared -fPIC -o libDeviceDescriptions.so DeviceDescriptions.cc
g++ -shared -fPIC -o libFed9UDeviceFactory.so Fed9UDeviceFactory.cc
g++ -shared -fPIC -o libICUtils.so ICUtils.cc
g++ -shared -fPIC -o libFed9UUtils.so Fed9UUtils.cc
cp *.so "$INSTALLROOT/lib/"
