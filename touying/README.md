# Touying slide deck

Typst-based presentation for *Type-Driven Development: A Practical Journey*.

## Build commands

```bash
make              # build talk.pdf (default)
make talk.pdf     # same as above
make talk-notes   # build talk-with-notes.pdf (speaker-notes variant)
make talk-svg     # export slides/svg/slide-NN.svg (one per page)
make talk-png     # export slides/png/slide-NN.png at 1920×1080 144 ppi
make watch        # live-reload into talk.pdf on every save
make clean        # delete generated artefacts
```

Run all commands from the **repo root** (not from `touying/`).

## Requirements

- **Typst** 0.5.5 or later (tested with 0.14.2).
  Install: <https://github.com/typst/typst/releases>

## Font installation

Two fonts must be available system-wide (or in `touying/fonts/`):

**IBM Plex Sans** — body text and headings
```bash
# Debian/Ubuntu (backports)
sudo apt install fonts-ibm-plex

# Or manually: download OTF release from
# https://github.com/IBM/plex/releases
# then copy to ~/.local/share/fonts/ibm-plex/ and run:
fc-cache -f
```

**JetBrains Mono** — code panes and monospace labels
```bash
# Debian/Ubuntu
sudo apt install fonts-jetbrains-mono

# Or manually: download from
# https://github.com/JetBrains/JetBrainsMono/releases
# then copy to ~/.local/share/fonts/JetBrainsMono/ and run:
fc-cache -f
```

Verify after installation:
```bash
typst fonts | grep -E "IBM Plex|JetBrains"
```

The theme falls back to `Inter → Libertinus Sans → Fira Code` if the primary
fonts are missing; those fallback warnings from Typst are harmless when the
primary font resolves.

## Syntax highlighting

Code panes use the `dark.tmTheme` TextMate theme (`touying/themes/dark.tmTheme`).
Idris 2 is currently highlighted with Haskell grammar — close enough for demo
purposes. If `idris.sublime-syntax` becomes available in a future Typst release,
swap it in via the `lang` argument to `code-pane`.

## Presenter view (pympress)

[pympress](https://github.com/Cimbali/pympress) is the recommended PDF
presenter tool on Linux.

```bash
pip install pympress   # or: sudo apt install pympress
pympress talk.pdf
```

Key bindings during presentation:

| Key | Action |
|-----|--------|
| `→` / `Space` | Next slide |
| `←` | Previous slide |
| `F` | Toggle fullscreen |
| `N` | Toggle notes pane |
| `G` | Go to slide (type number) |
| `P` | Pause/blank screen |
| `Q` | Quit |

Speaker notes are embedded in the PDF (PDF annotations); pympress renders them
in the presenter window automatically.
