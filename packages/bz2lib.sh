package: bz2lib
version: "1.0.8"
build_requires:
 - gmake
requires:
 - gcc
sources:
 - https://gitlab.com/bzip2/bzip2/-/archive/bzip2-%(version)s/bzip2-bzip2-%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Build shared library
make ${JOBS:+-j$JOBS} -C "$BUILDDIR" -f Makefile-libbz2_so

# Install
make ${JOBS:+-j$JOBS} -C "$BUILDDIR" install PREFIX="$INSTALLROOT"

# Install shared library and versioned symlinks
cp "$BUILDDIR/libbz2.so.$PKGVERSION" "$INSTALLROOT/lib/"
cd "$INSTALLROOT/lib"
ln -sf "libbz2.so.$PKGVERSION" "libbz2.so"
ln -sf "libbz2.so.$PKGVERSION" "libbz2.so.$(echo $PKGVERSION | cut -d. -f1,2)"
ln -sf "libbz2.so.$PKGVERSION" "libbz2.so.$(echo $PKGVERSION | cut -d. -f1)"

# Convenience symlinks for bin tools
cd "$INSTALLROOT/bin"
ln -sf bzdiff bzcmp
ln -sf bzgrep bzegrep
ln -sf bzgrep bzfgrep
ln -sf bzmore bzless
