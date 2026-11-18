package: bootstrap_provides
version: v1
variables:
  provides: "
  perl(Cwd) perl(File::Basename) perl(File::stat) perl(Getopt::Long) perl(List::Util) perl(POSIX) perl(bigint) perl(Carp) perl(Class::Struct) perl(Data::Dumper) perl(Errno) perl(Exporter) perl(File::Copy) perl(File::Find) perl(File::Path) perl(File::Spec) perl(File::Temp) perl(IO::File) perl(Text::ParseWords) perl(constant) /usr/bin/env /usr/bin/perl perl(CGI) perl(CGI::Carp) perl(CGI::Util) perl(DBI) perl(Digest::MD5) perl(Encode) perl(Fcntl) perl(Getopt::Std) perl(IO::Pipe) perl(IO::Socket) perl(IPC::Open2) perl(IPC::Open3) perl(Memoize) perl(SVN::Core) perl(SVN::Delta) perl(SVN::Ra) perl(Scalar::Util) perl(Storable) perl(Time::HiRes) perl(Time::Local) perl(YAML::Any)
  "
  platformSeeds: "
  bash glibc glibc-headers openssl-libs libX11 libxcrypt readline ncurses-libs tcl tk mesa-libGLU libglvnd-glx libglvnd-opengl libXext libXft libXpm perl perl-libs libbrotli python3 perl-base perl-lib perl-filetest perl-overload perl-vars libcom_err krb5-libs libaio libgcc"
hook: disable
---
cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EOF
#!/bin/bash
PLATFORM_SEEDS="%(platformSeeds)s"
PROVIDES="%(provides)s"

# Query provides from platform seeds and build JSON
provides_json='[]'
for seed in \$PLATFORM_SEEDS; do
  pkg=\$(rpm -q --whatprovides "\$seed" 2>/dev/null | head -1)
  if [ -z "\$pkg" ] || [[ "\$pkg" == *"no package provides"* ]]; then
    echo "Error: No package provides '\$seed'"
    exit 1
  fi
  seed_provides=\$(rpm -q --provides "\$pkg" 2>/dev/null | jq -R . | jq -s .)
  provides_json=\$(echo "\$provides_json" | jq --argjson new "\$seed_provides" '. + \$new')
done

# Append PROVIDES to the JSON (faking that they exist)
for p in \$PROVIDES; do
  provides_json=\$(echo "\$provides_json" | jq --arg p "\$p" '. + [\$p]')
done

echo "\$provides_json" | jq '.' > "\$WORK_DIR/system_provides.json"
cp \$WORK_DIR/\$PP/etc/profile.d/check_dependencies.py \$WORK_DIR/
cp \$WORK_DIR/\$PP/etc/profile.d/spec \$WORK_DIR/
chmod +x \$WORK_DIR/check_dependencies.py
EOF

cp $(get_file_from_configDir check_dependencies.py) $INSTALLROOT/etc/profile.d
cp $(get_file_from_configDir spec) $INSTALLROOT/etc/profile.d
chmod +x "$INSTALLROOT/etc/profile.d/post-relocate.sh"
