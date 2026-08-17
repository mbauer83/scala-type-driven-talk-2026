# Talk v2 — Rework Plan (DRAFT 2)

Branch `talk-v2-rework`, off `talk-v1` (`93c8d95`).
**Delivery: Thursday 20 August 2026 — Java Meetup, Inspired Consulting GmbH, Köln.**
45 min + 15 min Q&A (up to 3 min borrowable).

Inputs treated as *proposals, not decisions*: `PRESENTATION_SLIDE_PLAN.md` (drifted from the
deck; retire after v2 ships), `REFACTOR_STAGE4_REMOVAL.md` and `DOMAIN_REWORK.md` (both verified
unexecuted — 0/19 checklist boxes; none of their identifiers exist in code or slides).

---

## Part 0 — What's wrong with v1

Not the visual design; that is good and stays. Five structural problems:

**P1 — The motivation runs backwards.** ~6 minutes of Aristotle → Russell's paradox → Hilbert →
Gödel → Coquand *before* the audience has a reason to care, then the assertion "your compiler is
a descendant of that project." A practitioner audience experiences this as a tax paid before the
talk starts. The history wasn't too long — it was doing the wrong job.

**P2 — All formalism is front-loaded, far from the code it explains.** Gentzen's ∨-rules land at
minute 9; the compile error they explain lands at minute 17. MLTT's Π/Σ rules land at minute 10;
the Idris code that *is* those rules lands at minute 36. Every rule is separated from its own
punchline by a quarter of an hour.

**P3 — The budget is fiction.** 38 main slides + 7 live IDE hand-offs in 45 minutes, with
several slides carrying 4–6 minutes each.

**P4 — The incidents show their code too early.** Four code panes in the first five minutes,
before the audience has a framework to read them with — then the same code is re-shown later at
the stage where it dies.

**P5 — The progress trackers don't transport information.** Two parallel scoreboards do the same
job badly. The nine-row test list is checklist-ese nobody reads ("Shape confusion — passing an
Order where an Authorization belongs"), its `CLOSES S·5` column spoils the answer before the
suspense exists, strikethrough on table rows reads weakly at projection distance, and it appears
five times at ~15 seconds each. The four-chip story strip duplicates the same tracking as a
status dashboard. Together they cost well over a minute and land as bookkeeping.

### The governing principle for v2

> **Front-load only the *shape* of logic. Distribute the *formalism* to the moment it pays off.**

A short primer establishes what logic does and that the audience already writes it. Then every
formal rule appears adjacent to the code that makes it click: Gentzen's ∨E sixty seconds before
the exhaustive-switch compile error; Π/Σ next to the Idris functions that are literally those
rules. Each incident's buggy code appears at the stage where it stops compiling — not up front.

---

## Part 1 — Settled constraints

| | |
|---|---|
| Occasion | Java Meetup, Inspired Consulting GmbH, Köln — **Thu 20 Aug 2026** |
| Audience | Working Java devs, mixed seniority, little FP/type-theory background |
| Runtime | 45 min hard; up to 3 min borrowable. **Plan to ~44:00** |
| Title | Unchanged: *Type-Driven Programming — Correctness by Construction from the Basics to the Cutting Edge* |
| Demos | 4 live IDE segments; fallback = **real captured compiler output**, rendered as a terminal pane, hidden until needed |
| Code | **Talk-only rework.** Existing 7-stage ladder (`00-` … `06-`) unchanged |
| Toolchain | typst 0.15.1, touying pkg 0.7.4, cetz 0.5.2, touying CLI 0.14.4 — all verified |

**Must land:** sum-of-products as the core tactic · typestate · generics · type-level expressions
and pattern matching · Java → Scala 3 → Idris 2 · brief integrated touches on `Either`, effect
systems, capture checking/capabilities · **the types/values/references and memory model, lightly
sketched** · Curry-Howard(-Lambek) as the central fascination · **an honest cost answer** ·
pragmatic payoff as the focus.

---

## Part 2 — Progress tracking, rebuilt (replaces P5)

The nine-row test list leaves the main deck (→ appendix, as the complete invariant inventory for
anyone who wants it). Two lightweight devices replace it, on two genuinely different axes.

### Device 1 — the human axis: one payoff statement per stage

Each stage payoff stops being a table and becomes a single declarative claim plus the line of
code that is now unwriteable. Example, Stage 3:

> ### Bob's bug is now a compile error.
> ```java
> if (risk != HIGH) { return fastPath(order); }   // ← there is no longer an `if` to get wrong
> ```
> The switch will not compile without `case Medium`. Not "we added a test" — the shape is gone.

Four names, four such moments. The collective view happens **once**, at the end, on the existing
dark *"Unrepresentable"* slide — which already works and is the emotional peak. No persistent
dashboard, no strikethrough tables.

### Device 2 — the technical axis: the lambda cube, progressively disclosed

The cube is **not** front-loaded. It appears three times, at the *threshold* moments, gaining
lit edges each time — so it functions as a navigation aid that earns its detail as the audience
acquires it:

| Appearance | Where | What is lit |
|---|---|---|
| Glimpse | S7, primer — one line, no explanation | nothing lit; "there is a map of this territory; we'll fill it in as we go" |
| Reveal 1 | S17, the Java ceiling | `f(x)` → `f[A]` edge lit — Java's reach; the two unlit axes named |
| Reveal 2 | S22, the Scala ceiling | `F[A]` edge lit — type-level computation; one axis still dark |
| Reveal 3 | S25, after Idris | `B(a)` edge lit — the cube is complete |

**Implementation:** refactor `diagrams/lambda-cube.typ` from a fixed canvas value into
`lambda-cube-canvas(reveal: 0)`, where `reveal` selects which path edges are drawn in the
highlight colour and which stage tags are shown. Straightforward parameterisation of the
existing drawing; no new geometry.

---

## Part 3 — The deck: 30 main slides, ~44:00

Legend: **NEW** · **KEEP** · **REWORK** · **MERGE** · **→A** (demoted to appendix)

### Act 0 — Open · 3:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 1 | Title | 0:30 | KEEP `01-title` — new date + venue |
| 2 | Four incidents, **no code** | 2:15 | **NEW** — replaces `02`–`05` (4 slides → 1) |
| 3 | The turn: "you already write logic" | 0:45 | **NEW** — replaces `06-pattern` |

**S2** — four rows: name · system · what happened · what it cost. Each keeps **one concrete human
detail** (the Slack message from accounting; the third risk tier added months later; the three
hours of log archaeology; the three weeks it ran fine before anyone tried a large upload). No
code panes. Closing line: *"Four bugs. None of them is stupidity. All four compiled."*

**S3** — the pivot: *"None of these is a testing failure — in each one the language let someone
write down something the business had already declared illegal. Logic happens to be a
long-standing interest of mine, so here's my claim for the next forty-five minutes: everyone in
this room already writes logic and proofs for a living. You just don't call it that. Types are
how you get to do logic **about** your programs."*

### Act 1 — The logic primer · 7:00 — *the main new content*

| # | Slide | Time | Origin |
|---|---|---|---|
| 4 | What logic is for — the syllogism | 1:15 | **NEW** (absorbs `07-toolkit` as a 10-sec strip) |
| 5 | Notation 1 — propositional | 1:30 | **NEW** |
| 6 | Notation 2 — predicate | 1:30 | **NEW** |
| 7 | Notation 3 — briefly uncovered | 1:15 | **NEW** |
| 8 | Curry-Howard(-Lambek) | 1:30 | REWORK `curry-howard` |

**S4** — validity is a property of *form*, not content. Two columns; the right one is the left
one with the content removed:

```
All medium-risk orders need 3DS.      All M are T
This order is medium-risk.            x is M
────────────────────────────          ────────
So this order needs 3DS.              x is T
```

*"Strip out the content and the argument still stands or falls. That's the whole idea, and it's
2,400 years old. And if the form is valid, it holds for **every** M, T and x — hold that
thought."* Bottom strip, tiny, ~10 seconds: Aristotle · Leibniz · Boole · Frege · Gentzen ·
Curry-Howard · Martin-Löf — *"one idea, refined for 2,400 years: make the form checkable."*
**This strip replaces v1's entire six-minute history section.**

**S5 — propositional logic.** Formalism left, the Java they already write right. *Snippets must
be lifted verbatim from `03-java-function-types-sealed/`, not invented* — the audience sees this
same code fifteen minutes later and any seam is noticeable.

```
risk = Low ∨ Medium ∨ High     sealed interface RiskDecision
                                   permits Low, Medium, High {}   ← the ∨
medium → threeDS               record Low() implements RiskDecision {}
¬(captured ∧ ¬authorized)      record Order(String orderId, …)    ← the ∧
```

Punchline: *"`∨` is a sealed interface — exactly one variant. `∧` is a record — all fields at
once. **Sums of products.** That combination carries most domain modelling you will ever do, and
it shipped in Java 17."* This is where sum-of-products is planted; paid off at S12–S14.

**S6 — predicate logic.** Propositions with holes; quantifiers range over values.

```
∀o. medium(o) → needs3DS(o)    static <T> Validator<T> check(…)   ← ∀T
∃p. proof3DS(p) ∧ covers(p,o)  Optional<Proof> find3DS(Order o)   ← ∃
```

Punchline: *"When you wrote your first `<T>`, you wrote a universally quantified statement and
proved it once, for all T. That is not an analogy. It is the same statement."*

**S7 — briefly uncovered.** One job only (the lambda-cube map is cut from this slide per
Part 2). Four one-liners, deliberately *not* explained in depth:

```
(o : Order) → Assessment (riskOf o)   Π    the result TYPE depends on the VALUE
(lvl ** Assessment lvl)               Σ    a value bundled with a proof about itself
(1 ch : Session p) → …                QTT  this resource must be used exactly once
Send[Order, Recv[Auth, End]]          session type — a whole conversation, as a type
```

Contract with the room: *"You will not walk out of here fluent in this syntax. That's fine — it
isn't the point. You'll walk out knowing what each of these **buys** you, and you'll have watched
all four run on a payment flow."* Plus the one-line cube glimpse (Part 2, Device 2).

**S8 — Curry-Howard(-Lambek), the fulcrum.** Reuse the existing slide. Add Lambek's third leg as
one line — *"…and cartesian closed categories. Logic, computation and algebra turn out to be
three descriptions of one structure. That is, to me, the most beautiful fact in computer
science."* Then land it operationally:

> *"So a program that compiles **is** a proof. The only question is: a proof of what proposition?
> `String` proves almost nothing. `Payment<Authorized>` proves the payment was authorized before
> anyone captured it. **The rest of this talk is one question: how strong a proposition can I get
> my compiler to check, and what does it cost me?**"*

Gödel gets one line, not a slide: *"You can't have everything — Gödel, 1931. What you can have
is: it never proves something false. Every type checker takes that deal."*

### Act 2 — Ground floor · 1:45

| # | Slide | Time | Origin |
|---|---|---|---|
| 9 | One scenario | 0:45 | REWORK `15-test-spine` — flow diagram only, nine-row list → appendix |
| 10 | **Types, values, references** | 1:00 | **NEW** |

**S10 is the new grounding slide** requested in review — the hinge between logic and code, kept
deliberately light:

- A *value* is a bit pattern plus an agreement about how to read it. A *reference* is a value
  that denotes a location. In Java: primitives are values, everything else is a reference —
  which is why `==` compares the reference and `.equals` compares the value, and why `record`
  exists to give you value semantics over a reference.
- **The load-bearing point:** the *type* is not there at runtime at all. It is the compiler's
  reasoning about which values are allowed to flow where. `Payment<Initiated>` and
  `Payment<Authorized>` are the same bytes.
- Which is exactly why the rest of the talk is affordable: phantom type parameters carry no
  data, Scala's opaque types are plain `String`s at runtime, Idris's multiplicities are erased.
  **You pay in compile-time expressiveness, not in runtime cost.**
- And the honest flip side: what you erase, you cannot ask about later —
  `x instanceof List<String>` doesn't compile for a reason.

This slide pre-empts the "sounds expensive" reflex before it forms, and sets up the cost slide.

### Act 3 — The Java ladder · 13:40 — *the payoff section for this audience*

| # | Slide | Time | Origin |
|---|---|---|---|
| 11 | Stages 1+2 — nominal types & generics | 1:30 | MERGE `17-stage1` + `18-stage2` |
| 12 | Gentzen: how a connective is defined | 1:15 | KEEP `10-gentzen-or`, **moved here** |
| 13 | Stage 3 — records + sealed = sums of products | 2:00 | REWORK `19-stage3` (**fix overflow bug**) |
| 14 | → **LIVE DEMO 1** | 2:45 | delete `case Medium` → ∨E |
| 15 | Payoff — *Bob's bug is now a compile error* | 0:40 | REWORK `20-stage3-payoff` (Device 1) |
| 16 | Stage 4 — phantom typestate | 2:00 | REWORK `22-stage4` |
| 17 | → **LIVE DEMO 2** | 2:00 | uncomment `capture(init)` |
| 18 | Payoff + **Java ceiling** + cube reveal 1 | 1:30 | MERGE `23-stage4-payoff` + `24-java-ceiling` |

**S12 is the structural fix for P2** — Gentzen's ∨I₁/∨I₂/∨E now sit sixty seconds before the
compile error they explain instead of eight minutes before it.

**S13** is where Bob's actual buggy code first appears, beside the sealed version. `Result<T>`
lands here as the same rule applied again: *"no `.get()` escape hatch. Scala spells it `Either`,
Rust spells it `Result`."* The current slide has a real rendering bug — the `RiskDecision.java`
pane wraps comments outside the box and clips at the bottom — fixed as part of this.

**S16** is where Charlie's actual buggy code appears, then dies. Stage 0 (JavaScript) and the
`21-bridge` slide are both gone; each becomes one spoken sentence.

### Act 4 — Scala 3 · 8:45

| # | Slide | Time | Origin |
|---|---|---|---|
| 19 | Stage 5 — what opens up | 1:30 | REWORK `25-stage5` |
| 20 | → **LIVE DEMO 3** | 2:15 | `AutoApproved` → error at `ch.send` |
| 21 | Session types + duality | 1:45 | REWORK `26-session-types` |
| 22 | Mechanisms + **effects / capture checking** | 1:45 | REWORK `stage5-mechanisms` + promote `a01` |
| 23 | Payoff + Scala ceiling + cube reveal 2 | 1:30 | MERGE `27-stage5-payoff` + `scala3-ceiling` |

**S21 is where type-level expressions and pattern matching land explicitly** — `Dual[P] = P match
{ case Send[a,n] => Receive[a, Dual[n]] … }`: pattern matching and recursion, at the type level,
run by the compiler over types. Also Danielle's close.

**S22** carries the effects aside, ~40 seconds: *"`ZIO[Database, DbError, User]` puts 'this needs
a database' in the type. Scala 3's experimental capture checking does the same without the monad
— `User^{db}`. Same idea one level up: not which values you hold, but which capabilities they
carry."* Depth stays in appendix A1.

### Act 5 — Idris 2 · 5:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 24 | Stage 6 + **MLTT running** | 2:00 | MERGE `28-stage6-bridge` + `29-mltt-running` |
| 25 | → **LIVE DEMO 4** | 2:30 | drop `finish done` → linearity error |
| 26 | *Unrepresentable* + cube reveal 3 | 1:00 | KEEP `30-stage6-payoff` (dark slide, emotional peak) |

**S24 is the payoff for the primer.** The Π and Σ notation from minute 8 is now on screen,
running: `protocolFromSnapshot : RiskSnapshot -> SessionType` *is* Π-elimination; `assessOrder :
Order n c -> (lvl ** Assessment lvl n c)` *is* Σ-introduction. Callback: *"That's the notation I
showed you in the primer and promised you'd see run. There it is."*

### Act 6 — Close · 5:00

| # | Slide | Time | Origin |
|---|---|---|---|
| 27 | The climb | 0:45 | KEEP `31-the-climb`, tightened |
| 28 | **What it costs — and why the calculus is shifting** | 1:30 | **NEW** + MERGE `32-agentic` |
| 29 | What to do on Monday | 1:00 | MERGE `where-to-start` + `33-horizon` (3 lines) |
| 30 | Close | 1:00 | KEEP `34-close` |

**S28 is the new cost slide**, merged with the agentic-development argument because they are the
same conversation — the price, and why the price is worth paying now:

- *Sealed types + records:* zero cost. Java 17, no dependency, one afternoon. Do this regardless.
- *Phantom typestate:* one interface and a private constructor. Costs a code-review conversation
  and some generic noise in signatures. Worth it on lifecycle-bearing aggregates, not everywhere.
- *Scala 3:* a real team decision — build tooling, compile times measured in seconds not
  milliseconds, hiring, and a genuine learning curve. Justified when the domain has invariants
  expensive enough to be worth encoding. Not a default.
- *Idris 2:* not a production proposal. It is here because it shows where the ceiling actually
  is, and because the ideas leak downward into languages you do ship.
- Then the shift: *code is now generated faster than it can be reviewed. An expressive type
  system raises the floor of correctness that holds regardless of who — or what — wrote the code.
  And the compiler's type error is precise enough to be a specification an agent can act on.*
- Landing line: *"The question was never 'should I use dependent types for my CRUD endpoints.'
  It's: is this invariant expensive enough to encode? The tools keep getting cheaper, so that
  set keeps getting bigger."*

### Budget

| Act | Time |
|---|---|
| 0 — Open | 3:30 |
| 1 — Logic primer | 7:00 |
| 2 — Ground floor | 1:45 |
| 3 — Java ladder | 13:40 |
| 4 — Scala 3 | 8:45 |
| 5 — Idris 2 | 5:30 |
| 6 — Close | 5:00 |
| **Total** | **45:10** |

Against 45:00 hard + 3:00 borrowable. **This is 10 seconds over and therefore not yet
trustworthy** — the honest number comes from the stopwatch read-through (execution step 8), not
from this table. The cut list below is the safety margin, and it is deep enough to reach 41:00.

**Cut order if running behind** — apply in this order; never cut Demo 1 or Demo 4:

1. Demo 3 → narrate over the static pane (−1:30)
2. S22 mechanisms → name three of six, drop the effects aside (−1:00)
3. S12 Gentzen → state the rule verbally over S13 (−1:00)
4. Demo 2 → narrate over the static pane (−1:15)

---

## Part 4 — What moves to the appendix

Nothing is deleted; eight things stop being spoken by default.

| Was | v1 cost | Now |
|---|---|---|
| `07-toolkit` — 2,500 years of logic | 1:30 | 10-sec strip on S4; slide → A4 |
| `08-crisis` — Russell / Hilbert / Gödel | 1:30 | one line on S8; slide → A5 |
| `09/11/13-convergence` — five history beats | 1:45 | strip on S4; slide → A6 |
| `12-mltt` — Π/Σ rules standalone | 0:25 | redundant with S24, which shows them running → A7 |
| `14-lambda-cube` — the cube as a slide | 1:00 | progressive reveals at S18/S23/S26; full slide → A8 |
| `15-test-spine` — the nine-invariant table | ~1:15 total | → A9, the complete inventory |
| `21-bridge` — records → typestate | 1:30 | two sentences between S15 and S16 |
| `16-stage0` — JavaScript baseline | 0:45 | one line on S9 |

Recovered: **≈9:40** — which pays for the 7:00 primer, the 1:00 grounding slide, the 1:30 cost
slide, and the longer cold open.

Appendix after the rework: A1 effects/capture · A2 linearity across languages · A3 Idris live
mismatch · A4–A8 the demoted theory · A9 the invariant inventory · A10 reading list · A11 match
types · A12 singletons. A genuine Q&A arsenal rather than dead weight.

---

## Part 5 — Live demos and their fallbacks

| # | Where | Edit | Expected error |
|---|---|---|---|
| 1 | Stage 3, `Demo.java` | delete `case RiskDecision.Medium m -> …` | *"the switch expression does not cover all possible input values"* |
| 2 | Stage 4, `Demo.java` | uncomment `Payment.capture(init);` | *"Payment&lt;Initiated&gt; cannot be converted to Payment&lt;Authorized&gt;"* |
| 3 | Stage 5, `PaymentDemo.scala` | `ThreeDSApproved(proof)` → `AutoApproved` | *"Found: AuthorizedPayment[LowRisk], Required: AuthorizedPayment[MediumRisk]"* |
| 4 | Stage 6, `Main.idr` | comment out a `finish done` | *"There are 0 uses of linear name done"* |

**Fallback mechanism (agreed):** apply each edit, run the real compiler (`javac`, `sbt`,
`idris2`) headlessly, capture actual output to `demos/*.txt`, and render it on the slide as a
terminal-styled pane hidden until needed. Genuinely the compiler's output, reproducible, and
regenerable if the code changes.

---

## Part 6 — Where each required topic lands

| Required | Slide(s) |
|---|---|
| **Sum-of-products as core tactic** | planted S5, paid off S12–S15, recalled S27 |
| Typestate | S16, S17 |
| Generics | S6 (as ∀), S11 |
| Type-level expressions & pattern matching | S21 (`Dual[P]` match type), A11 |
| `Either` / `Result` | S13, same ∨E rule applied again |
| Effect systems, capture checking, capabilities | S22 (~40 sec), depth in A1 |
| **Types / values / references / memory model** | **S10** |
| Curry-Howard(-Lambek) | S8, the fulcrum |
| Logic ↔ type theory ↔ mathematics | S4–S8 |
| **Cost, honestly** | **S28** |
| Java → Scala 3 → Idris 2 | Acts 3, 4, 5 |
| Pragmatic focus | 28:00 of 45:10 is the code ladder |

---

## Part 7 — Execution order

Three days. Ordered so that a stop at any point still leaves a deliverable deck.

1. **Bug fix + metadata** — Stage 3 code-pane overflow; title slide date/venue *(independent of everything)*
2. **Act 1 primer** — S4, S5, S6, S7 new; S8 reworked *(the core ask; biggest authoring block)*
3. **Act 0** — S2 incidents, S3 the turn
4. **S10** types/values/references
5. **Move Gentzen into Act 3**; rework S13 and its payoff to Device 1
6. **Parameterise the lambda cube** for progressive disclosure; wire reveals into S18, S23, S26
7. **Merges** — S11, S18, S23, S24, S28, S29
8. **Re-order `deck.typ`**; move demoted slides into the appendix block
9. **Capture the four compiler-output fallbacks** into `demos/`
10. **Speaker notes** rewritten for every changed slide; rebuild `talk.pdfpc`
11. **Stopwatch read-through**; replace the estimated budget with measured numbers

---

## Open questions

None blocking. Retire `PRESENTATION_SLIDE_PLAN.md` once v2 ships (agreed).
