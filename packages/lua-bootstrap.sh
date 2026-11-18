package: lua-bootstrap
version: "5.4.7"
sources: 
-   http://www.lua.org/ftp/lua-%(version)s.tar.gz
requires:
 - gcc
---
tar xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make -C src all MYLIBS="-ldl" MYCFLAGS="-fPIC -DLUA_USE_POSIX -DLUA_USE_DLOPEN"

make install INSTALL_TOP=$INSTALLROOT
