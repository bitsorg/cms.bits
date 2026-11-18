package: libzmq
version: "4.3.5"
tag: 5bf04ee2ff207f0eaf34298658fe354ea61e1839
variables:
 branch: master
sources: 
-  git+https://github.com/zeromq/libzmq.git?obj=%(branch)s/%(tag_basename)s&export=libzmq-%(version)s&output=/libzmq-%(version)s.tgz
build_requires:
- autotools
requires:
- autotools
- gcc
---
tar -xzf "$SOURCEDIR/$SOURCE0" \
    --strip-components=1 \
    -C "$BUILDDIR"

./autogen.sh

./configure --prefix=$INSTALLROOT \
            --without-docs \
            --enable-libunwind=no \
            --disable-dependency-tracking

make all ${JOBS:+-j $JOBS}
make install
