# Adversarial review — Type-Driven Programming talk, Acts 0–2

## The job

Review a conference talk for a **Java meetup, Thursday 20 August, 45 minutes
hard**. Audience: working Java developers, **mixed seniority and mixed depth**,
mostly little FP or type-theory background. Delivery is in two days, so find what
will fail in the room — do not redesign the talk.

**Be adversarial. Agreeable review is worthless here.** The author has already
had one round of "this is finished" that turned out to be wrong. Assume real
defects and go find them. Equally, do not manufacture findings to look thorough:
a short high-signal list beats a long one, and a false positive costs more than a
miss because it burns time that does not exist.

---

## How to read this repository

**The deck** is Typst + touying. `touying/deck.typ` is the entry point and its
`#include` order **is the running order** — page N of the PDF is the Nth include.

| path | what it is |
|---|---|
| `touying/slides/*.typ` | one file per slide. `//` comments are authoring notes and never appear on screen |
| `touying/scripts/*.md` | the speaker script for a slide, pulled in by `#read()` |
| `touying/components.typ`, `theme.typ`, `code-pane.typ` | the visual system — **signed off, out of scope** |
| `touying/COMPONENTS.md` | the component API, if you need to know what a call does |
| `tools/budget.tsv` | per-slide airtime cap. Single source of truth for durations |
| `tools/talk-timing.py` | word counts → minutes at a given rate |
| `tools/prose-lint.py` | the mechanical register rules; read the rule tables at the top, they encode faults already found |
| `TALK_V2_PLAN.md` | the plan. **Parts 8, 9 and 12 are the house style** |
| `00-…` … `06-idris2-payment/` | the code ladder the talk demonstrates — **fixed, out of scope** |
| `demos/` | real captured compiler output for the four live demos |

**Two conventions you must know or you will misread everything:**

1. **In a script, only text inside double quotes is spoken aloud.** Everything
   else is notes to the speaker — beats, fact-checks, warnings — and is not
   counted or delivered. Judge quoted text as *speech* and slide text as *slide
   copy*; they have different standards. A slide carrying cues rather than a full
   script declares `EST-WORDS: n` instead.

2. **Every size in a slide file is in "slide-plan px" against a 1920×1080
   canvas, and is halved at render** (`sz(t)` = `t * 0.5`, page is 960×540 pt).
   So `sz(60pt)` is 60 px of a 1080-px-tall slide, and `sz(21pt)` is 21 px — a
   small caption, not "21 point type". Judge legibility on the 1920×1080 basis.

---

## Commands

```bash
make check            # build + prose lint + per-slide timing, all three
make talk-png         # 1920×1080 PNG per slide into slides/png/ — exact projected pixels
make talk-notes       # PDF with each speaker note rendered visibly on its slide
python3 tools/talk-timing.py --wpm 140
python3 tools/prose-lint.py --all
```

**Look at the rendered slides.** Half of the known defects are layout and are
invisible in source. `make talk-png` gives you exactly what the projector shows.

---

## Scope

| page | file | id | in scope |
|---|---|---|---|
| 1 | `slides/01-title.typ` | A0-title | yes |
| 2 | `slides/02-alice.typ` | A0-incidents | yes |
| 3 | `slides/06-pattern.typ` | A0-turn | yes |
| 4 | `slides/07-toolkit.typ` | A1-aristotle | yes |
| 5 | `slides/a1-connectives.typ` | A1-connectives | yes |
| 6 | `slides/a1-quantifiers.typ` | A1-quantifiers | yes |
| 7 | `slides/08-crisis.typ` | A1-crisis | yes |
| 8 | `slides/curry-howard.typ` | A1-curry-howard | yes |
| 9 | `slides/a1-above.typ` | A1-above | yes |
| 10 | `slides/15-test-spine.typ` | A2-scenario | **no** — still v1, known unpolished. Judge only its *join* to page 11 |
| 11 | `slides/a2-values.typ` | A2-values | yes |
| 12 | `slides/a2-promises.typ` | A2-promises | yes |

**Everything from page 13 onward is out of scope.** Acts 3–6 are still last
year's prose, known to fail the linter in ~19 places, and scheduled for rework.
Findings there are noise.

---

## Constraints you must respect

A finding that ignores these is unusable.

- **45:00 hard.** The deck currently measures **42:23** of prose at 140 wpm, so
  there is roughly **2:30 of slack for the whole talk** — and Act 1 alone is
  1:37 over its own internal budget. **Every fix you propose must state its
  word-count cost.** A fix that adds forty words is usually not a fix.
- **Four live demos sit in Acts 3–5 and consume 9:15** of the slot. They are
  unwritten. Do not propose anything that spends their time.
- **No new slides, no new material, no scope.** The budget is closed.
- **The code ladder is fixed** and is not being changed for the talk.
- **The visual system is fixed** — palette, type scale, slide classes. Layout
  findings should be about *this slide's* arrangement, not about the design.
- **Freeze is Wednesday 16:00.** Anything not fixed by then ships as-is.

---

## Criteria A — the house rules

Read `TALK_V2_PLAN.md` **Part 8** (thirteen standing corrections), **Part 9**
(eleven lessons from the prose diff) and **Part 12** (register faults, R1–R8)
before you start. They are non-negotiable and every one records a mistake already
made once. In particular:

1. **Register.** No machine-sounding prose. Named faults: defining by exclusion
   ("none of this is X"); balanced clauses with no content in either half ("the X
   is the claim, the Y is what makes good on it"); the talk narrating itself ("I
   am deliberately not going to teach them"); enumerate-then-declare ("[n] X,
   [remark about the count]"); flat runs of short declaratives. **Shortening
   everything is not the fix** — varied rhythm with real subordination is.
2. **No sentence may exist to explain another element of the same slide.** If a
   caption is needed to explain a layout, the layout is wrong; say so.
3. **A headline names a concept.** It is not a line of speech.
4. **Lead with the capability or the problem**, then the notation, then the code.
   Ask of every slide's *opening line*: why are you telling me this? If the slide
   only answers at the end, that is a finding.
5. **Do not overclaim.** The weaker claim is the stronger argument. Flag anything
   a competent Java developer could immediately counterexample, and anything
   imprecise that a type-theory-literate attendee would catch.
6. **Keep three things distinct**: the *program* (the construction), the *type*
   (the proposition), the *checker*. Blurring "the logic in the program"
   (`if (a && b)`) with "the logic about the program" is the single failure that
   would sink the primer.
7. **Introduce before use, and the room is mixed.** The talk **may** use
   technical terms — it has to name and explain them first, at the beat where the
   technique is the subject. Two faults: a term used *before* the beat that
   teaches it, and a term used *in passing* where teaching it costs more than the
   name earns. "A good half of a meetup crowd would not place this noun *here*"
   is a finding, not a quibble — especially when the term arrives next to an
   unfamiliar idea, so two things must be resolved at once.
8. **Joins.** Read the last spoken sentence of each slide against the first of
   the next. Beats can each be right while the sequence is unreadable.
9. **Verify every claim.** `grep` every identifier, signature and line reference
   against `02-java5-generics/`, `03-java-function-types-sealed/`,
   `05-scala3-payment/`, `06-idris2-payment/src/`. A slide has shipped with a
   one-argument version of a three-argument function more than once. Historical
   and mathematical claims (Boole, Frege, Russell, Hilbert, Gödel, Rice,
   Church, Curry-Howard, Lambek, Martin-Löf, Coquand, parametricity) must be
   checked, not recognised. "Sounds right" is not checked.

## Criteria B — general talk quality

Independent of the house rules. Judge the talk as a talk.

10. **Does it deliver its promise?** Slide 1 claims that writing a program which
    type-checks is, *in a precise sense*, the same act as constructing a proof.
    Trace that promise through Acts 0–2. Is it discharged, dodged, or quietly
    weakened?
11. **Argument integrity.** Does each claim follow from what precedes it? Is
    anything asserted and never supported? Is any step doing work it has not
    earned?
12. **Does every slide earn its airtime?** For each, say what would actually be
    lost if it were cut. A slide that survives that question weakly is a finding
    given 2:30 of slack.
13. **Redundancy.** v1's central failure was telling every idea twice — once
    abstractly, once concretely. Flag anything said twice, on a slide or across
    slides.
14. **Narrative arc.** Setup, tension, payoff. Does the primer read as a climb or
    as a detour? Does Act 2 feel like an arrival or an interruption?
15. **The one-sentence test.** Could an attendee restate the thesis accurately
    the next morning? If not, which slide should have made that possible?
16. **Legibility at projection distance.** Smallest text on each slide, contrast,
    code-pane font size, and anything distinguished by colour alone. Judge on the
    1920×1080 render, imagining the back of a room.
17. **Cognitive load.** How many new things does a slide introduce at once? Can
    the audience read it and listen at the same time, or are they doing both?
18. **Robustness.** Does the deck survive a failed demo, a projector that eats
    contrast, and running five minutes late?
19. **Stance.** The speaker should read as a practitioner among practitioners,
    not as a lecturer. Flag anything that makes the audience pupils.

---

## Output format — follow this exactly

No preamble, no summary of the talk back, no praise section at the top.

```
## Summary

| ID | Slide | Sev | Category | One-line |
|----|-------|-----|----------|----------|
| F-01 | A1-crisis | MAJOR | register | ... |
```

Then one block per finding, same order:

```
### F-01 · A1-crisis · MAJOR · register

WHERE    touying/scripts/07-crisis.md:34   (or: rendered page 7, lower-left)
QUOTE    "the exact text, verbatim and greppable"
FAULT    One sentence. What is wrong.
IMPACT   One sentence. What the audience does or thinks as a result.
FIX      A concrete replacement, written out — not a direction to go in.
COST     +12 words / -3 words / none
CONF     high | medium | low
```

Field rules, because they are what make this usable:

- **ID** — `F-01`, `F-02`, … sequential and stable. They will be referred to by
  number.
- **Sev** — `BLOCKER` (factually wrong, broken layout, or a claim that gets
  challenged from the floor) · `MAJOR` (weakens the argument or the speaker's
  credibility) · `MINOR` (would improve it). Be strict about BLOCKER.
- **Category** — exactly one of: `factual` · `overclaim` · `register` ·
  `structure` · `argument` · `redundancy` · `layout` · `legibility` ·
  `clarity` · `audience-fit` · `time` · `join` · `c13-equivocation` ·
  `robustness`.
- **QUOTE** — verbatim, so it can be `grep`ped. For a layout finding with no
  text, write `QUOTE  (layout)` and describe the region precisely.
- **FIX** — write the actual replacement sentence. A fix that has to be invented
  by the reader is half a finding. If the honest fix is structural, describe the
  structure concretely in two sentences.
- **COST** — word delta of your fix. Required. Say `none` if it is neutral.
- **CONF** — `low` is useful. Mark `low` rather than dropping a hunch, and mark
  `low` on anything you could not verify against source.

Then:

```
## Do not change

Things working well that a well-meaning edit would break. Name the slide and the
element. This section exists to prevent regressions.

## Open questions for the speaker

Decisions only the author can make — taste, personal stories, how strong a claim
he wants to stand behind. Phrase each as a closed question with the options.

## Top five, ranked

If only five findings get fixed before Thursday, these, in order, one line each
on why this one and not another.
```

---

## Do not

- Do not rewrite slides wholesale or attach a revised deck.
- Do not propose new slides, new material, or scope changes.
- Do not restate the brief or summarise the talk back.
- Do not report a finding you could not locate in a file or a render.
- Do not report findings on out-of-scope pages, the visual system, or the code.
- Do not soften. If a slide is bad, the finding is that the slide is bad, and the
  FIX field says what replaces it.
