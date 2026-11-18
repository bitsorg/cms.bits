package: Xcode
version: "17_21"
prefer_system: "(?!osx).*"
prefer_system_check: |
  exit 0
---
# If replacement is selected, this must NOT run
echo "RUNNING RECIPE"
exit 1
