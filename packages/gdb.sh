package: gdb
version: "16.2"
sources:
- https://mirror.ibcp.fr/pub/gnu/gdb/gdb-%(version)s.tar.gz
requires:
 - Python
 - zlib
 - xz
 - expat
 - py-six
 - gcc
patches:
 - gdb-disable-makeinfo.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

patch -p1 < $SOURCEDIR/$PATCH0

rm -rf build; mkdir build; cd build

../configure \
    --prefix="$INSTALLROOT" \
    --disable-rpath \
    --with-system-gdbinit=$INSTALLROOT/share/gdbinit \
    --with-expat=yes \
    --with-libexpat-prefix=${EXPAT_ROOT} \
    --with-zlib=yes \
    --with-python=$PYTHON_ROOT/bin/python3 \
    --with-lzma=yes \
    --with-liblzma-prefix=${XZ_ROOT} \
    LDFLAGS="-L${PYTHON_ROOT}/lib -L${ZLIB_ROOT}/lib -L${EXPAT_ROOT}/lib -L${XZ_ROOT}/lib" \
    CFLAGS="-Wno-error=strict-aliasing -I${PYTHON_ROOT}/include -I${ZLIB_ROOT}/include -I${EXPAT_ROOT}/include -I${XZ_ROOT}/include" \
    MAKEINFO=true

make ${JOBS:+-j$JOBS}
make install

cd $INSTALLROOT/bin/
mv gdb gdb-$PKGVERSION
cat << \EOF_GDBINIT > $INSTALLROOT/share/gdbinit
set substitute-path $INSTALLROOT
EOF_GDBINIT

echo "#!/bin/bash" > gdb
echo "PYTHONHOME=${PYTHON_ROOT} gdb-%(version)s \"\$@\"" >> gdb
chmod +x gdb
