package: compilation_flags
version: "1.0"
env:
  arch_build_flags: "$(uname -m | grep -q '^aarch' && echo '-march=armv8-a -mno-outline-atomics' || (uname -m | grep -q '^ppc64le' && echo '-mcpu=power8 -mtune=power8 --param=l1-cache-size=64 --param=l1-cache-line-size=128 --param=l2-cache-size=512' || echo ''))"
---
