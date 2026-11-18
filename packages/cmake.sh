package: CMake
version: "3.31.7"
sources:
  - https://cmake.org/files/v3.31/cmake-%(version)s.tar.gz
requires:
  - gcc
  - bz2lib
  - expat
  - zlib
  - curl
---
#!/bin/bash -e
SONAME=so
case $ARCHITECTURE in
  osx*) SONAME=dylib ;;
esac

cat > build-flags.cmake <<- EOF
        # Disable Java capabilities; we don't need it and on OS X might miss
        # required /System/Library/Frameworks/JavaVM.framework/Headers/jni.h.
        SET(JNI_H FALSE CACHE BOOL "" FORCE)
        SET(Java_JAVA_EXECUTABLE FALSE CACHE BOOL "" FORCE)
        SET(Java_JAVAC_EXECUTABLE FALSE CACHE BOOL "" FORCE)

        # SL6 with GCC 4.6.1 and LTO requires -ltinfo with -lcurses for link
        # to succeed, but cmake is not smart enough to find it. We don't
        # really need ccmake anyway, so just disable it.
        SET(BUILD_CursesDialog FALSE CACHE BOOL "" FORCE)

        # Use system libraries, not cmake bundled ones.
        SET(CMAKE_USE_OPENSSL TRUE CACHE BOOL "" FORCE)
        SET(CMAKE_USE_SYSTEM_LIBRARY_CURL TRUE CACHE BOOL "" FORCE)
        SET(CMAKE_USE_SYSTEM_LIBRARY_ZLIB TRUE CACHE BOOL "" FORCE)
        SET(CMAKE_USE_SYSTEM_LIBRARY_BZIP2 TRUE CACHE BOOL "" FORCE)
        SET(CMAKE_USE_SYSTEM_LIBRARY_EXPAT TRUE CACHE BOOL "" FORCE)
EOF

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

export CMAKE_PREFIX_PATH=$CURL_ROOT:$ZLIB_ROOT:$EXPAT_ROOT:$BZ2LIB_ROOT

./configure --prefix=$INSTALLROOT --init=build-flags.cmake --parallel=$JOBS

make ${JOBS:+-j $JOBS}
make install/strip
