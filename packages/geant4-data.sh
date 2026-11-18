package: geant4-data
version: "11"
variables:
  G4NDL: "4.7"
  G4EMLOW: "8.5"
  G4PhotonEvaporation: "5.7"
  G4RadioactiveDecay: "5.6"
  G4PARTICLEXS: "4.1"
  G4SAIDDATA: "2.0"
  G4ABLA: "3.3"
  G4ENSDFSTATE: "2.3"
  G4RealSurface: "2.2"
  G4INCL: "1.2"
sources:
- https://cern.ch/geant4-data/datasets/G4NDL.%(G4NDL)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4EMLOW.%(G4EMLOW)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4PhotonEvaporation.%(G4PhotonEvaporation)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4RadioactiveDecay.%(G4RadioactiveDecay)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4PARTICLEXS.%(G4PARTICLEXS)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4SAIDDATA.%(G4SAIDDATA)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4ABLA.%(G4ABLA)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4ENSDFSTATE.%(G4ENSDFSTATE)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4RealSurface.%(G4RealSurface)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4INCL.%(G4INCL)s.tar.gz
---
for i in $(seq 0 9); do
  src_var="SOURCE$i"
  src_file="${!src_var}"
  if [ -n "$src_file" ]; then
    tar -xzf "$SOURCEDIR/$src_file" -C "$INSTALLROOT"
  fi
done
