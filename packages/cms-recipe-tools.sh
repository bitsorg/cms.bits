package: cms-recipe-tools
version: main
source: https://github.com/akritkbehera/bits-recipe-tools
---
mkdir -p $INSTALLROOT/bin
install $SOURCEDIR/*Recipe $INSTALLROOT
install $SOURCEDIR/bits-* $INSTALLROOT/bin
