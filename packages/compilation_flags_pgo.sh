package: compilation_flags_pgo
version: vCMS
env:
 setup_pgo: ' setup_pgo_flags(){ 
   local var1=\$1;
   local var2=\$2;
   pgo_common=\"-fprofile-prefix-path=\$var1 -fprofile-update=prefer-atomic -fprofile-correction\"; 
   CMSSW_PGO_DIRECTORY=\"\$COMPILATION_FLAGS_PGO_ROOT/\$var2\"; 
   if [ ! -d \"\$CMSSW_PGO_DIRECTORY\" ]; then 
     mkdir -p \"\$CMSSW_PGO_DIRECTORY\"; pgo_build_flags=\"\$pgo_common -fprofile-generate -fprofile-dir=\$CMSSW_PGO_DIRECTORY/pgo/\$\$/\$var2\"; 
   else 
     pgo_build_flags=\"\$pgo_common -fprofile-use -fprofile-partial-training -fprofile-dir=\$CMSSW_PGO_DIRECTORY/pgo/\$\$/\$var2\"; 
  fi; 
     export pgo_build_flags; 
   }
'
---
#pgo_common: " -fprofile-prefix-path=$pgo_path_prefix" -fprofile-update=prefer-atomic -fprofile-correction
#CMSSW_PGO_DIRECTORY: "$BITS_WORK_DIR/tmp"
#pgo_build_flags: "$pgo_common -fprofile-generate -fprofile-dir=$CMSSW_PGO_DIRECTORY/pgo/$$/$pgo_package_name"
