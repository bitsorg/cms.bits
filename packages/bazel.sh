package: bazel
version: "6.5.0"
sources:
 - https://github.com/bazelbuild/bazel/releases/download/%(version)s/bazel-%(version)s-dist.zip
build_requires:
 - java-env
 - Python
requires:
 - gcc
patches:
 - bazel-3.7.0-patches.patch
 - bazel-absl.patch
#- bazel-gcc14.patch
# For some build steps, bazel uses a process-wrapper that is executed in an empty environment.
# Therefore, the wrapper is linked to the system library /lib64/libstdc++.so.6, and complains about
# a missing GLIBCXX_3.4.21 version when (e.g.) used during the compilation of tensorflow python
# modules invoked via swig. This mechanism of bazel is actually only useful in combination with its
# remote compilation features. When disabling the process-wrapper, the local environment is taken
# into account which is the desired behavior for us. For example, see:
#   - https://github.com/bazelbuild/bazel/issues/4137
#   - https://github.com/bazelbuild/bazel/issues/4510
#   - https://github.com/tensorflow/tensorboard/issues/1611

# configuration issue
# https://github.com/bazelbuild/bazel/issues/9392
---
unzip -q "$SOURCEDIR/${SOURCE0}" -d "$BUILDDIR"

patch -p1 -s -i "$SOURCEDIR/$PATCH0"
patch -p1 -s -i "$SOURCEDIR/$PATCH1"
#patch -p1 -s -i "$SOURCEDIR/$PATCH2"

export EXTRA_BAZEL_ARGS="--define=ABSOLUTE_JAVABASE=${JAVA_HOME} --jobs 8"
export BAZEL_CXXOPTS="-std=c++$CXXSTD"
if [ $(${JAVA_HOME}/bin/java -version 2>&1 | grep -i 'openjdk version' | sed -E 's/.*"([0-9]+)\..*/\1/') -ge 17 ] ; then
  export JNI_FLAGS="--add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"
fi
bash ./compile.sh

mkdir $INSTALLROOT/bin
cp "$BUILDDIR/output/bazel" "$INSTALLROOT/bin/"
