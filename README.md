# Capoeira Lietuva songbook

Capoeira song lyrics and berimbau rhythms, kept as Markdown and published as
PDF and Word files.

## Download

Every change to `master` rebuilds the files and publishes them on the
[`latest` release](../../releases/tag/latest). These links always point to the
newest version:

| File | Link |
|---|---|
| Songbook (PDF) | [songs.pdf](../../releases/download/latest/songs.pdf) |
| Songbook (Word, for editing) | [songs.docx](../../releases/download/latest/songs.docx) |
| Berimbau rhythms (PDF) | [berimbau-ritmai.pdf](../../releases/download/latest/berimbau-ritmai.pdf) |

The full address is `https://github.com/<owner>/<repo>/releases/download/latest/<file>`.

## Files

| Path | What it is |
|---|---|
| `songs.md` | The songbook. **Edit this.** |
| `berimbau-ritmai.md` | Berimbau rhythms. **Edit this.** |
| `scripts/build.sh` | Builds everything into `dist/` |
| `scripts/pdf.yaml` | PDF layout: paper size, columns, font, margins, heading style |
| `scripts/reference.docx` | Word layout: page setup and paragraph styles |
| `scripts/*.lua` | pandoc add-ons: index with page numbers, keeping songs on one page, two-column sections |
| `flake.nix`, `flake.lock` | Pin the exact pandoc and typst versions |
| `.github/workflows/build.yml` | Builds and publishes the release on every push to `master` |

## Editing songs

Open `songs.md` in any text editor. A song looks like this:

```markdown
## 7. Sai Sai Catarina {#song-7}

[▶ YouTube](http://youtu.be/YqdEWWrktZ0)

Sai sai Catarina\
Saia do mar venha ver Idalina\
***Sai sai Catarina***

Oh Catarina, meu amor\
***Sai sai Catarina***
```

- **Title line:** `## <number>. <Title> {#song-<number>}`. The number appears
  twice and both must match.
- **Line breaks:** end a line with `\` to keep the next line on its own line.
  The last line of a verse has no `\`.
- **Verses:** separate them with a blank line.
- **Chorus (coro):** wrap the line in `***…***`. Plain lines are the soloist.
- **Links:** `[▶ YouTube](url)` under the title (optional).

### Adding, removing or reordering songs

Songs are numbered, and the index at the top of `songs.md` (between
`::: {#song-index}` and `:::`) lists them with links. When you add, remove or
move a song:

1. Put the song where you want it.
2. Renumber the titles that follow, both numbers in each title line.
3. Update the index list to match: `12\. [Title](#song-12)\`.

Keep the `::: {#song-index}` and `:::` lines. The build uses them to replace
the list with an index that has page numbers.

### Berimbau rhythms

`berimbau-ritmai.md` lists each rhythm under a `###` heading. The rhythms
section is laid out in two columns in the PDF; `{.colbreak}` after a heading
(currently Santa Maria) starts the second column there. Move it if the
columns get uneven.

## Building locally

You need [Nix](https://nixos.org/download) with flakes enabled. Then:

```sh
scripts/build.sh
```

The files appear in `dist/` (not committed). The first run downloads pandoc
and typst; later runs are quick.

To update pandoc and typst to newer versions:

```sh
nix flake update
scripts/build.sh   # check the output
git commit -m "Update build tools" flake.lock
```

## Publishing

Push to `master`. The GitHub workflow builds the files and replaces the
assets on the `latest` release (the download links above). You can also run
it by hand from the repository's **Actions** tab ("Run workflow").
