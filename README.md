# Type-Driven Programming — Correctness by Construction

Slides, speaker scripts and runnable example code for the talk *Type-Driven
Programming: Correctness by Construction, from the Basics to the Cutting Edge*.

The deck walks one payment flow up a ladder of type systems — untyped
JavaScript, Java, Scala 3, Idris 2 — and closes four real bugs along the way,
live, in front of the room.

## Layout

| path | what it is |
|---|---|
| `touying/` | the deck. `deck.typ` is the running order; `slides/*.typ` are the slides; `scripts/*.md` are the speaker scripts and the single source of every note |
| `tools/` | build and quality tooling — notes export, PPTX and presenter builders, prose linter, timing model, demo capture |
| `demos/` | real compiler output, captured from the real toolchains, rendered on the demo slides as fallbacks |
| `00-…` … `06-…` | the example ladder, one directory per stage, each independently buildable |

`touying/scripts/README.md` has the script-to-slide map, the demo pre-flight and
the editor setup.

## Build

```
make            # talk.pdf and the notes sidecar
make check      # build + prose lint + timing against the slot
make talk-pptx      # slides with the speaker notes as real text
make talk-presenter # two-window browser presenter
make talk-notes     # a PDF with the notes printed under each slide
```

Requires `typst`. `make talk-pptx` additionally needs Python; dependencies are
declared in `pyproject.toml` and pinned in `uv.lock`:

```
uv sync            # creates .venv from the lockfile
uv run make talk-pptx
```

## Presenting

`talk.pptx` in LibreOffice Impress or PowerPoint is the primary artifact — the
notes are real text, so presenter view, timer and next-slide thumbnail all work.
`presenter/` is a self-contained two-window browser alternative. `talk.pdf` is
the no-notes fallback.

Run the demo pre-flight in `touying/scripts/README.md` before presenting.

## Releases

Tagging `v*` builds and attaches `talk.pdf`, `talk.pptx` and `presenter.zip`.

## Licence

See `LICENSE`.
