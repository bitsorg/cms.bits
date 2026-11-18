#!/usr/bin/env python3
"""
Virtual package generator for CMSSW, cmssw-tools, coral, and coral-tools.

Command-line usage:
  cmssw:       package.py cmssw <ib_name> <release_queue> <suffix> <date_time> <branch> [os] [flavor]
  cmssw-tools: package.py cmssw-tools <release_queue> [os]
  coral:       package.py coral
  coral-tools: package.py coral-tools

Generates YAML recipe to stdout in the format:
  <yaml header>
  ---
  <bash body>
"""
import sys
from os.path import dirname, join, exists

from bits_helpers.utilities import yamlLoad, yamlDump
from bits_helpers.log import debug, info, banner, warning

from config_loader import ConfigLoader


def apply_override(spec, body, override_file, variables):
    """
    Merge <pkg>.file overrides into spec; prepend body if the file has one.

    Args:
        spec: Package specification dictionary
        body: Build body script
        override_file: Path to override file (e.g., cmssw.file)
        variables: Current variables dictionary

    Returns:
        Tuple of (updated_spec, updated_body)
    """
    if not override_file or not exists(override_file):
        return spec, body

    with open(override_file) as f:
        content = f.read()
    parts = content.split('---', 1)
    override_header = parts[0].strip()
    override_body = parts[1].strip() if len(parts) > 1 else ''

    if override_header:
        override_spec = yamlLoad(override_header)
        # Merge variables separately so they combine rather than replace
        merged_vars = variables.copy()
        merged_vars.update(override_spec.pop('variables', {}))
        spec.update(override_spec)
        spec['variables'] = merged_vars
        import pprint
        debug("Final spec: \n%s" % (pprint.pformat(spec)))

    if override_body:
        body = override_body + '\n' + body
        debug("Final body after applying override from %s:\n%s" % (override_file, body))

    return spec, body


def build_spec(yaml_file, body_file, override_file, package, version,
               extra_vars=None, body_prefix='', config=None):
    """
    Build the complete package specification.

    Args:
        yaml_file: Path to package YAML spec (e.g., cmssw.yaml)
        body_file: Path to build body template
        override_file: Optional path to override file (e.g., cmssw.file)
        package: Package name
        version: Package version
        extra_vars: Additional variables to merge
        body_prefix: Prefix to prepend to body
        config: Configuration from ConfigLoader

    Returns:
        Tuple of (spec_dict, body_string)
    """
    with open(yaml_file) as f:
        spec = yamlLoad(f.read())
    spec['package'] = package
    spec['version'] = version

    # Start with variables from spec, then layer config, then extra_vars
    variables = spec.pop('variables', {})
    variables.update((config or {}).get('variables', {}))

    if extra_vars:
        variables.update(extra_vars)

    spec['variables'] = variables

    with open(body_file) as f:
        body = body_prefix + f.read().strip()

    return apply_override(spec, body, override_file, variables)


# Parse command-line arguments
pkg_type = sys.argv[1]
pkg_dir = dirname(__file__)

# Initialize ConfigLoader
loader = ConfigLoader(pkg_dir)

if pkg_type == 'cmssw':
    # argv: package.py cmssw <ib_name> <release_queue> <suffix> <date_time> <branch> [os] [flavor]
    ib_name, release_queue, suffix, date_time, branch = sys.argv[2:7]

    # Optional context from packages.py
    os_name = sys.argv[7] if len(sys.argv) > 7 and sys.argv[7] else None
    flavor = sys.argv[8] if len(sys.argv) > 8 and sys.argv[8] else None

    # Load layered configuration
    config = loader.load_config(
        pkg_type='cmssw',
        os=os_name,
        flavor=flavor,
        queue=release_queue,
    )

    spec, body = build_spec(
        yaml_file=join(pkg_dir, 'cmssw.yaml'),
        body_file=join(dirname(pkg_dir), 'scram-project-build.file'),
        override_file=join(pkg_dir, 'cmssw.file'),
        package=ib_name,
        version="%s_%s" % (ib_name, date_time),
        extra_vars={'branch': branch},
        body_prefix=(
            'export SCRAM_ARCH="$ARCHITECTURE"\n'
            'source "$WORK_DIR/cmsset_default.sh"\n'
        ),
        config=config,
    )

    # Also check for release_queue specific override
    queue_override = join(pkg_dir, '%s.file' % release_queue)
    if exists(queue_override):
        spec, body = apply_override(spec, body, queue_override, spec.get('variables', {}))

elif pkg_type == 'cmssw-tools':
    # argv: package.py cmssw-tools <release_queue> [os]
    release_queue = sys.argv[2]

    # Optional context from packages.py
    os_name = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] else None

    # Load layered configuration
    config = loader.load_config(
        pkg_type='cmssw-tools',
        os=os_name,
        flavor=None,
        queue=release_queue,
    )

    spec, body = build_spec(
        yaml_file=join(pkg_dir, pkg_type + '.yaml'),
        body_file=join(dirname(pkg_dir), 'tool-conf-src.file'),
        override_file=None,
        package=pkg_type,
        version='100',
        config=config,
    )

elif pkg_type in ('coral', 'coral-tools'):
    # These recipes share the SCRAM project build workflow but are kept as
    # generated packages under CMSSW/ so the CMSSW provider owns their specs.
    version = 'CORAL_2_3_21' if pkg_type == 'coral' else 'v1'
    spec, body = build_spec(
        yaml_file=join(pkg_dir, pkg_type + '.yaml'),
        body_file=join(pkg_dir, pkg_type + '-build.sh'),
        override_file=None,
        package=pkg_type,
        version=version,
    )

else:
    raise ValueError("Unknown generated package type: %s" % pkg_type)

# Output the recipe
print(yamlDump(spec).strip())
print('---')
print(body)
