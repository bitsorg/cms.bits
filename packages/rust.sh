package: rust
version: "v%(tag_basename)s"
tag: 1.93.1
sources: 
- https://static.rust-lang.org/dist/rust-%(tag_basename)s-x86_64-unknown-linux-gnu.tar.gz
requires:
- zlib
- gcc
---
arch=$(uname -m)

if [[ "$arch" == "ppc64le" ]]; then
    build_arch="powerpc64le-unknown-linux-gnu"
elif [[ "$arch" == "riscv64" ]]; then
    build_arch="${arch}gc-unknown-linux-gnu"
else
    build_arch="${arch}-unknown-linux-gnu"
fi


tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./install.sh --verbose --prefix=$INSTALLROOT \
  --disable-ldconfig \
  --without=rust-docs \
  --components=rustc,cargo,rust-std-${build_arch}

chmod 0755 $INSTALLROOT/lib/*.so 
chmod 0755 $INSTALLROOT/lib/libLLVM*stable

rm -rf $INSTALLROOT/share
rm -f $INSTALLROOT/lib/rustlib/install.log
