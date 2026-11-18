package: tensorflow-sources
version: "2.17.0"
variables:
  tag: 4bc8eb2ebed6a8c02a3446f2541b6ed396a95cdf
  branch: cms/v%%(version)s
  github_user: cms-externals
  build_type: "opt"
  pythonOnly: "no"
  enable_gpu: "0"
sources:
 - git+https://github.com/%(github_user)s/tensorflow.git?obj=%(branch)s/%(tag)s&export=tensorflow-%(version)s&output=/tensorflow-%(version)s.tgz
patches:
 - tensorflow-gcc14-aarch64.patch
build_requires:
 - bazel
 - java-env
 - git
requires:
 - Python
 - py-numpy
 - py-pybind11
 - py-mock
 - py-typing-extensions
 - py-keras-applications
 - py-keras-preprocessing
 - py-future
 - py-wrapt
 - py-gast
 - setuptools
 - py-cython
 - py-protobuf
 - py-astor
 - py-six
 - py-termcolor
 - py-absl-py
 - py-opt-einsum
 - py-flatbuffers
 - eigen
 - protobuf
 - zlib
 - libpng
 - libjpeg-turbo
 - curl
 - giflib
 - sqlite
 - py-wheel
 - cuda
 - cudnn
 - grpc
 - flatbuffers
---
export PYTHON_MAJOR_MINOR_VERSION="3.12"
export CXXSTD=20
export USER="builder"

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i -e "s|lib/python[^/]*/site-packages/|lib/python$PYTHON_MAJOR_MINOR_VERSION/site-packages/|" third_party/systemlibs/pybind11.BUILD
sed -i -e "s|site-packages/pybind11\"|site-packages/pybind11/include\"|g" third_party/systemlibs/pybind11.BUILD

export pythonOnly="${pythonOnly:-no}"
export build_type="${build_type:-opt}"
export MAJOR_VERSION=$(echo "$PKG_VERSION" | cut -d. -f1)
export PYTHON_BIN_PATH="$(which python3)"
export USE_DEFAULT_PYTHON_LIB_PATH=1
export GCC_HOST_COMPILER_PATH="$(which gcc)"
export CC_OPT_FLAGS="-Wno-sign-compare"
export BAZEL_OPTS="--batch --output_user_root ../build"

if [ $(${JAVA_HOME}/bin/java -version 2>&1 | grep -E -i 'openjdk version "[1-9]' | sed -E 's|.* "([0-9]+)[.].*|\1|') -ge 17 ] ; then
BAZEL_OPTS="$BAZEL_OPTS --host_jvm_args=--add-opens=java.base/java.nio=ALL-UNNAMED"
BAZEL_OPTS="$BAZEL_OPTS --host_jvm_args=--add-opens=java.base/java.lang=ALL-UNNAMED"
fi

BAZEL_OPTS="$BAZEL_OPTS build -s --verbose_failures --distinct_host_configuration=false"

if [[ -n "$selected_microarch" ]]; then
  BAZEL_OPTS="$BAZEL_OPTS --copt=$selected_microarch"
  BAZEL_OPTS="$BAZEL_OPTS --copt=-DEIGEN_USE_AVX512_GEMM_KERNELS=0"

  if [[ "$selected_microarch" != "$default_microarch" ]]; then
    BAZEL_OPTS="$BAZEL_OPTS --distinct_host_configuration=true"
  fi
fi

if [[ -n "$arch_build_flags" ]]; then
  BAZEL_OPTS+=" $(for f in $arch_build_flags; do echo --copt=$f; done)"
fi

BAZEL_OPTS+=" --config=$build_type \
  --cxxopt=-std=c++$CXXSTD \
  --host_cxxopt=-std=c++$CXXSTD \
  --jobs=${JOBS:-$(nproc)}"

BAZEL_OPTS+=" --config=noaws --config=nogcp --config=nohdfs --config=nonccl"
BAZEL_OPTS+=" --action_env=PYTHONPATH"
BAZEL_OPTS+=" --action_env=TF_PYTHON_VERSION=3.12"

if [[ "$enable_tf_mkldnn" == "0" ]]; then
  BAZEL_OPTS+=" --define=zendnn=true \
    --define=build_with_mkl_dnn_only=false \
    --define=build_with_mkl=false \
    --define=enable_mkl=false \
    --define=tensorflow_mkldnn_contraction_kernel=0 \
    --define=build_with_mkl_opensource=false"
fi

if [[ "$(uname -m)" == "ppc64le" ]]; then
  BAZEL_OPTS+=" --define=tflite_with_xnnpack=false \
    --define=tflite_kernel_use_xnnpack=false"
fi

if [[ "%(enable_gpu)s" == "1" ]]; then
  BAZEL_OPTS+=" --config=cuda"

  export GCC_HOST_COMPILER_PREFIX="${GCC_ROOT}/bin"
  export GCC_HOST_COMPILER_PATH="$(which gcc)"
  export TF_CUDA_COMPUTE_CAPABILITIES="$(echo "compute_${cuda_arch}" | sed 's|\s\s*|,compute_|g')"
  export TF_CUDA_VERSION="$(echo "$CUDA_VERSION" | cut -f1,2 -d.)"
  export TF_CUDA_PATHS="${CUDA_ROOT},${CUDNN_ROOT}"
  export TF_CUDA_CLANG=0
  export cuda=Y
fi

export TF_NEED_CUDA="%(enable_gpu)s"
export TF_NEED_CLANG=0
export TF_DOWNLOAD_CLANG=0
export TF_NEED_JEMALLOC=0
export TF_NEED_HDFS=0
export TF_NEED_GCP=0
export TF_ENABLE_XLA=1
export TF_NEED_OPENCL=0
export TF_NEED_VERBS=0
export TF_NEED_MKL=0
export TF_NEED_MPI=0
export TF_NEED_S3=0
export TF_NEED_GDR=0
export TF_NEED_OPENCL_SYCL=0
export TF_SET_ANDROID_WORKSPACE=false
export TF_NEED_KAFKA=false
export TF_NEED_AWS=0
export TF_NEED_IGNITE=0
export TF_NEED_ROCM=0
export TF_NEED_TENSORRT=0
export TF_PYTHON_VERSION=$PYTHON_MAJOR_MINOR_VERSION
export TEST_TMPDIR=$BUILDDIR/build
export TF_CMS_EXTERNALS="$BUILDDIR/cms_externals.txt"

echo "png:${LIBPNG_ROOT}"                   >  ${TF_CMS_EXTERNALS}
echo "libjpeg_turbo:${LIBJPEG_TURBO_ROOT}"  >> ${TF_CMS_EXTERNALS}
echo "zlib:${ZLIB_ROOT}"                    >> ${TF_CMS_EXTERNALS}
echo "eigen_archive:${EIGEN_ROOT}"          >> ${TF_CMS_EXTERNALS}
echo "curl:${CURL_ROOT}"                    >> ${TF_CMS_EXTERNALS}
#echo "com_google_protobuf:${PROTOBUF_ROOT}" >> ${TF_CMS_EXTERNALS}
echo "com_github_grpc_grpc:${GRPC_ROOT}"    >> ${TF_CMS_EXTERNALS}
echo "gif:${GIFLIB_ROOT}"                   >> ${TF_CMS_EXTERNALS}
echo "org_sqlite:${SQLITE_ROOT}"            >> ${TF_CMS_EXTERNALS}
echo "cython:"                              >> ${TF_CMS_EXTERNALS}
echo "flatbuffers:${FLATBUFFERS_ROOT}"      >> ${TF_CMS_EXTERNALS}
echo "pybind11:${PY_PYBIND11_ROOT}"          >> ${TF_CMS_EXTERNALS}
echo "absl_py:${PY_ABSL_PY_ROOT}"          >> ${TF_CMS_EXTERNALS}
echo "pasta:"                               >> ${TF_CMS_EXTERNALS}
echo "boringssl:"                           >> ${TF_CMS_EXTERNALS}

export TF_SYSTEM_LIBS=$(cat ${TF_CMS_EXTERNALS} | sed 's|:.*||' | tr "\n" "," | sed 's|,*$||')

echo "pypi_numpy:${PY_NUMPY_ROOT}"         >> ${TF_CMS_EXTERNALS}

# Create local repos for pypi_* packages required by TF
tf_requirement=requirements_lock_${PYTHON_MAJOR_VERSION}_${PYTHON_MINOR_VERSION}.txt
for name in $(grep '^[a-zA-Z].*==' ${tf_requirement} | sed 's| *==.*||;s|-|_|g'); do
  bfile="pypi"
  [ -f third_party/cms/${name}.BUILD ] && bfile="${name}"
  sed -i -e "s|def repos():|def pypi_${name}():\n  cms_new_local_repository(name = \"pypi_${name}\",build_file = \"//third_party/cms:${bfile}.BUILD\")\n\ndef repos():\n    pypi_${name}()|" third_party/cms/workspace.bzl
done
rm -f ${tf_requirement}; touch ${tf_requirement}

if [ -d ../build ] ; then
  chmod -R u+w  ../build
  rm -rf ../build
fi

export PYTHONPATH=$PYTHON3PATH
export TF_PYTHON_VERSION=$PYTHON_MAJOR_MINOR_VERSION
./configure

rm -rf "$BUILDDIR/cms-pytool"
mkdir -p "$BUILDDIR/cms-pytool"
echo '#!/bin/bash'                            >  "$BUILDDIR/cms-pytool/python3"
echo "export PYTHON3PATH=\"${PYTHON3PATH}\"" >> "$BUILDDIR/cms-pytool/python3"
echo "$(which python3) \"\$@\""              >> "$BUILDDIR/cms-pytool/python3"
chmod +x "$BUILDDIR/cms-pytool/python3"
ln -s python3 "$BUILDDIR/cms-pytool/python"
export PATH="$BUILDDIR/cms-pytool:$PATH"

# Build numpy first to fix the pypi_numpy repo
bazel $BAZEL_OPTS //third_party/py/numpy
build_dir=$(readlink bazel-out | sed 's|/execroot/org_tensorflow/bazel-out$||')
ln -s ${PYTHON3_LIB_SITE_PACKAGES} ${build_dir}/external/pypi_numpy/site-packages

# Build the wheel
bazel $BAZEL_OPTS //tensorflow/tools/pip_package:wheel

# Install wheel and XLA runtime artifacts
case "$(uname -m)" in
  x86_64) bazel_dir="k8-${build_type}" ;;
  *)      bazel_dir="$(uname -m)-${build_type}" ;;
esac

mkdir -p "$INSTALLROOT/lib-xla-runtime"
find "bazel-out/${bazel_dir}/bin" -path '*/pip_package/wheel_house/tensorflow-%(version)s*.whl' | xargs --no-run-if-empty -i cp '{}' $INSTALLROOT/
find "bazel-out/${bazel_dir}/bin" -path '*/external/ducc/libfft*.pic.a'             | xargs --no-run-if-empty -i cp '{}' "$INSTALLROOT/lib-xla-runtime/"
find "bazel-out/${bazel_dir}/bin" -path '*/external/local_tsl/tsl/*/libmutex.pic.a' | xargs --no-run-if-empty -i cp '{}' "$INSTALLROOT/lib-xla-runtime/"
find "bazel-out/${bazel_dir}/bin" -path '*/external/nsync/libnsync_cpp.pic.a'       | xargs --no-run-if-empty -i cp '{}' "$INSTALLROOT/lib-xla-runtime/"
for lib in libfft.pic.a libfft_wrapper.pic.a libmutex.pic.a libnsync_cpp.pic.a; do
  test -e "$INSTALLROOT/lib-xla-runtime/${lib}"
done
