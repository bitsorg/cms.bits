package: nfpm
version: 2.41.3
tag: v2.41.3
source: https://github.com/goreleaser/nfpm.git
requires:
- go
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/ 
go mod tidy
go build -o $INSTALLROOT ./cmd/nfpm
$INSTALLROOT/nfpm
