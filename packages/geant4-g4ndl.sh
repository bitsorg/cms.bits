package: geant4-G4NDL
version: "4.7"
sources:
-  https://cern.ch/geant4-data/datasets/G4NDL.%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$INSTALLROOT"
