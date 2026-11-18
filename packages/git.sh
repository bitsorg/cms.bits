package: git
version: "2.49.0"
build_requires:
 - autotools
requires:
 - curl
 - expat
 - zlib
 - pcre2
 - Python
 - gcc
sources:
 - https://github.com/git/git/archive/v%(version)s.tar.gz
 - https://raw.githubusercontent.com/curl/curl/eeed87f0563d3ca73ff53813418d1f9f03c81fe5/scripts/mk-ca-bundle.pl
patches:
 - git-2.19.0-runtime.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -s -i "$SOURCEDIR/$PATCH0"
sed -i -e 's|$(sysconfdir)/git|etc/git|' Makefile

export LDFLAGS=""
export NO_LIBPCRE1_JIT=1

make ${JOBS:+-j$JOBS} configure
./configure prefix=$INSTALLROOT \
	--with-curl=${CURL_ROOT} \
        --with-expat=${EXPAT_ROOT} \
        --with-libpcre=${PCRE2_ROOT} \
        --with-python=$(which python3) \
        --with-zlib=${ZLIB_ROOT}

make ${JOBS:+-j$JOBS} \
  NO_GETTEXT=1 \
  NO_R_TO_GCC_LINKER=1 \
  RUNTIME_PREFIX=1 \
  V=1 \
  NO_CROSS_DIRECTORY_HARDLINK=1 \
  NO_INSTALL_HARDLINKS=1 \
  all

mkdir ./ca-bundle
pushd ./ca-bundle
cp $SOURCEDIR/$SOURCE1 ./mk-ca-bundle.pl
chmod +x ./mk-ca-bundle.pl
./mk-ca-bundle.pl -k
popd

export NO_LIBPCRE1_JIT=1
make ${JOBS:+-j$JOBS} \
  V=1 \
  NO_CROSS_DIRECTORY_HARDLINK=1 \
  NO_INSTALL_HARDLINKS=1 \
  install

mkdir -p $INSTALLROOT/share/ssl/certs
cp ./ca-bundle/ca-bundle.crt $INSTALLROOT/share/ssl/certs/ca-bundle.crt
perl -p -i -e "s|^#!.*python.*|#!/usr/bin/env python3|" $INSTALLROOT/libexec/git-core/git-p4
