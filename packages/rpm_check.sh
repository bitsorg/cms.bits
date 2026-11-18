package: rpm
version: 4.18.0
variables:
 tag: 10c1f38c4c5e4c62a879801e34a0aa042207cd53
 branch: cms/rpm-%(version)s-release
 github_user: cms-externals
 github_repo: rpm-upstream
sources:
    - git://github.com/%(github_user)s/%(github_repo)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
    - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_16_0_X/g14/rpm-set_runpath.file
build_requires:
    - bootstrap-bundle
    - patchelf-bootstrap
    - autotools
env:
    RPM_CONFIGDIR: "%(root_dir)s/libx/rpm"
    RPM_POPTEXEC_PATH: "%(root_dir)s/bin"
    MAGIC: "%(root_dir)s/share/misc/magic.mgc"
---
CMS_BITS_MARCH=$(gcc -dumpmachine)
export disable_rpm="yes"

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv

CFLAGS_PLATF="-fPIC"
if [[ $(uname) == "darwin"* ]]; then
    export CFLAGS_PLATF="-arch x86_64 -fPIC -D_FORTIFY_SOURCE=0"
    export LIBS_PLATF="-liconv"
else
    case "$(uname -m)" in
        aarch64)
            export LIBS_PLATF="-ldl -lrt -pthread"
            ;;
        x86_64)
            export LIBS_PLATF="-ldl"
            ;;
    esac
fi

export USER_CFLAGS="-ggdb -O0"
export USER_CXXFLAGS="-ggdb -O0"

if [[ -n "$GCC_ROOT" && $(uname) == "Linux" ]]; then
    export OS_CFLAGS="-I$GCC_ROOT/include"
    export OS_CXXFLAGS="-I$GCC_ROOT/include"
    export OS_CPPFLAGS="-I$GCC_ROOT/include"
    export OS_LDFLAGS="-L$GCC_ROOT/lib"
fi


perl -p -i -e's|-O2|-O0|' ./configure
./configure \
  --prefix="$INSTALLROOT" \
  --build="$CMS_BITS_MARCH" \
  --host="$CMS_BITS_MARCH" \
  --disable-python \
  --disable-nls \
  --with-archive \
  --disable-rpath \
  --with-crypto=openssl \
  --enable-zstd \
  --enable-ndb=yes \
  --enable-sqlite=yes \
  --localstatedir="$INSTALLROOT/var" \
  --with-lua-lib="$BOOTSTRAP_BUNDLE_ROOT/lib" \
  CXXFLAGS="$USER_CXXFLAGS $OS_CXXFLAGS" \
  CFLAGS="$CFLAGS_PLATF $USER_CFLAGS -I$BOOTSTRAP_BUNDLE_ROOT/include \
          $OS_CFLAGS -I/usr/include/nspr4 -I/usr/include/nss3" \
  LDFLAGS="-L$BOOTSTRAP_BUNDLE_ROOT/lib $OS_LDFLAGS" \
  CPPFLAGS="-I$BOOTSTRAP_BUNDLE_ROOT/include \
            $OS_CPPFLAGS -I/usr/include/nspr4 -I/usr/include/nss3" \
  LIBS="-lnspr4 -lnss3 -lnssutil3 -lplds4 -lbz2 -lplc4 -lz -lpopt \
        -llzma -lsqlite3 -llua -larchive $LIBS_PLATF" \
  ZSTD_CFLAGS="-I$BOOTSTRAP_BUNDLE_ROOT/include" \
  ZSTD_LIBS="-lzstd"

find . -type f -exec sed -i '1s|^#!.*perl\(.*\)|#!/usr/bin/env perl\1|' {} +
find . -type f -exec sed -i '1s|^#!.*python\(.*\)|#!/usr/bin/env python\1|' {} +

make install

rm -rf $INSTALLROOT/share
rm -rf $INSTALLROOT/lib/pkgconfig

perl -p -i -e "s!:/etc/[^:]*!!g;
               s!~/[^:]*!!g" $INSTALLROOT/lib/rpm/rpmrc

# Patch RPM macros for compatibility with rpm 4.3.3
perl -p -i -e '
  s!^.buildroot!#%%buildroot!;
  s!^%%_dbpath.*lib/rpm!%%_dbpath '"$BITS_WORK_DIR"'/'"$ARCHITECTURE"'/'"$PKG_NAME"'/'"$PKG_VERSION-$PKG_REVISION"'/var/lib/rpm!;
  s!^%%_repackage_dir.*/var/spool/repackage!%%_repackage_dir '"$BITS_WORK_DIR"'/'"$ARCHITECTURE"'/'"$PKG_NAME"'/'"$PKG_VERSION-$PKG_REVISION"'/var/spool/repackage!' "$INSTALLROOT/lib/rpm/macros"

# Removes any reference to /usr/lib/rpm in lib/rpm
perl -p -i -e 's|/usr/lib/rpm([^a-zA-Z])|'$INSTALLROOT'/libx/rpm$1|g' \
    $INSTALLROOT/lib/rpm/check-rpaths \
    $INSTALLROOT/lib/rpm/check-rpaths-worker \
    $INSTALLROOT/lib/rpm/find-debuginfo.sh \
    $INSTALLROOT/lib/rpm/rpmdb_loadcvt \
    $INSTALLROOT/lib/rpm/rpmrc \
    $INSTALLROOT/lib/rpm/find-provides \
    $INSTALLROOT/lib/rpm/find-requires

# Changes the shebang from /usr/bin/perl to /usr/bin/env perl
perl -p -i -e 's|^#[!]/usr/bin/perl(.*)|#!/usr/bin/env perl$1|' \
    $INSTALLROOT/lib/rpm/perl.prov \
    $INSTALLROOT/lib/rpm/perl.req \
    $INSTALLROOT/lib/rpm/tcl.req \
    $INSTALLROOT/lib/rpm/osgideps.pl

mkdir -p "$BITS_WORK_DIR"'/'"$ARCHITECTURE"'/'"$PKG_NAME"'/'"$PKG_VERSION-$PKG_REVISION"/var/spool/repackage
perl -p -i -e "s|.[{]prefix[}]|$INSTALLROOT|g" $INSTALLROOT/lib/rpm/macros

#Disabled pythondist requirement checks; we use pip checks to make sure the dependencies are satisfied
perl -p -i -e 's|^%%__pythondist_requires.*|%%__pythondist_requires true|' $INSTALLROOT/lib/rpm/fileattrs/pythondist.attr

# Remove some of the path macros defined in macros since they could come from
# different places (e.g. from system or from macports) and this would lead to
# problems if a developer with macports builds a bootstrap package set.
for shellUtil in tar cat chgrp chmod chown cp file gpg id make mkdir mv pgp rm rsh sed ssh gzip cpio perl unzip patch grep bzip2 xz
    do
        perl -p -i -e "s|^%__$shellUtil\s(.*)|%__$shellUtil       $shellUtil|" $INSTALLROOT/lib/rpm/macros
    done

ln -sf rpm $INSTALLROOT/bin/rpmverify
ln -sf rpm $INSTALLROOT/bin/rpmquery

#rpath settings
#Copy bootstrap/patchelf lib
mv $INSTALLROOT/lib $INSTALLROOT/libx
cp -rf $BOOTSTRAP_BUNDLE_ROOT/bin/* $INSTALLROOT/bin
cp -f $PATCHELF_BOOTSTRAP_ROOT/bin/patchelf $INSTALLROOT/bin
cp $SOURCEDIR/$SOURCE1 $INSTALLROOT/bin/set_runpath
chmod +x $INSTALLROOT/bin/set_runpath
#Copy bootstrap share/lib
cp -rf $BOOTSTRAP_BUNDLE_ROOT/share $INSTALLROOT/share
cp -rf $BOOTSTRAP_BUNDLE_ROOT/lib/* $INSTALLROOT/libx

if [ "$(uname)" = "Darwin" ]; then
    dynamic_path_var="DYLD_FALLBACK_LIBRARY_PATH"
    dynamic_lib_ext="dylib"
else
    dynamic_path_var="LD_LIBRARY_PATH"
    dynamic_lib_ext="so"
fi
MAGIC=$INSTALLROOT/share/misc/magic.mgc \
PATH="$INSTALLROOT/bin:${PATH}" \
$INSTALLROOT/bin/set_runpath \
  --prefix "$BITS_WORK_DIR/$ARCHITECTURE/$PKG_NAME/$PKG_VERSION-$PKG_REVISION/" \
  --package "$INSTALLROOT" \
  -m libx \
  --force-rpath \
  --rpath '$ORIGIN:$ORIGIN/..:$ORIGIN/../libx' \
  --jobs "${JOBS:+-j$JOBS}"

#Create lib/rpm
mkdir -p $INSTALLROOT/lib
for d in lua rpm rpm-plugins ; do ln -sf ../libx/$d $INSTALLROOT/lib/$d ; done
