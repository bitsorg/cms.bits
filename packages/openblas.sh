package: OpenBLAS
version: 0.3.27
tag: v%(version)s
source: https://github.com/OpenMathLib/OpenBLAS
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

default_microarch_name=x86-64-v3
ARCH="$(uname -m)"

if [ "$ARCH" = "x86_64" ]; then
    XTARGETS="sse3=CORE2"
fi

for t in nehalem sandybridge haswell ; do
    XTARGETS="${XTARGETS} $t=$(echo $t | tr 'a-z' 'A-Z')"
done

XTARGETS="${XTARGETS} skylake-avx512=SKYLAKEX"
XTARGETS="${XTARGETS} x86-64-v2=NEHALEM"
XTARGETS="${XTARGETS} x86-64-v3=HASWELL"
XTARGETS="${XTARGETS} x86-64-v4=SKYLAKEX"

STARGET=$(echo "x86-64-v3" | sed 's|^-m||;s|^arch=||')
TARGET_ARCH=$(echo ${XTARGETS} | tr ' ' '\n' | grep "^${STARGET}=" | sed "s|^${STARGET}=||")

if [ "${TARGET_ARCH}" = "" ] ; then
    echo "ERROR: Unable to match OpenBlas build target '${STARGET}'. Available build targets are"
    echo "${XTARGETS}" | tr ' ' '\n' | sed 's|=.*||'
    echo "Please use one of the supported targets or add support for ${STARGET}"
    exit 1
fi

if [ "$ARCH" = "x86_64" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 TARGET=${TARGET_ARCH}
fi

if [ "$ARCH" = "aarch64" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 TARGET=ARMV8 CFLAGS="-march=armv8-a -mno-outline-atomics"
fi

if [ "$ARCH" = "ppc64le" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 TARGET=POWER8 CFLAGS="-mcpu=power8 -mtune=power8 --param=l1-cache-size=64 --param=l1-cache-line-size=128 --param=l2-cache-size=512"
fi

if [ "$ARCH" = "riscv64" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 TARGET=RISCV64_GENERIC shared
fi

make PREFIX=$INSTALLROOT install MAKE_NB_JOBS=$JOBS
