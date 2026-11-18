package: opencl-cpp
version: "2.0.16"
sources:
 - https://raw.githubusercontent.com/KhronosGroup/OpenCL-CLHPP/v%(version)s/include/CL/opencl.hpp
---
mkdir -p $INSTALLROOT/include/CL
cp $SOURCEDIR/$SOURCE0 $INSTALLROOT/include/CL
