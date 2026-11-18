package: geant4-G4EMLOWc
version: "8.5"
sources:
 - https://geant4-data.web.cern.ch/datasets/G4EMLOW.%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$INSTALLROOT"
