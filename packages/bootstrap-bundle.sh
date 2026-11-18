package: bootstrap-bundle
version: "4.0"
build_requires:
  - sqlite-bootstrap
  - zstd-bootstrap
  - lua-bootstrap
  - file-bootstrap
  - xz-bootstrap
  - libarchive-bootstrap
---
libdir="lib64"
soname="so"
if [[ "$(uname -s)" == "Darwin" ]]; then
    soname="dylib"
fi
USE_SYSTEM_GCC=1

mkdir -p "${INSTALLROOT}"/{bin,lib,include,share,tmp,etc/profile.d}
BUILD_REQUIRED_TOOLS="ZSTD_BOOTSTRAP_ROOT SQLITE_BOOTSTRAP_ROOT LUA_BOOTSTRAP_ROOT FILE_BOOTSTRAP_ROOT XZ_BOOTSTRAP_ROOT LIBARCHIVE_BOOTSTRAP_ROOT"
for var in ${BUILD_REQUIRED_TOOLS}; do
  toolbase="${!var}"
  for sdir in bin lib include; do
    src="${toolbase}/${sdir}"
    dest="${INSTALLROOT}/${sdir}"
    [ -d "${src}" ] || continue
    mkdir -p "${dest}"
    rsync -a --links --ignore-existing "${src}/" "${dest}/"
  done
done
mkdir -p "${INSTALLROOT}/share/misc"
cp ${FILE_BOOTSTRAP_ROOT}/share/misc/magic.mgc  ${INSTALLROOT}/share/misc/magic.mgc
rm -f ${INSTALLROOT}/bin/xml2-config ${INSTALLROOT}/lib/xml2Conf.sh

if [ -z "${USE_SYSTEM_GCC:-}" ]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
        cp -P $GCC_ROOT/lib/lib{stdc++,gcc_s}*.${soname} ${INSTALLROOT}/lib
    else
        cp -P $GCC_ROOT/${libdir}/lib{stdc++,gcc_s,gomp}.${soname}* ${INSTALLROOT}/lib
        cp -P $GCC_ROOT/lib/libelf.${soname}* ${INSTALLROOT}/lib
        cp -P $GCC_ROOT/lib/libelf-*.${soname} ${INSTALLROOT}/lib
        cp -P $GCC_ROOT/lib/libdw.${soname}* ${INSTALLROOT}/lib
        cp -P $GCC_ROOT/lib/libdw-*.${soname} ${INSTALLROOT}/lib
        cp -P $GCC_ROOT/bin/readelf ${INSTALLROOT}/bin
    fi
fi
find ${INSTALLROOT}/lib -type f | xargs chmod 0755

mv ${INSTALLROOT}/lib/lib{lua,archive,zstd}.a ${INSTALLROOT}/tmp
rm -f ${INSTALLROOT}/lib/*.{l,}a
mv ${INSTALLROOT}/tmp/lib* ${INSTALLROOT}/lib/
rm -rf ${INSTALLROOT}/tmp
