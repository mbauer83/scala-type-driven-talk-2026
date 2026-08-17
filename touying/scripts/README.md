# Speaker scripts — edit these, not the .typ files

Each file here is the verbatim script for one slide. The slide pulls it in with
`#read("../scripts/<name>.md")`, so **this directory is the single source of
truth**: the PDF, the pdfpc presenter notes, the word counts and the prose
linter all read the same file you edit. There is no second copy to keep in sync.

| script | slide | cap |
|---|---|---|
| `01-title.md` | `slides/01-title.typ` | 0:35 |
| `02-incidents.md` | `slides/02-alice.typ` | 2:35 |
| `03-the-turn.md` | `slides/06-pattern.typ` | 1:50 |

## The one formatting rule

**What you say goes in double quotes. Everything outside quotes is notes to
yourself and is ignored** — by the word counter, by the linter, and by you on
the night. That is how a file can hold both the script and its own commentary
without the commentary inflating the timing.

```
"This sentence is spoken and counted."

Anything out here is a reminder, a fact-check, or a warning. Not counted.
```

Plain text. No Typst syntax needed. Two things to avoid, because the file is
included into Typst markup: unbalanced `[` or `]`, and a leading `#` on a line
(it would be read as code). Both are caught immediately by `make check`.

## After editing

```
make check          # build + prose lint + timing, in one go
make check WPM=150  # your measured read rate rather than the planning rate
```

`make check` reports three things: whether the deck still compiles, whether any
script trips the prose rules, and how long each slide now runs against its cap.

## What the prose linter rejects

It encodes the constructions that read as machine-written, and it applies to
anything in quotes regardless of who typed it:

- `not just X but Y` and its variants — state the thing directly
- three consecutive short sentences used for cadence
- a one-or-two-word sentence dropped after a long one, more than once
- three sentences opening with the same two words
- padding (`in order to`, `at the end of the day`, `at its core`, …)
- a rhetorical question answered by its own next sentence
- stock kickers
- **four consecutive sentences of 4–15 words, or low length variation overall** —
  a flat run of short declaratives is its own tell, and it is what you get if you
  "fix" prose by shortening everything

Warnings, which do not block: AI-register diction, dashes used as drama,
superlatives the audience cannot check, and sentences over 35 words (a delivery
risk in a second language, not a register fault).
