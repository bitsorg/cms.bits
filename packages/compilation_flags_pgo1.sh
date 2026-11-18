package: compilation_flags_pgo1
version: vCMS
env:
 pgo: '
eval "
  var1=\$1
  var2=\$2
  pgo_common=\"-fprofile-prefix-path=\$var1 -fprofile-update=prefer-atomic -fprofile-correction\"
  CMSSW_PGO_DIRECTORY=\"\$COMPILATION_FLAGS_PGO_ROOT/\$var2\"

  if [ ! -d \"\$CMSSW_PGO_DIRECTORY\" ]; then
      mkdir -p \"\$CMSSW_PGO_DIRECTORY\"
      pgo_build_flags=\"\$pgo_common -fprofile-generate -fprofile-dir=\$CMSSW_PGO_DIRECTORY/pgo/\$\$/\$var2\"
  else
      pgo_build_flags=\"\$pgo_common -fprofile-use -fprofile-partial-training -fprofile-dir=\$CMSSW_PGO_DIRECTORY/pgo/\$\$/\$var2\"
  fi

  export pgo_build_flags
"
'
---
