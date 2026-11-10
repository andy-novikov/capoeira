#!/usr/bin/env bash
# Build every export from the Markdown masters into dist/:
#   songs.md           -> dist/songs.docx, dist/songs.pdf
#   berimbau-ritmai.md -> dist/berimbau-ritmai.pdf
# pandoc and typst come from the nixpkgs revision pinned in flake.lock
# (update with `nix flake update`).
set -euo pipefail
cd "$(dirname "$0")/.."

# Re-run inside the pinned dev shell unless we're already in it.
if [[ -z "${SONGBOOK_SHELL:-}" ]]; then
  exec nix develop --command env SONGBOOK_SHELL=1 "$0" "$@"
fi

S=scripts
mkdir -p dist

# reference.docx holds the page setup (A4, 2 columns) and heading styles.
pandoc songs.md -f markdown-smart -o dist/songs.docx --reference-doc=$S/reference.docx \
  --lua-filter=$S/index.lua --lua-filter=$S/keep-songs.lua
echo "dist/songs.docx written"

# Layout options live in pdf.yaml.
pandoc songs.md -f markdown-smart -o dist/songs.pdf \
  --pdf-engine=typst --metadata-file=$S/pdf.yaml --lua-filter=$S/index.lua --lua-filter=$S/keep-songs.lua
echo "dist/songs.pdf written"

# Berimbau rhythms: one column so the sounds table fits; the rhythms list is 2 columns (columns.lua).
pandoc berimbau-ritmai.md -f markdown-smart -o dist/berimbau-ritmai.pdf \
  --pdf-engine=typst --metadata-file=$S/pdf.yaml -M columns=1 --lua-filter=$S/columns.lua
echo "dist/berimbau-ritmai.pdf written"
