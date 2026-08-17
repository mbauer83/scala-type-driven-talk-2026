# Talk v2 — Rework Plan (DRAFT 1, for review)

Branch `talk-v2-rework`, off `talk-v1` (`93c8d95`). 45 min + 15 Q&A, Java Meetup Cologne.

**Status: draft for review. No slide files changed yet.**

Inputs considered but treated as *proposals, not decisions*: `PRESENTATION_SLIDE_PLAN.md`
(drifted from the deck), `REFACTOR_STAGE4_REMOVAL.md` and `DOMAIN_REWORK.md` (both verified
unexecuted — 0/19 checklist boxes, none of their identifiers exist in code or slides).

---

## Part 0 — What's wrong with v1

Not the visual design; that is good and stays. Four structural problems:

**P1 — The motivation runs backwards.** v1 spends ~6 minutes on Aristotle → Russell's paradox →
Hilbert → Gödel → Coquand *before* the audience has any reason to care, then asserts "your
compiler is a descendant of that project." A practitioner audience experiences this as a tax to
be paid before the talk starts. The fix is not to cut history for time — it is that the history
was doing the wrong job. What the audience needs first is *what logic is for* and *the fact that
they already write it*.

**P2 — All formalism is front-loaded, far from the code it explains.** Gentzen's ∨-rules appear
at minute 9; the compile error they explain appears at minute 17. MLTT's Π/Σ rules appear at
minute 10; the Idris code that runs them appears at minute 36. Each rule is separated from its
own punchline by a quarter of an hour.

**P3 — The budget is fiction.** 38 main slides + 7 live IDE hand-offs in 45 minutes is ~1
min/slide with zero slack. Several slides (Stage 3, Stage 5) carry 4–6 minutes of content each.

**P4 — The incidents show their code too early.** Four code panes in the first five minutes,
before the audience has any framework to read them with. The code then has to be re-shown later
anyway, at the stage where it gets killed.

### The governing principle for v2

> **Front-load only the *shape* of logic. Distribute the *formalism* to the moment it pays off.**

A short primer establishes what logic does and that the audience already writes it. Then every
formal rule appears immediately adjacent to the code that makes it click: Gentzen's ∨E sixty
seconds before the exhaustive-switch compile error; Π/Σ next to the Idris functions that are
literally those rules. The buggy code from each incident appears at the stage where it stops
compiling — not in the cold open.

This recovers ~4 minutes *and* makes the theory more memorable, not less.

---

## Part 1 — Settled constraints

| | |
|---|---|
| Audience | Same Java meetup — working Java devs, mixed seniority, little FP/type-theory background |
| Runtime | 45 min hard; up to 3 min borrowable from Q&A. **Plan to 43:00** so slack is real |
| Demos | 3–4 live IDE segments, each with a fallback on its own slide |
| Code | **Talk-only rework.** Existing 7-stage ladder (`00-` … `06-`) unchanged |
| Toolchain | typst 0.15.1, touying pkg 0.7.4, cetz 0.5.2, touying CLI 0.14.4 (all verified) |

**Must land** (from the brief): sum-of-products as the core tactic · typestate · generics ·
type-level expressions and pattern matching · Java → Scala 3 → Idris 2 · brief integrated
touches on `Either`, effect systems, capture checking/capabilities · Curry-Howard(-Lambek) as
the central theoretical fascination · pragmatic payoff as the focus.

---

## Part 2 — The deck: 29 main slides, 43:00

Legend: **NEW** · **KEEP** (reuse v1 slide as-is or near) · **REWORK** · **MERGE** · **→A** (demoted to appendix)

### Act 0 — Open · 3:00

| # | Slide | Time | Origin |
|---|---|---|---|
| 1 | Title | 0:30 | KEEP `01-title` — new date, new subtitle |
| 2 | Four incidents, **no code** | 1:45 | **NEW** — replaces `02`–`05` (4 slides → 1) |
| 3 | The turn: "you already write logic" | 0:45 | **NEW** — replaces `06-pattern` |

**S2** — one slide, four rows: name · system · one-sentence failure · cost. Alice (`"4500"+"1500"`
= €450,015 instead of €60). Bob (third risk tier added, `if (risk != HIGH)` still compiled, 3DS
skipped). Charlie (a "force execute" shortcut ran a refund that was never reviewed). Danielle
(client and server each correct, contracts drifted, large uploads hang for three weeks).
No code panes. The four chips are introduced here and turn `CLOSED ✓` across the rest of the deck.
Closing line: *"Four bugs. None of them is stupidity. All four compiled."*

**S3** — the pivot, in your words: *"None of these is a testing failure — in each one the language
let someone write down something the business had already declared illegal. Logic happens to be a
long-standing interest of mine, so here's my claim for the next forty-five minutes: everyone in
this room already writes logic and proofs for a living. You just don't call it that. Types are how
you get to do logic **about** your programs."*

### Act 1 — The logic primer · 7:00 — **the main new content**

| # | Slide | Time | Origin |
|---|---|---|---|
| 4 | What logic is for — the syllogism | 1:15 | **NEW** (absorbs `07-toolkit` as a 10-sec strip) |
| 5 | Notation 1 — propositional | 1:30 | **NEW** |
| 6 | Notation 2 — predicate | 1:30 | **NEW** |
| 7 | Notation 3 — briefly uncovered | 1:15 | **NEW** (absorbs `14-lambda-cube` content) |
| 8 | Curry-Howard(-Lambek) | 1:30 | REWORK `curry-howard` |

**S4** — Aristotle's move: validity is a property of *form*, not content. Two columns, the
right one being the left one with the content removed:

```
All medium-risk orders need 3DS.      All M are T
This order is medium-risk.            x is M
────────────────────────────          ────────
So this order needs 3DS.              x is T
```

*"Strip out the content and the argument still stands or falls. That's the whole idea, and it's
2,400 years old. And notice: if the form is valid, it holds for **every** M, T and x. Hold that
thought."* Bottom strip, tiny, no dwell — Aristotle · Leibniz · Boole · Frege · Gentzen ·
Curry-Howard · Martin-Löf, one line total: *"2,400 years, a handful of people, one idea: make the
form checkable."* **This ten-second strip replaces v1's entire six-minute history section.**

**S5 — propositional logic.** Left, the formalism; right, the Java they already write.

```
medium → threeDS               sealed interface Risk
risk = low ∨ medium ∨ high         permits Low, Medium, High {}      ← the ∨
¬(captured ∧ ¬authorized)      record Order(OrderId id, Money total) ← the ∧
```

Punchline: *"`∨` is a sealed interface — exactly one variant. `∧` is a record — all fields at
once. Sums of products. That combination carries most domain modelling you will ever do, and it
shipped in Java 17."* **This is where sum-of-products is planted**; it is paid off at S12–S14 and
recalled in the climb.

**S6 — predicate logic.** Propositions with holes; quantifiers range over values.

```
∀o. medium(o) → needs3DS(o)    <T> Validator<T> nonEmpty()       ← ∀T
∃p. proof3DS(p) ∧ covers(p,o)  Optional<Proof> find3DS(Order o)  ← ∃
```

Punchline: *"When you wrote your first `<T>`, you wrote a universally quantified statement and
proved it once for all T. That is not an analogy. It is the same statement."*

**S7 — briefly uncovered.** Four one-liners, deliberately *not* explained in depth — the
"uncover one or two further down" from the brief:

```
(o : Order) → Assessment (riskOf o)   Π    the result TYPE depends on the VALUE
(lvl ** Assessment lvl)               Σ    a value bundled with a proof about itself
(1 ch : Session p) → …                QTT  this resource must be used exactly once
Send[Order, Recv[Auth, End]]          session type — a whole conversation, as a type
```

Explicit contract with the room: *"You will not walk out of here fluent in this syntax. That is
fine — it isn't the point. You'll walk out knowing what each of these **buys** you, and you'll
have watched all four of them run on a payment flow."* Right column carries the lambda-cube
*content* as a compact four-row map that doubles as the roadmap for the rest of the talk —
`f(x)` ordinary code · `f[A]` generics · `F[A]` type-level computation · `B(a)` dependent types.
The cube *drawing* goes to the appendix.

**S8 — Curry-Howard(-Lambek), the fulcrum.** Reuse the existing slide, which is already strong.
Add Lambek's third leg as one line — *"…and cartesian closed categories. Logic, computation and
algebra turn out to be three descriptions of one structure. That is, to me, the most beautiful
fact in computer science."* Then land it operationally:

> *"So a program that compiles **is** a proof. The only question is: a proof of what proposition?
> `String` proves almost nothing. `Payment<Authorized>` proves the payment was authorized before
> anyone captured it. **The whole rest of this talk is one question: how strong a proposition can
> I get my compiler to check, and what does it cost me?**"*

Gödel gets one line at the bottom, not a slide: *"You can't have everything — Gödel, 1931. What
you can have is: it never proves something false. Every type checker takes that deal."*

### Act 2 — The domain · 1:15

| # | Slide | Time | Origin |
|---|---|---|---|
| 9 | One scenario, nine invariants | 1:15 | KEEP `15-test-spine` |

Stage 0 (JavaScript) loses its own slide and becomes this slide's footer: *"In the JavaScript
version, every one of these nine is a test somebody has to remember to write."*

### Act 3 — The Java ladder · 14:00 — *the payoff section for this audience*

| # | Slide | Time | Origin |
|---|---|---|---|
| 10 | Stages 1+2 — nominal types & generics | 1:45 | MERGE `17-stage1` + `18-stage2` |
| 11 | Gentzen: how a connective is defined | 1:15 | KEEP `10-gentzen-or`, **moved here** |
| 12 | Stage 3 — records + sealed = sums of products | 2:00 | REWORK `19-stage3` (**fix overflow**) |
| 13 | → **LIVE DEMO 1** | 2:15 | delete `case Medium` → ∨E |
| 14 | Stage 3 payoff — Bob closed | 0:45 | KEEP `20-stage3-payoff` |
| 15 | Stage 4 — phantom typestate | 2:00 | REWORK `22-stage4` |
| 16 | → **LIVE DEMO 2** | 2:00 | uncomment `capture(init)` |
| 17 | Stage 4 payoff + **the Java ceiling** | 1:30 | MERGE `23-stage4-payoff` + `24-java-ceiling` |

**S11 is the structural fix for P2.** Gentzen's ∨I₁/∨I₂/∨E now sit sixty seconds before the
compile error they explain, instead of eight minutes before it.

**S12** is where Bob's actual buggy code appears for the first time — then the sealed version
beside it. `Result<T>` lands here as the second application of the same rule: *"same rule applied
to error handling — no `.get()` escape hatch. Scala spells it `Either`, Rust spells it `Result`."*
The current slide has a real rendering bug (the `RiskDecision.java` pane wraps comments outside
the box and clips at the bottom); fixed as part of the rework.

**S15** is where Charlie's actual buggy code appears, then dies.

### Act 4 — Scala 3 · 9:00

| # | Slide | Time | Origin |
|---|---|---|---|
| 18 | Stage 5 — what opens up | 1:30 | REWORK `25-stage5` |
| 19 | → **LIVE DEMO 3** | 2:15 | `AutoApproved` → error at `ch.send` |
| 20 | Session types + duality | 2:00 | REWORK `26-session-types` |
| 21 | Mechanisms + **effects / capture checking** | 1:45 | REWORK `stage5-mechanisms` + promote `a01` |
| 22 | Stage 5 payoff + Scala ceiling | 1:30 | MERGE `27-stage5-payoff` + `scala3-ceiling` |

**S20 is where "type-level expressions and pattern matching" lands explicitly** — `Dual[P] = P
match { case Send[a,n] => Receive[a, Dual[n]] … }`: pattern matching and recursion, at the type
level, run by the compiler over types. This is also Danielle's close.

**S21** carries the brief's requested aside, ~40 seconds: *"`ZIO[Database, DbError, User]` puts
'this needs a database' in the type. Scala 3's experimental capture checking does the same thing
without the monad — `User^{db}`. Same idea one level up: not which *values* you have, but which
*capabilities* they carry."* Content promoted from appendix A1, which stays for Q&A depth.

### Act 5 — Idris 2 · 5:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 23 | Stage 6 + **MLTT running** | 2:00 | MERGE `28-stage6-bridge` + `29-mltt-running` |
| 24 | → **LIVE DEMO 4** | 2:30 | drop `finish done` → linearity error |
| 25 | "Unrepresentable" | 1:00 | KEEP `30-stage6-payoff` (dark slide, emotional peak) |

**S23 is the payoff for the primer.** The Π and Σ notation shown at minute 8 is now on screen
running: `protocolFromSnapshot : RiskSnapshot -> SessionType` is Π-elimination; `assessOrder :
Order n c -> (lvl ** Assessment lvl n c)` is Σ-introduction. Callback line: *"That's the notation
I showed you in the primer and promised you'd see run. There it is."*

### Act 6 — Close · 4:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 26 | The climb | 1:15 | KEEP `31-the-climb` |
| 27 | Why now: agentic development | 1:15 | KEEP `32-agentic` |
| 28 | What to do on Monday | 1:00 | MERGE `where-to-start` + `33-horizon` (3 lines) |
| 29 | Close | 1:00 | KEEP `34-close` (+ zero-runtime-cost footnote) |

### Budget

| Act | Time |
|---|---|
| 0 — Open | 3:00 |
| 1 — Logic primer | 7:00 |
| 2 — Domain | 1:15 |
| 3 — Java ladder | 14:00 |
| 4 — Scala 3 | 9:00 |
| 5 — Idris 2 | 5:30 |
| 6 — Close | 4:30 |
| **Total** | **44:15** |

Against a 45:00 hard stop with 3:00 borrowable. Slack is thin; see the cut list below.

---

## Part 3 — What moves to the appendix

Nothing is deleted; six things stop being spoken by default.

| Was | v1 cost | Now |
|---|---|---|
| `07-toolkit` — 2,500 years of logic | 1:30 | 10-sec strip on S4; full slide → A4 |
| `08-crisis` — Russell / Hilbert / Gödel | 1:30 | one line on S8; full slide → A5 |
| `09/11/13-convergence` — five history beats | 1:45 | strip on S4; full slide → A6 |
| `12-mltt` — Π/Σ formation rules standalone | 0:25 | redundant with S23, which shows them running → A7 |
| `14-lambda-cube` — the cube drawing | 1:00 | content → S7 four-row map; drawing → A8 |
| `21-bridge` — records → typestate | 1:30 | two sentences of speech between S14 and S15 |
| `16-stage0` — JavaScript baseline | 0:45 | footer line on S9 |

Recovered: **≈8:25** — which is what pays for the 7:00 primer plus real slack.

Appendix after the rework (A1 effects/capture · A2 linearity across languages · A3 Idris live
mismatch · A4–A8 the demoted theory · A9 reading list · A10 match types · A11 singletons) is a
genuine Q&A arsenal rather than dead weight.

---

## Part 4 — Live demos and their fallbacks

Four segments, in descending order of value:

| # | Where | Edit | Expected error |
|---|---|---|---|
| 1 | Stage 3, `Demo.java` | delete `case RiskDecision.Medium m -> …` | *"the switch expression does not cover all possible input values"* |
| 2 | Stage 4, `Demo.java` | uncomment `Payment.capture(init);` | *"Payment&lt;Initiated&gt; cannot be converted to Payment&lt;Authorized&gt;"* |
| 3 | Stage 5, `PaymentDemo.scala` | `ThreeDSApproved(proof)` → `AutoApproved` | *"Found: AuthorizedPayment[LowRisk], Required: AuthorizedPayment[MediumRisk]"* |
| 4 | Stage 6, `Main.idr` | comment out a `finish done` | *"There are 0 uses of linear name done"* |

**Proposed fallback mechanism** — better than a screenshot: I apply each edit, run the real
compiler (`javac`, `sbt`, `idris2`) headlessly, capture the actual output to a text file under
`demos/`, and render it on the slide in a terminal-styled pane that is *hidden until needed*.
Advantages: it is genuinely the compiler's output rather than a mock-up; it is reproducible; it
can be regenerated if the code changes; and I can produce all four without your IDE. The only
thing it cannot capture is IntelliJ's specific inline wording — if you want that, four
screenshots from your machine will do it, and I'll slot them in.

**Cut order if running behind** (apply in this order, never cut Demo 1 or Demo 4):

1. Demo 3 → narrate over the static pane (saves 1:30)
2. S21 mechanisms → name three of six, skip the effects aside (saves 1:00)
3. S27 agentic → fold into the close as two sentences (saves 1:00)
4. Demo 2 → narrate over the static pane (saves 1:15)

---

## Part 5 — Where each required topic lands

| Required | Slide(s) |
|---|---|
| **Sum-of-products as core tactic** | planted S5, paid off S11–S14, recalled S26 |
| Typestate | S15, S16 |
| Generics | S6 (as ∀), S10 |
| Type-level expressions & pattern matching | S20 (`Dual[P]` match type), A10 |
| `Either` / `Result` | S12, alongside the same ∨E rule |
| Effect systems, capture checking, capabilities | S21 (~40 sec), depth in A1 |
| Curry-Howard(-Lambek) | S8, the fulcrum |
| Logic ↔ type theory ↔ mathematics | S4–S8 |
| Java → Scala 3 → Idris 2 | Acts 3, 4, 5 |
| Pragmatic focus | 28:30 of 44:15 is the code ladder |

---

## Part 6 — Execution order (once the plan is agreed)

1. Fix the Stage 3 code-pane overflow (independent of plan approval — it's a straight bug)
2. New slides S2, S3, S4, S5, S6, S7 (the open + primer) — the bulk of new authoring
3. Rework S8 Curry-Howard, move S11 Gentzen into Act 3
4. Merges: S10, S17, S22, S23, S28
5. Re-order `deck.typ`; move demoted slides into the appendix block
6. Capture the four compiler-output fallbacks under `demos/`
7. Rewrite speaker notes for every changed slide; rebuild `talk.pdfpc`
8. Full read-through against a stopwatch; correct the budget with real numbers

---

## Open questions

1. **Date and venue for the new delivery** — needed for S1 and the deck metadata.
2. **Title.** v1 is *"Type-Driven Programming — Correctness by Construction from the Basics to
   the Cutting Edge."* The primer-first structure suggests something closer to the actual claim,
   e.g. *"You're Already Writing Proofs"* with the existing title as subtitle. Your call.
3. **Fallbacks** — real captured compiler output (I can do it), or IntelliJ screenshots from your
   machine (you'd need to take four)?
4. **7:00 for the primer** — this is the single biggest bet in the plan. It is 16% of the talk
   spent before any payment code appears. I think it earns its place because it re-frames
   everything after it, but it is the first thing to challenge.
