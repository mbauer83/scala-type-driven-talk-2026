# Continue the Type-Driven Programming talk — session brief

## The job

Finish a 45-minute conference talk. **Delivery is Thursday 20 August; one
working day remains.** Audience: a Java meetup in Köln — working developers,
mixed seniority and mixed depth, little FP or type-theory background.

Acts 0–3 are written and reviewed. **Act 4 (Scala, 5 slides + Demo 3) is next,
then Act 5 (3), Act 6 (3), and Demos 3 and 4.**

## Read these first, in this order

1. `TALK_V2_PLAN.md` **Part 15** — state of play, next steps, standing decisions
   that are easy to lose. Everything else in this brief is a summary of it.
2. **Parts 8, 9, 12 and 14** — the accumulated corrections. C1–C13, L1–L26,
   R1–R15. Every one records a mistake already made once, most of them by me.
3. `touying/scripts/README.md` — the script format and the conventions that
   break the tooling if you get them wrong.

## How the deck is built

Typst + touying. `touying/deck.typ` is the entry point and its `#include` order
**is the running order**. One `.typ` per slide in `touying/slides/`; the speaker
script lives in `touying/scripts/NN-name.md` and is pulled in with `#read()`.

Two conventions, and missing either will corrupt your work:

- **Only double-quoted text in a script is spoken.** The word counter and the
  linter read exactly that and nothing else. Never put `"` in a TALKING POINTS
  line, a runbook direction, or a prep note — use backticks, `»`, or italics.
- **Sizes are slide-plan px against a 1920×1080 canvas, halved at render.**
  `sz(60pt)` is 60 px of a 1080-px slide; `sz(21pt)` is a small caption. Judge
  legibility on that basis. **Code below ~19 px does not survive the back of a
  room** — this has been a finding twice.

Every script has three sections, in this order and no other:

```
TALKING POINTS   short numbered lines, no rationale. What the presenter
                 view opens on and what he glances at mid-beat.
VERBATIM         the script, in double quotes. Counted and linted.
PREPARATION      below a rule, marked "not for the night": why the slide is
                 shaped this way, corrections applied, grepped citations, Q&A.
```

## Commands

```bash
make check                 # build + prose lint + per-slide timing
make talk-png              # 1920×1080 PNG per slide into slides/png/
make talk-notes            # PDF with each note rendered on its slide
typst compile --root . touying/deck.typ out.png --pages N --ppi 144
./tools/capture-terminal.sh   # re-record the demo terminal frames
```

`--root .` is required — several slides `#read()` files above `touying/`.

**Render and look at every slide you touch.** Half the defects found in this
project were layout and were invisible in source.

## The rules that matter most

The linter enforces what it can. These are the ones it cannot see:

1. **Do not overclaim.** The weaker claim is the stronger argument. Before
   writing "every stage does X" or "language L cannot do Y", write the cases out
   and check them one at a time. Both of those exact sentences were wrong here.
2. **Define positively.** Never "this is not X" — naming the wrong idea plants
   it. If a wrong reading is available, change the slide until it is not.
3. **No sentence may exist to explain another element of the same slide.** If a
   caption is needed to explain a layout, the layout is wrong.
4. **A headline names a concept**, not a line of speech.
5. **Lead with the capability or the problem**, then the notation, then the code.
6. **No metaphor the talk has not issued** — "the climb", "the ladder", "the
   top" are invisible until a sentence issues them.
7. **Introduce before use.** Technical terms are welcome where the beat teaches
   them, and wrong where it does not. The room is mixed: a term standard for
   half of it still needs introducing.
8. **Verbatim-from-source is a means, not the end.** An example that cannot
   carry the point should be visibly illustrative rather than real-but-useless.
9. **Grep every identifier against the code before it goes on a slide.**
   `00-…` through `06-idris2-payment/` are the real sources.

## Failure modes I repeated — do not repeat them

- **`str.replace` that silently matches nothing.** Assert every substitution,
  and grep the result afterwards. A fix was reported as landed three times when
  it had not.
- **Fixing the script and leaving the slide.** The same correction lives in two
  files. `tools/retired.tsv` now fails the build if retracted wording reappears
  anywhere — **add to it whenever something is retracted.**
- **Adding words while "fixing" something.** Every slide has a cap in
  `tools/budget.tsv`; check the delta after every edit.
- **Reporting work as done without running `make check`.**

## Budget

Planning rate is **140 wpm** and stays there. MB measured **181 wpm** standing
across slides 1–12, and has said explicitly not to plan against his own pace —
the discount covers nerves, questions and audience pauses.

Caps are a pacing decision. When a slide needs more time, **move** it from a
named slide that measured under, and say which. Never shave a few seconds off
several slides to make the arithmetic work.

## Working relationship

MB writes and rewrites his own prose, and his rewrites have been better than
mine every time — the lessons drawn from them are Part 9. When you change a
sentence of his, flag it (C11). He reviews in passes and sends long, specific
lists; work through them in order and say plainly which you rejected and why.
Do not be agreeable about things that are wrong, and do not defend things that
are.

## First actions

1. `make check` — see the current state.
2. Read `TALK_V2_PLAN.md` Part 15, then Parts 8/9/12/14.
3. Look at `touying/slides/24-java-ceiling.typ` and its script: it is the last
   slide of Act 3 and the joint Act 4 has to pick up from. It ends on residual
   failure, which is D-C option (d).
4. Start Act 4. Five slides, one thread through the Scala stage (D-A/c).
