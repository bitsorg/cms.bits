#!/usr/bin/env python3
from os.path import exists, dirname, join
import sys
print("package: %s" % sys.argv[1])
print("version: %s" % sys.argv[2])
dir=dirname(sys.argv[0])
override_file = join (dir, "%s.file" % sys.argv[1])
recipe = ""
add_source = True
if exists(override_file):
  with open(override_file) as ref:
    header,recipe = ref.read().split("---", 1)
    if header.strip():
      from bits_helpers.utilities import yamlLoad, yamlDump
      spec = yamlLoad(header.strip())
      print(yamlDump(spec))
      add_source = "sources" not in spec

if add_source:
  data_repo=sys.argv[1][5:]
  default_source = "https://github.com/cms-data/%s/archive/refs/tags/%s.tar.gz" % (data_repo, sys.argv[2])
  print("sources:\n -", default_source)
print("---")
if recipe.strip():
  print(recipe.strip())

build_tmpl = join(dir, "%s.file" % sys.argv[3])
with open(build_tmpl) as ref:
  print(ref.read())
