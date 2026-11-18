package: rocm
version: 6.4.3
variables:
  repoversion:                   "%(version)s"
  distro_major_version:          "9"
  rocm_branch:                   "6.4"
  rocprofiler_register_branch:   release/rocm-rel-%(rocm_branch)s
  rocprofiler_register_tag:      rocm-%(version)s
  rocprofiler_register_pkg:      rocprofiler-register-%(rocprofiler_register_tag)s
  arch:                          "%(platform_machine)s"
  repository:                    repo.radeon.com/rocm/rhel%(distro_major_version)s
build_requires:
 - CMake
 - gmake
requires:
# - rpm
 - numactl
 - zstd
 - fmt
 - Python
 - gcc
sources:
- https://%(repository)s/%(repoversion)s/main/amd-smi-lib-25.5.1.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/comgr-3.0.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hip-devel-6.4.43484.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hip-runtime-amd-6.4.43484.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hipcc-1.1.1.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hsa-rocr-1.15.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hsa-rocr-devel-1.15.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/openmp-extras-devel-18.63.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/openmp-extras-runtime-18.63.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocm-core-6.4.3.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocm-dbgapi-0.77.2.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocm-device-libs-1.0.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocm-llvm-19.0.0.25224.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocm-smi-lib-7.7.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocminfo-1.0.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprim-devel-3.4.1.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-2.0.60403.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-compute-3.1.1.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-devel-2.0.60403.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-docs-2.0.60403.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-plugins-2.0.60403.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-register-0.4.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocprofiler-systems-1.0.2.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hipcub-devel-3.4.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocthrust-devel-3.3.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hiprand-2.12.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/hiprand-devel-2.12.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocrand-3.3.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocrand-devel-3.3.0.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rccl-2.22.3.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rccl-devel-2.22.3.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- https://%(repository)s/%(repoversion)s/main/rocshmem-devel-2.0.1.60403-128.el%(distro_major_version)s.%(arch)s.rpm
- git+https://github.com/ROCm/rocprofiler-register.git?obj=%(rocprofiler_register_branch)s/%(rocprofiler_register_tag)s&export=%(rocprofiler_register_pkg)s&submodules=1&output=/%(rocprofiler_register_pkg)s.tgz
hook_params:
  AutoReq: '1'
---
for i in $(seq 0 31); do
    srcvar="SOURCE$i"
    srcfile=$(eval echo \$$srcvar)
    if [ -f "$SOURCEDIR/$srcfile" ]; then
        echo "Extracting $srcfile..."
        rpm2cpio "$SOURCEDIR/$srcfile" | cpio -idmv
    fi
done

mkdir src

tar -xzf "$SOURCEDIR/${SOURCE32}" \
    -C "$BUILDDIR/src"

sed -i -e 's|add_subdirectory(external)|find_package(fmt REQUIRED)\nadd_subdirectory(external)|' src/%(rocprofiler_register_pkg)s/CMakeLists.txt
if [ "$CXXSTD" != "17" ]; then
  grep -q 'CMAKE_CXX_STANDARD  *17' "src/%(rocprofiler_register_pkg)s/cmake/rocprofiler_register_options.cmake"
  sed -i -e "s|CMAKE_CXX_STANDARD  *17|CMAKE_CXX_STANDARD $CXXSTD|" \
    "src/%(rocprofiler_register_pkg)s/cmake/rocprofiler_register_options.cmake"
fi

mkdir -p build/rocprofiler-register
cd build/rocprofiler-register

cmake $BUILDDIR/src/%(rocprofiler_register_pkg)s -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_CXX_STANDARD=$CXXSTD \
  -DCMAKE_VERBOSE_MAKEFILE=TRUE \
  -DROCPROFILER_REGISTER_BUILD_FMT=OFF \
  -DCMAKE_PREFIX_PATH="${FMT_ROOT}"

make all ${JOBS:+-j$JOBS}
rm -rf $INSTALLROOT
mv $BUILDDIR/opt/rocm-%(version)s/ $INSTALLROOT
rm -rf opt
rm -rf usr
rm -r -f $INSTALLROOT/hip/

ln -s -f amd_detail    $INSTALLROOT/include/hip/hcc_detail
ln -s -f nvidia_detail $INSTALLROOT/include/hip/nvcc_detail

mkdir -p $INSTALLROOT/bin
ln -r -s -f $INSTALLROOT/llvm/bin/amdclang     $INSTALLROOT/bin/
ln -r -s -f $INSTALLROOT/llvm/bin/amdclang++   $INSTALLROOT/bin/
ln -r -s -f $INSTALLROOT/llvm/bin/amdclang-cl  $INSTALLROOT/bin/
ln -r -s -f $INSTALLROOT/llvm/bin/amdclang-cpp $INSTALLROOT/bin/
ln -r -s -f $INSTALLROOT/llvm/bin/amdflang     $INSTALLROOT/bin/
ln -r -s -f $INSTALLROOT/llvm/bin/amdlld       $INSTALLROOT/bin/

cd $BUILDDIR/build/rocprofiler-register
make install

if [ -z "${use_system_gcc}" ]; then
  host_triple=$(gcc -dumpmachine)
  echo "--gcc-toolchain=$GCC_ROOT" > "$INSTALLROOT/llvm/bin/clang++.cfg"
  echo "--target=$host_triple" >> "$INSTALLROOT/llvm/bin/clang++.cfg"
fi
