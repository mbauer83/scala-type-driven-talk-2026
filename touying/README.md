# Touying slide deck

Typst-based presentation for *Type-Driven Development: A Practical Journey*.

## Build commands

Run all commands from the **repo root** (not from `touying/`).

```bash
make              # build talk.pdf (default)
make talk.pdf     # same as above
make talk.pdfpc   # build speaker-notes sidecar (for the pdfpc presenter tool)
make talk-notes   # build talk-with-notes.pdf (notes rendered inline per slide)
make talk-html    # export to HTML for browser-based presenter
make talk-pptx    # export to PPTX
make talk-svg     # export slides/svg/slide-NN.svg (one per page)
make talk-png     # export slides/png/slide-NN.png at 1920×1080 144 ppi
make watch        # live-reload into talk.pdf on every save
make clean        # delete generated artefacts
```

## Requirements

**Build tools (WSL2 / Linux):**

- **Typst** 0.11 or later (tested with 0.14.2):
  ```bash
  curl -fsSL https://typst.app/install.sh | sh
  # or: snap install typst
  ```

- **touying** Python CLI 0.14+ (HTML, PPTX, pdfpc exports):
  ```bash
  pip install touying
  ```

**Presenter tools (Windows):**

- **pdfpc** — reads `talk.pdfpc` and displays text speaker notes in a
  dedicated presenter window. Install via Scoop:
  ```powershell
  scoop install pdfpc
  ```
  Or download the `.msi` from https://github.com/pdfpc/pdfpc/releases.

- **pympress** — good PDF presenter but shows only PDF-embedded notes
  (beamer / LibreOffice page-split style), **not** pdfpc text notes. Useful
  for navigating slides; install via winget if desired:
  ```powershell
  winget install Cimbali.pympress
  ```

## Font installation

Two fonts must be available system-wide (or in `touying/fonts/`):

**IBM Plex Sans** — body text and headings
```bash
sudo apt install fonts-ibm-plex
# or manually: https://github.com/IBM/plex/releases → ~/.local/share/fonts/
fc-cache -f
```

**JetBrains Mono** — code panes and monospace labels
```bash
sudo apt install fonts-jetbrains-mono
# or manually: https://github.com/JetBrains/JetBrainsMono/releases → ~/.local/share/fonts/
fc-cache -f
```

Verify:
```bash
typst fonts | grep -E "IBM Plex|JetBrains"
```

The theme falls back to `Inter → Libertinus Sans → Fira Code` if the primary
fonts are missing; those fallback warnings from Typst are harmless.

## Syntax highlighting

Code panes use `touying/themes/dark.tmTheme`. Idris 2 is highlighted with
Haskell grammar — close enough for demo purposes.

## Presenter workflow (WSL2 + Windows)

Build outputs land in the repo root inside WSL2. Access them from Windows via:
```
\\wsl$\<distro>\home\mb\workspace\scala-type-driven-talk\
```
(Replace `<distro>` with your WSL distro name, e.g. `Ubuntu`.)

### Primary: pdfpc with text speaker notes

```bash
make talk.pdf talk.pdfpc
```

Then from Windows PowerShell/CMD (pdfpc finds `talk.pdfpc` by stem automatically):
```powershell
pdfpc \\wsl$\Ubuntu\home\mb\workspace\scala-type-driven-talk\talk.pdf
```

pdfpc key bindings:

| Key | Action |
|-----|--------|
| `→` / `Space` | Next slide |
| `←` | Previous slide |
| `F5` / `F` | Toggle fullscreen |
| `N` | Toggle notes font size |
| `G` | Go to slide (type number) |
| `B` | Blank screen |
| `Q` / `Esc` | Quit |

### Fallback: browser-based HTML presenter

```bash
make talk-html
```

Open `talk.html` from Windows (via `\\wsl$\...` in Explorer, or copy to
the Windows filesystem). Speaker notes are embedded in the HTML.

**To open the presenter console:** press `P` in the browser. This opens
the impress.js impressConsole, which shows the current slide, next slide,
speaker notes, and a timer.

**Verifying on one screen:** the presenter console opens in a separate
browser window. Tile the two windows side by side to verify notes are
correct before the event. On the day, move the console window to your
laptop display and the main window to the projector.

### Inline notes PDF

`make talk-notes` compiles `talk-with-notes.pdf` with every speaker note
rendered as a visible block after its slide — useful for proof-reading or
printing a speaker sheet.
