package: classlib
version: 3.1.3
variables:
 tag: b43e382237aa91d7dfcc9ef4d8642c7abd9b08c4
 branch: cms/%(version)s
 github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
requires:
 - pcre
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/cfg/"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"

./configure --prefix=$INSTALLROOT           \
  --without-zlib --without-bz2lib \
  --without-lzma --without-lzo \
  --with-pcre-includes=$PCRE_ROOT/include \
  --with-pcre-libraries=$PCRE_ROOT/lib

perl -p -i -e 's|-lz | |;s|-lbz2| |;s|-lcrypto| |;s|-llzma||' Makefile
perl -p -i -e '
  s{-llzo2}{}g;
  !/^\S+: / && s{\S+LZO((C|Dec)ompressor|Constants|Error)\S+}{}g' \
 Makefile
 
make ${JOBS:+-j$JOBS} CXXFLAGS="-Wno-error=extra -ansi -pedantic -W -Wall -Wno-long-long -Werror -Wno-cast-function-type"
make ${JOBS:+-j$JOBS} install
