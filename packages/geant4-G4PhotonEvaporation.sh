packages: geant4-G4PhotonEvaporation
version: "11.0"
sources:
 - https://geant4-data.web.cern.ch/datasets/G4PhotonEvaporation.%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$INSTALLROOT"
