package: rocm-flags
version: vCMS
env:
    # define the ROCm compilation flags in a way that can be shared by SCRAM-based and regular tools
    # build support for Instinct MI100 (gfx908), Instinct MI210/MI250X (gfx90a), Instinct MI300X (gfx942), Radeon Pro W6800 (gfx1030), 
    # Radeon Pro W7800/W7900 (gfx1100), and Radeon Pro W7600 (gfx1102)
  rocm_archs: "gfx908:sramecc+ gfx90a:ramecc+ gfx942sramecc+ gfx1030 gfx1100 gfx1102"
    # LLVM/hipcc style for listing the supported ROCm compute architectures
  hipcc_flags_rocm_archs: "$(echo $(for arch in $rocm_archs; do echo -n '--amdgpu-target='$arch' ' ; done))"
    # all ROCm flags
  rocm_flags: "$(echo $hipcc_flags_rocm_archs)"
---