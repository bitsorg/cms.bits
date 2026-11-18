package: java-env
version: "17_21"
env:
  JAVA_HOME: $( [ "$(grep -oE '^[0-9]+' /etc/os-release | head -1)" -ge 10 ] && echo "/usr/lib/jvm/java-21" || echo "/usr/lib/jvm/java-17" )
---