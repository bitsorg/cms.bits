package: heppdt
version: "3.04.01"
variables:
  tag: 2b499cfb4302d48d1fd91911fddec88e94219a44
  branch: cms/%(version)s
  github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
requires:
 - TBB
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/tmp"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
    ls -la "$TMPDIR"/config.{guess,sub}
else
    exit 1
fi
for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_GUESS_FILE"
    cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE"
    chmod +x "$CONFIG_GUESS_FILE"
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_SUB_FILE"
    cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE"
    chmod +x "$CONFIG_SUB_FILE"
done

export cms_cxx="$cms_cxx g++"
export cms_cxxflags="$cms_cxxflags -O2 -std=c++$CXXSTD"

CXX="$cms_cxx" CXXFLAGS="$cms_cxxflags" CPPFLAGS="-I$TBB_ROOT/include" LDFLAGS="-I$TBB_ROOT/lib" ./configure --prefix=$INSTALLROOT

make
make install
