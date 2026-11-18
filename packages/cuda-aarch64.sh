package: cuda-aarch64
version: "12.9.0"
variables:
  driversversion: 575.51.03
sources:
 - https://developer.download.nvidia.com/compute/cuda/%(version)s/local_installers/cuda_%(version)s_%(driversversion)s_linux_sbsa.run
---
ARCH=${PKGNAME#*-}
CUDADRIVER_VERSION="%(driversversion)s"
cp "$SOURCEDIR/${SOURCE0}" "$BUILDDIR/"

chmod +x cuda_"$PKGVERSION"_"$CUDADRIVER_VERSION"_linux_sbsa.run

mkdir -p $BUILDDIR/{build,tmp}

CUDA_INSTALL_CMD="/bin/sh cuda_${PKGVERSION}_${CUDADRIVER_VERSION}_linux_sbsa.run \
  --silent \
  --override \
  --tmpdir=${BUILDDIR}/tmp \
  --installpath=${BUILDDIR}/build\
  --toolkit \
  --keep"

$CUDA_INSTALL_CMD

mkdir -p $INSTALLROOT/{include,lib64}

mv $BUILDDIR/build/lib64/libcudadevrt.a $INSTALLROOT/lib64/
mv $BUILDDIR/build/lib64/libcudart_static.a $INSTALLROOT/lib64/
rm -f $BUILDDIR/build/lib64/lib*.a

rm -rf $BUILDDIR/build/lib64/stubs/

rm -f $BUILDDIR/build/lib64/libOpenCL.*

chmod a+x $BUILDDIR/build/lib64/*.so
mv $BUILDDIR/build/lib64/* $INSTALLROOT/lib64/

chmod a-x $BUILDDIR/build/include/*.h*
mv $BUILDDIR/build/include/* $INSTALLROOT/include/

chmod a+x $BUILDDIR/build/extras/CUPTI/lib64/*.so*
mv $BUILDDIR/build/extras/CUPTI/lib64/*.so* $INSTALLROOT/lib64/
mv $BUILDDIR/build/extras/CUPTI/include/*.h $INSTALLROOT/include/

rm -f $BUILDDIR/build/bin/computeprof
rm -f $BUILDDIR/build/bin/cuda-uninstaller
rm -f $BUILDDIR/build/bin/ncu*
rm -f $BUILDDIR/build/bin/nsight*
rm -f $BUILDDIR/build/bin/nsys*
rm -f $BUILDDIR/build/bin/nvvp
mv $BUILDDIR/build/bin $INSTALLROOT/

mv $BUILDDIR/build/share/ $INSTALLROOT/
mv $INSTALLROOT/bin/cuda-gdb $INSTALLROOT/bin/cuda-gdb.real
cat > $INSTALLROOT/bin/cuda-gdb << @EOF
#! /bin/bash
export PYTHONHOME=$PYTHON_ROOT
exec $INSTALLROOT/bin/cuda-gdb.real "\$@"
@EOF
chmod a+x $INSTALLROOT/bin/cuda-gdb

mv $BUILDDIR/build/compute-sanitizer $INSTALLROOT/
rm -f $INSTALLROOT/bin/compute-sanitizer
ln -s ../compute-sanitizer/compute-sanitizer $INSTALLROOT/bin/compute-sanitizer
mv $BUILDDIR/build/nvvm $INSTALLROOT/
/bin/sh $BUILDDIR/pkg/builds/NVIDIA-Linux-${ARCH}-$CUDADRIVER_VERSION.run --silent --extract-only --tmpdir $BUILDDIR/tmp --target $BUILDDIR/build/drivers

mkdir -p $INSTALLROOT/drivers
cp -p $BUILDDIR/build/drivers/libcuda.so.$CUDADRIVER_VERSION                     $INSTALLROOT/drivers/
ln -sf libcuda.so.$CUDADRIVER_VERSION                                             $INSTALLROOT/drivers/libcuda.so.1
ln -sf libcuda.so.1                                                             $INSTALLROOT/drivers/libcuda.so
cp -p $BUILDDIR/build/drivers/libcudadebugger.so.$CUDADRIVER_VERSION             $INSTALLROOT/drivers/
ln -sf libcudadebugger.so.$CUDADRIVER_VERSION                                     $INSTALLROOT/drivers/libcudadebugger.so.1
ln -sf libcudadebugger.so.1                                                     $INSTALLROOT/drivers/libcudadebugger.so
cp -p $BUILDDIR/build/drivers/libnvidia-ptxjitcompiler.so.$CUDADRIVER_VERSION    $INSTALLROOT/drivers/
ln -sf libnvidia-ptxjitcompiler.so.$CUDADRIVER_VERSION                            $INSTALLROOT/drivers/libnvidia-ptxjitcompiler.so.1
ln -sf libnvidia-ptxjitcompiler.so.1                                            $INSTALLROOT/drivers/libnvidia-ptxjitcompiler.so
cp -p $BUILDDIR/build/drivers/libnvidia-nvvm.so.$CUDADRIVER_VERSION              $INSTALLROOT/drivers/
ln -sf libnvidia-nvvm.so.$CUDADRIVER_VERSION                                      $INSTALLROOT/drivers/libnvidia-nvvm.so.4
ln -sf libnvidia-nvvm.so.4                                                      $INSTALLROOT/drivers/libnvidia-nvvm.so
cp -p $BUILDDIR/build/drivers/nvidia-smi                                       $INSTALLROOT/drivers/

mkdir -p $INSTALLROOT/lib64/stubs
cp -p $BUILDDIR/build/drivers/libcuda.so.$CUDADRIVER_VERSION                     $INSTALLROOT/lib64/stubs/
ln -sf libcuda.so.$CUDADRIVER_VERSION                                             $INSTALLROOT/lib64/stubs/libcuda.so.1
ln -sf libcuda.so.1                                                             $INSTALLROOT/lib64/stubs/libcuda.so
cp -p $BUILDDIR/build/drivers/libnvidia-ml.so.$CUDADRIVER_VERSION                $INSTALLROOT/lib64/stubs/
ln -sf libnvidia-ml.so.$CUDADRIVER_VERSION                                        $INSTALLROOT/lib64/stubs/libnvidia-ml.so.1
ln -sf libnvidia-ml.so.1                                                        $INSTALLROOT/lib64/stubs/libnvidia-ml.so