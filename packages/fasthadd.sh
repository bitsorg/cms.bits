package: fasthadd
version: "2.4"
variables:
  commit: 972d35c43d210761a9fa31ff6c53490a615a383b
  user:   cms-sw
sources:
  - https://raw.githubusercontent.com/%(user)s/cmssw/%(commit)s/DQMServices/Components/bin/fastHadd.cc
  - https://raw.githubusercontent.com/%(user)s/cmssw/%(commit)s/DQMServices/Core/src/ROOTFilePB.proto
requires:
  - protobuf
  - ROOT
  - gcc
---
mkdir -p "$INSTALLROOT/bin"

cp "$SOURCEDIR/$SOURCE0" "$BUILDDIR/fastHadd.cc"
cp "$SOURCEDIR/$SOURCE1" "$BUILDDIR/ROOTFilePB.proto"

cd "$BUILDDIR"
protoc -I ./ --cpp_out=./ ROOTFilePB.proto
perl -p -i -e 's|DQMServices/Core/interface/||' ROOTFilePB.pb.cc fastHadd.cc

g++ -O2 -o "$INSTALLROOT/bin/fastHadd" ROOTFilePB.pb.cc fastHadd.cc \
    -I${PROTOBUF_ROOT}/include -L${PROTOBUF_ROOT}/lib -lprotobuf \
    $(root-config --cflags --libs)
