package: preamble
version: v1
---
# This file is included in any build recipe and it's only used to set
# environment functions and variables. The actual implementation of these functions
# is done by the `build` script, which sources this file.
sync_source_to_build() {
  local src="${1:-$SOURCEDIR}"
  local dest="${2:-$BUILDDIR}"
  rsync -a --chmod=ug=rwX --delete --exclude '**/.git' \
    "$src"/ "$dest"/
}