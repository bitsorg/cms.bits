package: conifer
version: "1.7"
sources: 
 - https://github.com/thesps/%(package)s/archive/v%(version)s.tar.gz
requires:
 - json
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p $INSTALLROOT/include/
cp conifer/backends/cpp/include/conifer.h     $INSTALLROOT/include/
