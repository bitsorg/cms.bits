package: Python
version: "3.12.4"
tag: "v%(version)s"
source: https://github.com/python/cpython
requires:
 - expat
 - bz2lib
 - db6
 - gdbm
 - libffi
 - zlib
 - sqlite
 - xz
 - libuuid
 - gcc
env:
  PYTHON_MAJOR_MINOR_VERSION: $(echo $PYTHON_VERSION | cut -d. -f1,2 | sed 's|^v||')
  PYTHON_MAJOR_MINOR_STR: $(echo $PYTHON_VERSION | cut -d. -f1,2 | sed 's|^v||' | sed 's|\.||')
  PYTHON3_LIB_SITE_PACKAGES: "lib/python$(echo $PYTHON_VERSION | cut -d. -f1,2 | sed 's|^v||')/site-packages"
---
export DB6_ROOT

export LIBFFI_ROOT

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/;

mkdir -p "${INSTALLROOT}"/{include,lib,bin};

LDFLAGS=""
CPPFLAGS=""
for d in ${EXPAT_ROOT} ${BZ2LIB_ROOT} ${DB6_ROOT} ${GDBM_ROOT} ${LIBFFI_ROOT} ${ZLIB_ROOT} ${SQLITE_ROOT} ${XZ_ROOT} ${LIBUUID_ROOT}; do
    if [[ -n "$d" ]]; then
        if [[ -e "$d/lib" ]]; then
            LDFLAGS="$LDFLAGS -L$d/lib"
        fi
        if [[ -e "$d/lib64" ]]; then
            LDFLAGS="$LDFLAGS -L$d/lib64"
        fi
        if [[ -e "$d/include" ]]; then
            CPPFLAGS="$CPPFLAGS -I$d/include"
        fi
    fi
done

export CPPFLAGS
export LDFLAGS=" $LDFLAGS -Wl,-rpath,'\$\$ORIGIN/../lib' -z origin -Wl,--enable-new-dtags"

LDFLAGS="$LDFLAGS" CPPFLAGS="$CPPFLAGS" ./configure \
    --prefix="$INSTALLROOT" \
    --enable-shared \
    --enable-ipv6 \
    --with-system-ffi \
    --without-ensurepip \
    --with-system-expat

make ${JOBS:+-j $JOBS}
make install


pythonv=$(echo ${PKGVERSION} | sed 's|^v||' | cut -d. -f 1,2)
python_major=$(echo ${pythonv} | cut -d. -f 1)

# Create symlink so python3 points to our custom python
ln -sf "$INSTALLROOT/bin/python${pythonv}" "$INSTALLROOT/bin/python${python_major}"

# After install, ensure our Python is used
export PATH="$INSTALLROOT/bin:$PATH"
export PYTHONHOME="$INSTALLROOT"
export PYTHONPATH="$INSTALLROOT/lib/python${pythonv}/site-packages"

# Check which Python is being picked up
which python${python_major}
python${python_major} --version
python${python_major} -c 'import sys; print(sys.executable)'

sed -i -e "s|^#!.*python${pythonv} *$|#!/usr/bin/env python${python_major}|" ${INSTALLROOT}/bin/* ${INSTALLROOT}/lib/python${pythonv}/*.py
sed -i -e "s|^#!/.*|#!/usr/bin/env python${pythonv}m|" ${INSTALLROOT}/lib/python${pythonv}/config-*/python-config.py
sed -i -e "s|^#! */usr/local/bin/python|#!/usr/bin/env python|" ${INSTALLROOT}/lib/python${pythonv}/cgi.py

# is executable, but does not start with she-bang so not valid
# executable; this avoids problems with rpm 4.8+ find-requires
#find ${INSTALLROOT} -name '*.py' -perm +0111 | while read f; do
#  if head -n1 $f | grep -q '"'; then chmod -x $f; else :; fi
#done

# Remove .pyo files
find ${INSTALLROOT} -name '*.pyo' -exec rm {} \;

# Remove documentation, examples and test files.
#rm -rf ${INSTALLROOT}/share ${INSTALLROOT}/lib/python${pythonv}/test ${INSTALLROOT}/lib/python${pythonv}/distutils/tests ${INSTALLROOT}/lib/python${pythonv}/lib2to3/tests

echo "from os import environ" > ${INSTALLROOT}/lib/python${pythonv}/sitecustomize.py
echo "if 'PYTHON3PATH' in environ:" >> ${INSTALLROOT}/lib/python${pythonv}/sitecustomize.py
echo "   import os,site" >> ${INSTALLROOT}/lib/python${pythonv}/sitecustomize.py
echo "   for p in environ['PYTHON3PATH'].split(os.pathsep):">> ${INSTALLROOT}/lib/python${pythonv}/sitecustomize.py
echo "       site.addsitedir(p)">> ${INSTALLROOT}/lib/python${pythonv}/sitecustomize.py
