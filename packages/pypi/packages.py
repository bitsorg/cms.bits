def getPackages(virtual_packages, configDir, *args):
  from re import match
  from os.path import dirname,join, exists
  import os, sys, platform
  pkg_dir = dirname(__file__)
  req = join(pkg_dir,'requirements.txt')
  if not exists(req): return
  extra_match = {}
  extra_match['platform_machine'] = platform.machine()
  extra_match['sys_platform'] = sys.platform
  extra_match['os_name'] = os.name
  #extra_match['cmsos_name'] = args[0].options.architecture.split("_")[0]
  for line in [ l.strip().replace(' ','') for l in open(req).readlines()]:
    if line.startswith('#'):continue
    if not '==' in line: continue
    items = line.strip().split(';')
    (pkg, ver) = items[0].strip().split('==',1)
    py_pkg = "py-%s" % pkg
    pkg_name = py_pkg.lower()
    if pkg_name in virtual_packages: continue
    matched=True
    for item in items[1:]:
      m = match("^("+"|".join(list(extra_match.keys()))+")(==|!=)'([^']+)'$", item)
      if m:
        if m.group(2)=='==' and not match(m.group(3),extra_match[m.group(1)]): matched=False
        if m.group(2)=='!=' and     match(m.group(3),extra_match[m.group(1)]): matched=False
    if matched:
      virtual_packages[pkg_name]={
          "version": ver,
          "pkgdir" : configDir,
          "url": py_pkg + ".sh",
          "command" : 'PYTHONPATH=%s %s/package.py "%s" "%s" "py3"' % (dirname(sys.argv[0]), pkg_dir, py_pkg, ver),
        }
  return
