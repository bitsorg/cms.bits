#Enable or Disable the LTO builds
package: compilation_flags_lto
version: vCMS
env:
  lto_build_flags: "$( [ $(uname -m) != ppc64le ] && echo '-flto=auto -fipa-icf -flto-odr-type-merging -fno-fat-lto-objects -Wodr ' )"
---
