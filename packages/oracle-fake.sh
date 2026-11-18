package: oracle-fake
version: "11.2.0.3.0__10.2.0.4.0"
variables:
  tag: 6da7ab5b4643b54f57002f9c96c426355a960eb1
sources:
  - https://github.com/cms-externals/%(package)s/archive/%(tag)s.tar.gz
requires:
  - gcc
env:
  ORACLE_HOME: "%(root_dir)s"
prepend_path:
  SQLPATH: "%(root_dir)s/bin"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$INSTALLROOT/bin" "$INSTALLROOT/lib"
cp -r include "$INSTALLROOT/"

g++ -shared -fPIC -o libocci.so occi.cc
g++ -shared -fPIC -o libclntsh.so clntsh.cc
cp *.so "$INSTALLROOT/lib/"

