package: cuda-compatible-runtime
version: "2.0"
variables:
  branch: master
  commit: 8069d15b0979cd4ec5c821960feb066a1e03f8ce
  cuda_arch: "70 75 80 89 90 100 120"
sources:
  - git+https://github.com/cms-patatrack/cuda-compatible-runtime.git?obj=%(branch)s/%(commit)s&export=cuda-compatible-runtime&filter=./test.cu&output=/cuda-compatible-runtime-%(version)s.tgz
requires:
  - cuda
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Inlined from ## INCLUDE cuda-flags (cpp-standard defaults to 20)
CMS_CXX_STANDARD="${CXXSTD:-20}"
nvcc_flags_stdcxx="-std=c++${CMS_CXX_STANDARD}"
nvcc_flags_cuda_archs="$(echo $(for ARCH in %(cuda_arch)s; do echo "-gencode arch=compute_${ARCH},code=[sm_${ARCH},compute_${ARCH}]"; done)) -Wno-deprecated-gpu-targets"

mkdir -p "$BUILDROOT/build"

if $CUDA_ROOT/bin/nvcc $nvcc_flags_stdcxx \
       -O2 -g \
       $nvcc_flags_cuda_archs \
       "$BUILDDIR/test.cu" \
       -I "$CUDA_ROOT/include" \
       -L "$CUDA_ROOT/lib64" \
       -L "$CUDA_ROOT/lib64/stubs" \
       --cudart static -ldl -lrt \
       --compiler-options '-Wall -pthread' \
       -o "$BUILDROOT/build/cuda-compatible-runtime"
then
  true
else
  # CUDA not supported by this architecture or compiler version — install stub
  cat > "$BUILDROOT/build/cuda-compatible-runtime" << 'EOF_STUB'
#!/bin/bash

VERBOSE=false

function usage() {
  cat << EOF_USAGE
Usage: $0 [-h|-v]

Options:
  -h        Print a help message and exits.
  -v        Be more verbose.
EOF_USAGE
}

for ARG in "$@"; do
  case "$ARG" in
  -h)
    usage
    exit 0
    ;;
  -v)
    VERBOSE=true
    ;;
  *)
    echo "$0: invalid option '$ARG'"
    echo
    usage
    exit 1
    ;;
  esac
done

$VERBOSE && echo "CUDA ${CUDA_VERSION} is not compatible with GCC ${GCC_VERSION}"
exit 1
EOF_STUB
  chmod +x "$BUILDROOT/build/cuda-compatible-runtime"
fi

mkdir -p "$INSTALLROOT/test"
cp "$BUILDROOT/build/cuda-compatible-runtime" "$INSTALLROOT/test/"

