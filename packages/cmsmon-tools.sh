package: cmsmon-tools
version: 0.6.7
variables:
  promv:       "2.31.1"
  amver:       "0.23.0"
  sternv:      "1.22.0"
  apsver:      "0.2.15"
  trivyver:    "0.21.1"
  heyver:      "0.0.2"
  k8s_info_ver: "0.0.1"
  gocurlver:   "0.0.4"
sources:
  - https://github.com/dmwm/CMSMonitoring/releases/download/go-%(version)s/cmsmon-tools.tar.gz
  - https://github.com/prometheus/prometheus/releases/download/v%(promv)s/prometheus-%(promv)s.linux-amd64.tar.gz
  - https://github.com/prometheus/alertmanager/releases/download/v%(amver)s/alertmanager-%(amver)s.linux-amd64.tar.gz
  - https://github.com/vkuznet/hey/releases/download/%(heyver)s/hey-tools.tar.gz
  - https://github.com/stern/stern/releases/download/v%(sternv)s/stern_%(sternv)s_linux_amd64.tar.gz
  - https://github.com/vkuznet/auth-proxy-server/releases/download/%(apsver)s/auth-proxy-tools_amd64.tar.gz
  - https://github.com/vkuznet/k8s_info/releases/download/%(k8s_info_ver)s/k8s_info-tools.tar.gz
  - https://github.com/aquasecurity/trivy/releases/download/v%(trivyver)s/trivy_%(trivyver)s_Linux-64bit.tar.gz
  - https://github.com/vkuznet/gocurl/releases/download/%(gocurlver)s/gocurl-tools.tar.gz
---
mkdir -p "$INSTALLROOT"

# Extract and install cmsmon-tools binaries
CMSMON_DIR="$BUILDDIR/cmsmon-tools"
mkdir -p "$CMSMON_DIR"
tar -xzf "$SOURCEDIR/$SOURCE0" -C "$CMSMON_DIR"
for cmd in monit alert annotationManager nats-sub nats-pub dbs_vm; do
    [ -f "$CMSMON_DIR/$cmd" ] && cp "$CMSMON_DIR/$cmd" "$INSTALLROOT/"
done

# prometheus
mkdir -p "$BUILDDIR/prometheus"
tar -xzf "$SOURCEDIR/$SOURCE1" --strip-components=1 -C "$BUILDDIR/prometheus"
cp "$BUILDDIR/prometheus/promtool"  "$INSTALLROOT/"
cp "$BUILDDIR/prometheus/prometheus" "$INSTALLROOT/"

# alertmanager
mkdir -p "$BUILDDIR/alertmanager"
tar -xzf "$SOURCEDIR/$SOURCE2" --strip-components=1 -C "$BUILDDIR/alertmanager"
cp "$BUILDDIR/alertmanager/amtool" "$INSTALLROOT/"

# hey
mkdir -p "$BUILDDIR/hey-tools"
tar -xzf "$SOURCEDIR/$SOURCE3" --strip-components=1 -C "$BUILDDIR/hey-tools"
cp "$BUILDDIR/hey-tools/hey_amd64" "$INSTALLROOT/hey"
chmod +x "$INSTALLROOT/hey"

# stern
mkdir -p "$BUILDDIR/stern"
tar -xzf "$SOURCEDIR/$SOURCE4" -C "$BUILDDIR/stern"
cp "$BUILDDIR/stern/stern" "$INSTALLROOT/stern"
chmod +x "$INSTALLROOT/stern"

# auth-proxy-server tools
mkdir -p "$BUILDDIR/auth-proxy"
tar -xzf "$SOURCEDIR/$SOURCE5" --strip-components=1 -C "$BUILDDIR/auth-proxy"
cp "$BUILDDIR/auth-proxy/token-manager" "$INSTALLROOT/"
cp "$BUILDDIR/auth-proxy/auth-token"    "$INSTALLROOT/"

# k8s_info
mkdir -p "$BUILDDIR/k8s_info"
tar -xzf "$SOURCEDIR/$SOURCE6" --strip-components=1 -C "$BUILDDIR/k8s_info"
cp "$BUILDDIR/k8s_info/k8s_info_amd64" "$INSTALLROOT/k8s_info"
chmod +x "$INSTALLROOT/k8s_info"

# trivy
mkdir -p "$BUILDDIR/trivy"
tar -xzf "$SOURCEDIR/$SOURCE7" -C "$BUILDDIR/trivy"
cp "$BUILDDIR/trivy/trivy" "$INSTALLROOT/"
chmod +x "$INSTALLROOT/trivy"

# gocurl
mkdir -p "$BUILDDIR/gocurl"
tar -xzf "$SOURCEDIR/$SOURCE8" --strip-components=1 -C "$BUILDDIR/gocurl"
cp "$BUILDDIR/gocurl/gocurl_amd64" "$INSTALLROOT/gocurl"
chmod +x "$INSTALLROOT/gocurl"

# Create wrapper script
cat << 'WRAPPER' > "$INSTALLROOT/.cmsmon-tools"
#!/bin/bash -e
#CMSDIST_FILE_REVISION=2
eval $(scram unsetenv -sh)
THISDIR=$(dirname $0)
SHARED_ARCH=$(cmsos)
CMD=$(basename $0)
LATEST_VERSION=$(ls -d ${THISDIR}/../${SHARED_ARCH}_*/cms/cmsmon-tools/*/$CMD 2>/dev/null | sed -e 's|.*/cms/cmsmon-tools/||;s|/.*||' | sort -t. -k 1,1n -k 2,2n -k 3,3n | tail -1)
[ -z $LATEST_VERSION ] && >&2 echo "ERROR: Unable to find command '$CMD' for '$SHARED_ARCH' architecture." && exit 1
TOOL=$(ls -d ${THISDIR}/../${SHARED_ARCH}_*/cms/cmsmon-tools/${LATEST_VERSION}/$CMD 2>/dev/null | sort | tail -1)
$TOOL "$@"
WRAPPER
chmod +x "$INSTALLROOT/.cmsmon-tools"

mkdir -p "$INSTALLROOT/etc/profile.d"
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
mkdir -p \$WORK_DIR/cmsmon
cp "\$WORK_DIR/\$PP/.cmsmon-tools" "\$WORK_DIR/cmsmon/.cmsmon-tools"
for cmd in monit alert annotationManager nats-sub nats-pub dbs_vm promtool amtool prometheus hey stern trivy k8s_info gocurl; do
    ln -sf .cmsmon-tools \$WORK_DIR/cmsmon/\$cmd
done
rm -f \$WORK_DIR/cmsmon/*_commands 2>/dev/null
EoF
