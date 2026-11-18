def getPackages(virtual_packages, configDir, *args):
  from os.path import dirname,join, exists
  from sys import exit, argv
  pkg_dir = dirname(__file__)
  data_file = join(pkg_dir ,'packages.txt')
  ptype=""
  local_data_pkgs = []
  for line in [ l.strip().replace(' ','') for l in open(data_file).readlines()]:
    if line.startswith('#') or line=='':continue
    if line[0]=='[' and line[-1]==']':
      ptype=line[1:-1]
      continue
    if not ptype: continue
    if not '=' in line: continue
    (pkg, ver) = line.strip().split('=',1)
    data_pkg = 'data-'+pkg
    pkg_name = data_pkg.lower()
    if pkg_name in virtual_packages:
      continue
    if pkg_name in local_data_pkgs:
      print ("ERROR: Duplicate data package definitions found in %s for package %s" % (data_file, pkg))
      exit(1)
    local_data_pkgs.append(pkg_name)
    virtual_packages[pkg_name]={
        "version": ver,
        "pkgdir" : configDir,
        "url" : data_pkg + ".sh",
        "command": 'PYTHONPATH=%s %s/package.py "%s" "%s" "%s"' % (dirname(argv[0]), pkg_dir, data_pkg, ver, ptype)
      }
  return
