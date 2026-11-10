#!/usr/bin/env bash
# Build every export from the Markdown masters:
#   songs.md           -> songs.docx, songs.pdf
#   berimbau-ritmai.md -> berimbau-ritmai.pdf
# pandoc and typst come from the nixpkgs revision pinned in flake.lock
# (update with `nix flake update`).
set -euo pipefail
cd "$(dirname "$0")"

# Re-run inside the pinned dev shell unless we're already in it.
if [[ -z "${SONGBOOK_SHELL:-}" ]]; then
  exec nix develop --command env SONGBOOK_SHELL=1 "$0" "$@"
fi

# reference.docx holds the page setup (A4, 2 columns) and heading styles.
pandoc songs.md -f markdown-smart -o songs.docx --reference-doc=reference.docx \
  --lua-filter=index.lua --lua-filter=keep-songs.lua
echo "songs.docx written"

# Layout options live in pdf.yaml.
pandoc songs.md -f markdown-smart -o songs.pdf \
  --pdf-engine=typst --metadata-file=pdf.yaml --lua-filter=index.lua --lua-filter=keep-songs.lua
echo "songs.pdf written"

# Berimbau rhythms: one column so the sounds table fits; the rhythms list is 2 columns (columns.lua).
pandoc berimbau-ritmai.md -f markdown-smart -o berimbau-ritmai.pdf \
  --pdf-engine=typst --metadata-file=pdf.yaml -M columns=1 --lua-filter=columns.lua
echo "berimbau-ritmai.pdf written"
