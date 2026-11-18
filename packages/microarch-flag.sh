package: microarch-flag
version: "1.0"
env:
  default_microarch_name: "x86-64-v3"
  arch: "$(/usr/lib64/ld-linux-x86-64.so.2 --help | grep 'x86-64-v*' | grep 'supported' | head -n 1 | awk '{print $1}')"
  selected_microarch: "-march=${override_microarch:-$arch}"
---
