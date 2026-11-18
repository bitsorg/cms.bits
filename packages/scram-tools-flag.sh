package: scram-tools-flag
version: "v1"
env:
  EIGEN_CXX_FLAGS: '$(echo "-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64")'
  CMS_EIGEN_CXX_FLAGS: '$(uname -m | grep -q "^aarch" && echo "-DEIGEN_NEON_GEBP_NR=4 $EIGEN_CXX_FLAGS" || echo "$EIGEN_CXX_FLAGS")'
---
