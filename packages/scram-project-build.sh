package: scram-project-build
version: vCMS
variables:
  enable_biglib:  "1"
  srctree:        src
  buildtarget:    release-build
  scram_compiler: gcc
  bootstrapfile:  config/bootsrc.xml
  configtag:      V09-08-10
  usercxxflags:   ""
  buildarch:      ""

sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
build_requires:
 - dwz
requires:
 - SCRAMV1
 - gcc
 - cms-recipe-tools
---
scramcmd="$SCRAMV1_ROOT/bin/scram --arch $ARCHITECTURE"






. ${CMS_RECIPE_TOOLS_ROOT}/ScramRecipe

