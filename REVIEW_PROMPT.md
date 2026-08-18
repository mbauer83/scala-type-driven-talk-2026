# Adversarial review — Type-Driven Programming talk, Acts 0–2

You are reviewing a conference talk for a **Java meetup, Thursday 20 August,
45 minutes hard**. Audience: working Java developers, mixed seniority, little
FP or type-theory background. Delivery is in two days, so your job is to find
what will fail in the room, not to redesign the talk.

**Be adversarial. Agreeable review is worthless here.** The author has already
had one round of "this is fine" that turned out to be wrong. Assume there are
real defects and go find them. Equally: do not manufacture findings to look
thorough — a short, high-signal list beats a long one, and a false positive
costs more than a miss, because it burns time we do not have.

## What to review

```
touying/slides/01-title.typ        A0-title
touying/slides/02-alice.typ        A0-incidents
touying/slides/06-pattern.typ      A0-turn
touying/slides/07-toolkit.typ      A1-aristotle
touying/slides/a1-connectives.typ  A1-connectives
touying/slides/a1-quantifiers.typ  A1-quantifiers
touying/slides/08-crisis.typ       A1-crisis
touying/slides/curry-howard.typ    A1-curry-howard
touying/slides/a1-above.typ        A1-above
touying/slides/a2-values.typ       A2-values
touying/slides/a2-promises.typ     A2-promises
```

Each slide pulls its speaker script from `touying/scripts/*.md` via `#read()`.
**Review both the slide and its script.** In a script, only text inside double
quotes is spoken aloud; everything else is notes to the speaker. Judge spoken
text as speech and slide text as slide copy — they have different standards.

**Ignore every other slide.** Acts 3–6 are still last year's prose and are known
to be unpolished; findings there are noise.

## Look at the rendered slides, not only the source

Half of the known defects are layout. Render and actually look:

```
typst compile touying/deck.typ 'out/p{n}.png' --pages 2-12 --ppi 110
```

Page numbers map to the list above in order (page 1 = `01-title`, page 12 =
`a2-promises`). Judge spacing, balance, whether anything overflows or crowds the
footer rail, and whether the eye lands on the right thing first.

## Verify every factual and code claim

Do not take a slide's word for anything.

- Java sources: `02-java5-generics/`, `03-java-function-types-sealed/`
- Scala: `05-scala3-payment/`, Idris: `06-idris2-payment/src/`
- `grep` every identifier, signature and line reference before accepting it.
  Slides have shipped with a one-argument version of a three-argument function
  more than once.
- Historical and mathematical claims (Boole, Frege, Russell, Gödel, Rice,
  Curry-Howard, Lambek, Martin-Löf, parametricity) must be checked, not
  recognised. "Sounds right" is not checked.

## The criteria

Read `TALK_V2_PLAN.md` **Part 8** (thirteen standing corrections), **Part 9**
(eleven lessons on register) and **Part 12** (register faults, rules R1–R7)
before you start. They are the house style and they are non-negotiable. In
particular:

1. **Register.** No machine-sounding prose. The named faults: defining by
   exclusion ("none of this is X"); balanced clauses with no content in either
   half ("the X is the claim, the Y is what makes good on it"); the talk
   narrating itself ("I am deliberately not going to teach them"); enumerate-
   then-declare ("[n] X, [remark about the count]"); flat runs of short
   declaratives. **Shortening everything is not the fix** — varied rhythm with
   real subordination is.
2. **No sentence may exist to explain another element of the same slide.** If a
   caption is needed to explain a layout, the layout is wrong. Say so.
3. **Headlines name a concept**, they are not lines of speech.
4. **Lead with the capability or the problem**, then the notation, then the
   code. Ask of every slide's opening: *why are you telling me this?* If the
   slide only answers at the end, that is a finding.
5. **Do not overclaim.** The weaker claim is usually the stronger argument.
   Flag anything a competent Java developer could immediately counterexample.
   Flag anything technically imprecise that a type-theory-literate attendee
   would catch.
6. **Keep three things distinct**: the *program* (the construction), the *type*
   (the proposition), the *checker*. Blurring "the logic in the program"
   (`if (a && b)`) with "the logic about the program" is the single failure
   that would sink the primer.
7. **Time.** The deck measures 42:12 against a 45:00 slot at 140 wpm; Act 1 is
   1:37 over its own budget. Every fix you propose must state its word-count
   cost. A fix that adds 40 words is usually not a fix.
8. **Joins.** Read the last spoken sentence of each slide against the first of
   the next. Beats can each be right while the sequence is unreadable.
9. **Audience fit.** Jargon this room does not share, examples outside the
   payment domain the talk establishes, anything that positions the audience as
   pupils rather than practitioners.

## Output format — follow this exactly

Start with the summary table, then the findings, then the three closing
sections. No preamble, no restatement of the brief.

```
## Summary

| ID | Slide | Sev | Category | One-line |
|----|-------|-----|----------|----------|
| F-01 | A1-crisis | MAJOR | register | ... |
```

Then one block per finding, in the same order:

```
### F-01 · A1-crisis · MAJOR · register

WHERE    touying/scripts/07-crisis.md:34   (or: rendered slide, lower-left)
QUOTE    "the exact text, verbatim and greppable"
FAULT    One sentence. What is wrong.
IMPACT   One sentence. What the audience does or thinks as a result.
FIX      A concrete replacement, written out — not a direction to go in.
COST     +12 words / -3 words / none
CONF     high | medium | low
```

Field rules, because they are what make this usable:

- **ID** — `F-01`, `F-02`, … sequential, stable. I will refer to them by number.
- **Sev** — `BLOCKER` (wrong, or will visibly fail on stage) · `MAJOR` (weakens
  the argument or the credibility) · `MINOR` (would improve it). Be strict:
  BLOCKER means factually wrong, broken layout, or a claim that gets challenged
  from the floor.
- **Category** — exactly one of: `factual` · `overclaim` · `register` ·
  `structure` · `layout` · `clarity` · `audience-fit` · `time` · `join` ·
  `c13-equivocation`.
- **QUOTE** — verbatim, so I can `grep` it. If the finding is about layout and
  has no text, write `QUOTE  (layout)` and describe the region precisely.
- **FIX** — write the actual replacement sentence. A fix I have to invent myself
  is half a finding. If the honest fix is structural, describe the structure in
  two sentences, concretely.
- **CONF** — `low` is fine and useful. Mark `low` rather than dropping a hunch,
  and mark `low` on anything you could not verify against source.

Then:

```
## Do not change

Things that are working and that a well-meaning edit would break. Be specific —
name the slide and the element. This section stops me regressing them.

## Open questions for the speaker

Things only the author can decide (taste, personal stories, what he wants to
claim). Phrase each as a closed question with the options.

## Top five, ranked

If only five findings get fixed before Thursday, these, in order, with one line
each on why this one over the others.
```

## Do not

- Do not rewrite slides wholesale or attach a revised deck.
- Do not propose adding material, new slides, or scope. The budget is closed.
- Do not restate the brief, summarise the talk back, or open with praise.
- Do not report a finding you could not locate in a file or a render.
- Do not soften. If a slide is bad, the finding is that the slide is bad, and
  the FIX field says what replaces it.
