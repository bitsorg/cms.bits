#!/usr/bin/env python3
from os.path import exists, dirname, join
from bits_helpers.utilities import yamlLoad, yamlDump
import sys

dir=dirname(sys.argv[0])
build_requires = ["Python", "setuptools", "pip"]
if not sys.argv[1] in ["py-wheel", "py-flit-core"]:
  build_requires.append("py-flit-core")
prepend_path = {"PYTHON3PATH": ["%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"]}
pypi_name=sys.argv[1][3:]
variables = {
  "pypi_source_name": pypi_name.replace("-","_"),
  "pypi_name": pypi_name,
  "pypi_source_opt": "--no-binary=:all:",
  "pypi_download_opts": "--python-version=%%(python_major_minor_str)s+--abi=cp%%(python_major_minor_str)s+--no-deps+%%(pypi_source_opt)s",
  "pypi_pip": "pip3",
  "pypi_source_name": "%s-%%(version)s.tar.gz" % pypi_name,
}

sources = ["pip://%%(pypi_name)s/%%(version)s?pip_options=%%(pypi_download_opts)s&pip=%%(pypi_pip)s&output=/%%(pypi_source_name)s"]
recipe = ""
header = ""
override_file = join (dir, "%s.file" % sys.argv[1])
if exists(override_file):
  with open(override_file) as ref:
    header,recipe = ref.read().split("---", 1)
header = "package: %s\nversion: \"%s\"\n%s" % (sys.argv[1], sys.argv[2], header.strip())
spec = yamlLoad(header.strip())
var = spec.get("variables", {})
for k, v in var.items():
  variables[k] = v
spec["variables"] = variables
if not "sources" in spec:
  spec["sources"] = sources
if "build_requires" in spec:
  spec["build_requires"].extend(build_requires)
else:
  spec["build_requires"] = build_requires
if "requires" in spec:
    spec["requires"].extend(["gcc"])
else:
    spec["requires"] = ["gcc"]
prepath = spec.get("prepend_path", {})
if prepath:
  for k, v in prepath.items():
    if k in prepend_path:
      if isinstance(v,str):
        prepend_path[k].append(v)
      else:
        prepend_path[k].extend(v)
    else:
      prepend_path[k] = v
spec["prepend_path"] = prepend_path
print(yamlDump(spec).strip()) 
print('---')
print("export Pypi_name=\"%s\"" % variables["pypi_name"])
if recipe.strip():
  print(recipe.strip())

build_tmpl = join(dir, "build-with-pip.file")
with open(build_tmpl) as ref:
  print(ref.read())
