package: tensorflow
version: 2.17.0
variables:
  enable_gpu: "0"
requires:
 - tensorflow-sources
 - py-wheel
---
tf_major=$(echo "$PKG_VERSION" | cut -d. -f1)
python_mm="${PYTHON_MAJOR_VERSION}${PYTHON_MINOR_VERSION}"
arch=$(uname -m)

mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/xla-aot-runtime"

wheel unpack "$TENSORFLOW_SOURCES_ROOT/tensorflow-2.17.0-cp312-cp312-linux_x86_64.whl"

mv "tensorflow-$PKG_VERSION/tensorflow/include"            "$INSTALLROOT/include"
for l in libtensorflow_cc.so libtensorflow_framework.so; do
  mv "tensorflow-$PKG_VERSION/tensorflow/${l}.${tf_major}" "$INSTALLROOT/lib/"
  chmod 0755 "$INSTALLROOT/lib/${l}.${tf_major}"
  ln -s "${l}.${tf_major}" "$INSTALLROOT/lib/${l}"
done
mv "tensorflow-$PKG_VERSION/tensorflow/xla_aot_runtime_src" "$INSTALLROOT/xla-aot-runtime/src"
cp -r "$TENSORFLOW_SOURCES_ROOT/lib-xla-runtime"             "$INSTALLROOT/xla-aot-runtime/lib"
