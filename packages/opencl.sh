package: opencl
version: "1.1"
---
cat << EoF > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
ln -s /usr/lib64/nvidia \$WORK_DIR/\$PP/lib64
ln -s /usr/local/cuda/include \$WORK_DIR/\$PP/include
EoF
