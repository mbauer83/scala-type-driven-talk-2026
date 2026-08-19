# Speaker scripts — edit these, not the .typ files

Each file here is the verbatim script for one slide. The slide pulls it in with
`#read("../scripts/<name>.md")`, so **this directory is the single source of
truth**: the PDF, the pdfpc presenter notes, the word counts and the prose
linter all read the same file you edit. There is no second copy to keep in sync.

| script | slide | id |
|---|---|---|
| `01-title.md` | `slides/01-title.typ` | `A0-title` |
| `02-incidents.md` | `slides/02-alice.typ` | `A0-incidents` |
| `03-the-turn.md` | `slides/06-pattern.typ` | `A0-turn` |
| `04-aristotle.md` | `slides/07-toolkit.typ` | `A1-aristotle` |
| `05-connectives.md` | `slides/a1-connectives.typ` | `A1-connectives` |
| `06-quantifiers.md` | `slides/a1-quantifiers.typ` | `A1-quantifiers` |
| `07-crisis.md` | `slides/08-crisis.typ` | `A1-crisis` |
| `08-curry-howard.md` | `slides/curry-howard.typ` | `A1-curry-howard` |
| `09-above.md` | `slides/a1-above.typ` | `A1-above` |
| `10-scenario.md` | `slides/15-test-spine.typ` | `A2-scenario` |
| `11-promises.md` | `slides/a2-promises.typ` | `A2-promises` |
| `12-stage12.md` | `slides/17-stage1.typ` | `A3-stage12` |
| `13-gentzen.md` | `slides/10-gentzen-or.typ` | `A3-gentzen` |
| `14-stage3.md` | `slides/19-stage3.typ` | `A3-stage3` |
| `15-demo1.md` | `slides/a3-demo1.typ` + `-edit` + `-out` | `A3-demo1` |
| `16-payoff-bob.md` | `slides/20-stage3-payoff.typ` | `A3-payoff-bob` |
| `17-stage4.md` | `slides/22-stage4.typ` | `A3-stage4` |
| `18-demo2.md` | `slides/a3-demo2.typ` + `-edit` + `-out` | `A3-demo2` |
| `19-ceiling.md` | `slides/24-java-ceiling.typ` | `A3-ceiling` |
| `20-stage5.md` | `slides/25-stage5.typ` | `A4-opens` |
| `21-demo3.md` | `slides/a4-demo3.typ` + `-edit` + `-out` | `A4-demo3` |
| `22-sessions.md` | `slides/26-session-types.typ` | `A4-sessions` |
| `23-mechanisms.md` | `slides/stage5-mechanisms.typ` | `A4-mechanisms` |
| `24-ceiling.md` | `slides/27-stage5-payoff.typ` | `A4-ceiling` |
| `25-mltt.md` | `slides/28-stage6-bridge.typ` | `A5-mltt` |
| `26-demo5.md` | `slides/a5-demo5.typ` + `-edit` + `-out` | `A5-demo5` |
| `27-payoff.md` | `slides/30-stage6-payoff.typ` | `A5-payoff` |
| `28-cost.md` | `slides/32-agentic.typ` | `A6-cost` |
| `29-now.md` | `slides/a6-now.typ` | `A6-now` |
| `30-monday.md` | `slides/where-to-start.typ` | `A6-monday` |
| `31-close.md` | `slides/34-close.typ` | `A6-close` |

That is all thirty-one, and the deck is fully scripted.

**Two script numbers are out of deck order and were left that way.** `deck.typ`
runs `19-stage3` before `10-gentzen-or`, so `14-stage3` should be 13 and
`13-gentzen` should be 14. Renumbering means editing both files, both `#read()`
calls and this table, on the day before delivery, to fix a mismatch this table
already resolves. Do it after Thursday. Everything from `20-` on is consecutive
and in deck order.

**Script numbers are consecutive and follow the running order in `deck.typ`.**
They drifted once, on 18 Aug, when `10-values.md` was cut and its replacement
was written as `12-scenario.md`; renumbering is cheap and a gap in the sequence
is the kind of thing that costs a minute to resolve on the night. If a script is
added or removed, renumber the rest and fix the `#read()` calls.

## The shape of a script

Three sections, always in this order:

- **TALKING POINTS** — the whole slide as a short numbered list, no rationale in
  it. This is what the presenter view opens on and what you glance at mid-beat.
- **VERBATIM** — the script, in double quotes. The word counter and the prose
  linter read this and nothing else.
- **PREPARATION** — below a rule, marked *not for the night*: why the slide is
  shaped this way, corrections already applied, grepped citations, and Q&A
  material. Never read on stage.

The script stems and the *slide* stems still do not match — several v2 slides
reuse a v1 file. **The id column is the name to use in conversation and in the
plan** (Part 8/C12); slide file names are an implementation detail that has
already drifted twice.

## The one formatting rule

**What you say goes in double quotes. Everything outside quotes is notes to
yourself and is ignored** — by the word counter, by the linter, and by you on
the night. That is how a file can hold both the script and its own commentary
without the commentary inflating the timing.

```
"This sentence is spoken and counted."

Anything out here is a reminder, a fact-check, or a warning. Not counted.
```

Plain text. No Typst syntax needed, and no Typst hazards either — `#read()`
returns a string, and a string in content position renders literally rather than
being re-parsed. A leading `#`, an unbalanced bracket, `*asterisks*` and `$x$`
all compile fine. (An earlier version of this file warned otherwise; it was
teaching a constraint that does not exist.)

**Caps live in `tools/budget.tsv`, not here and not in the file headers.** Word
counts are computed by `make timing`. Both drifted when they were written in
three places.

One thing that DOES matter: **an odd number of `"` in a file** silently swaps
which half is treated as speech. The linter now errors on it.

**And a quoted sentence in a PREPARATION block is counted as speech.** The
counter reads every `"…"` in the note, not just the ones above the rule, so a
quotation below it inflates the slide's measured length and lints against the end
of the real script. Ten scripts had this on 19 Aug — Act 1's numbers were up to
29 words too high, which is 12 seconds on one slide. Use `»…«` or italics below
the rule; `make timing` is only as honest as this convention.

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
