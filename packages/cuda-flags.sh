package: cuda-flags
version: vCMS
env:
  # build support for Pascal (6.x), Volta (7.0), Turing (7.5), Ampere (8.x), Lovelace (8.9) and Hopper (9.0)
  cuda_arch: "60 70 75 80 89 90"
  # LIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES style for listing the supported CUDA compute architectures
  omptarget_cuda_archs: "$(echo $cuda_arch | sed 's/ /,/g')"
  # LLVM style for listing the supported CUDA compute architectures
  llvm_flags_cuda_archs: "$(for arch in $cuda_arch; do echo -n '--offload-arch=sm_'$arch ; done)-Wunknown-cuda-version"
  # C++ standard to use for building host and device code with nvcc
  nvcc_flags_stdcxx: "-std=c++$CXXSTD"
  # generate optimised code
  nvcc_flags_opt: "-O3"
  # generate debugging information for device code
  nvcc_flags_debug: "--generate-line-info --source-in-ptx --display-error-number"
  # imply __host__, __device__ attributes in constexpr functions
  nvcc_flags_constexpr: "--expt-relaxed-constexpr"
  # allow __host__, __device__ attributes in lambda declarations
  nvcc_flags_lambda: "--extended-lambda"
  # build support for the various compute architectures
  nvcc_flags_cuda_archs: "$(echo $(for arch in $cuda_arch; do echo -n '-gencode arch=compute'+$arch',code=[sm_'$arch',compute_'$arch']' ; done)) -Wno-deprecated-gpu-targets"
  #various cuda diag-suppress flags e.g.
  # 3012: suppress volatile destination type for a compound assignment expression is deprecated
  # 3189: suppress "module" is parsed as an identifier rather than a keyword because the tokens that follow it do not match those of a preprocessor directive
  nvcc_flags_cuda_diag_suppress: "-diag-suppress=3012 -diag-suppress=3189"
  # disable warnings about attributes on defaulted methods
  nvcc_flags_cudage_diag: "-Xcudafe --diag_suppress=esa_on_defaulted_function_ignored"
  # override the version of GCC passed to cudafe++
  override_gnu_version: "$(gcc -dumpfullversion | { IFS=.; read MAJOR MINOR PATCH; echo $(((MAJOR * 100 + MINOR) * 100)); })"
  nvcc_flags_gnu_version: "-Xcudafe --gnu_version=$override_gnu_version"
  # link the CUDA runtime shared library
  nvcc_flags_cudart: "--cudart shared"
  # collect all CUDA flags
  nvcc_cuda_flags: "$(echo $nvcc_flags_stdcxx $nvcc_flags_opt $nvcc_flags_debug $nvcc_flags_constexpr $nvcc_flags_lambda $nvcc_flags_cuda_archs $nvcc_flags_cuda_diag_suppress $nvcc_flags_cudage_diag $nvcc_flags_gnu_version $nvcc_flags_cudart)"
---
