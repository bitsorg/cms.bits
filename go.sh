package: go
version: "1.22.5"
variables:
  aarch64_src: "arm64"
  x86_64_src: "amd64"
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
 - https://go.dev/dl/go%(version)s.linux-%(selected_src)s.tar.gz
env:
  PYTHON_VERSION: 3.9.14
  PYTHON_MAJOR_MINOR_VERSION: $(echo $PYTHON_VERSION | cut -d. -f1,2 | sed 's|^v||')
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rsync -a $BUILDDIR/ $INSTALLROOT/
