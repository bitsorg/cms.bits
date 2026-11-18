package: create_rpm
version: vCMS
requires:
 - Python
 - nfpm
---
create_rpm_package() {
    local pkg="$1"
    
    if [ -z "$pkg" ]; then
        echo "Error: Package name required" >&2
        return 1
    fi
    
    local pkg_upper=$(echo "$pkg" | tr '[:lower:]' '[:upper:]')
    local root_var="${pkg_upper}_ROOT"
    local ver_var="${pkg_upper}_VERSION"
    
    local root="${!root_var}"
    local ver="${!ver_var}"
    
    if [ -z "$root" ]; then
        echo "Error: $root_var not set" >&2
        return 1
    fi
    
    if [ -z "$ver" ]; then
        echo "Error: $ver_var not set" >&2
        return 1
    fi
    
    if [ ! -d "$root" ]; then
        echo "Error: Directory does not exist: $root" >&2
        return 1
    fi
    
    cat > "$BUILDDIR/nfpm.yaml" <<EOF
name: ${pkg}
version: "${ver}"
release: "1"
arch: $(uname -m)
platform: linux
license: "As required by the original provider of the software."
description: "CMS external package for ${pkg} ${ver}"
vendor: CMS
maintainer: "CMS <hn-cms-sw-develtools@cern.ch>"
depends:
$(for dep in $REQUIRES; do echo "  - ${dep}"; done)
contents:
  - src: "$root/"
    dst: /opt
    file_info:
      owner: root
      group: root
      mode: 0755
rpm:
  prefixes:
   - /opt
  compression: zstd
EOF
    
    echo "$NFPM_ROOT"
    $NFPM_ROOT/nfpm pkg --packager rpm --config "$BUILDDIR/nfpm.yaml" --target "$root"
    
    return $?
}

