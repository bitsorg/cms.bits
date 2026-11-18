package: cudnn
version: "9.9.0.52"
requires:
- cuda
- gcc
- zlib
variables:
  cudaversion: "12"
  aarch64_src: "linux-sbsa"
  x86_64_src: "linux-x86_64"
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
- https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/%(selected_src)s/cudnn-%(selected_src)s-%(version)s_cuda%(cudaversion)s-archive.tar.xz
---
tar -xJf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mv $BUILDDIR/lib $INSTALLROOT/lib64
mv $BUILDDIR/*   $INSTALLROOT/
