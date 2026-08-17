# Talk v2 — Rework Plan (DRAFT 3)

Branch `talk-v2-rework`, off `talk-v1` (`93c8d95`).
**Delivery: Thursday 20 August 2026 — Java Meetup, Inspired Consulting GmbH, Köln.**
45 min + 15 min Q&A (up to 3 min borrowable).

Inputs treated as *proposals, not decisions*: `PRESENTATION_SLIDE_PLAN.md` (drifted from the
deck; retire after v2 ships), `REFACTOR_STAGE4_REMOVAL.md` and `DOMAIN_REWORK.md` (both verified
unexecuted — 0/19 checklist boxes; none of their identifiers exist in code or slides).

---

## Part 0 — What's wrong with v1

Not the visual design; that is good and stays. Five structural problems:

**P1 — Every idea is told twice.** v1 gives ~6 minutes of Aristotle → Russell → Hilbert → Gödel
→ Coquand as an abstract history block at minute 7, then re-teaches the same ideas concretely at
the stage where they pay off. The history isn't wrong and it isn't too long — it is *detached*
from the code that makes it land, so it has to be said again later. The fix is not to cut it
(draft 1 tried that and lost the philosophy → logic → mathematics → CS thread, which is the
reason the speaker cares). The fix is to **say each idea once, with its history as the frame**.

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

> **Braid the history into the primer. Distribute the *formalism* to the moment it pays off.**

Two moves, not one.

**The braid.** The primer and the history are the same content, so they become one section. Every
notation the audience learns arrives attached to the person who invented it and the problem they
invented it for — Aristotle and validity, Boole and Frege and the connectives, Russell and the
paradox that produced *types themselves*, Curry and Howard and the fulcrum, Martin-Löf and
Coquand and what lies above. The names stop being a list to get through and become the reason
each idea exists. This is what carries the philosophy → logic → mathematics → CS thread, and it
costs no more time than v1's detached history because it removes the second telling.

**The distribution.** Formal *rules* still move next to the code that makes them click: Gentzen's
∨E sixty seconds before the exhaustive-switch compile error; Π/Σ next to the Idris functions that
are literally those rules. Each incident's buggy code appears at the stage where it stops
compiling — not up front.

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
| Glimpse | S9, primer — one line, no explanation | nothing lit; "there is a map of this territory; we'll fill it in as we go" |
| Reveal 1 | S19, the Java ceiling | `f(x)` → `f[A]` edge lit — Java's reach; the two unlit axes named |
| Reveal 2 | S24, the Scala ceiling | `F[A]` edge lit — type-level computation; one axis still dark |
| Reveal 3 | S27, after Idris | `B(a)` edge lit — the cube is complete |

**Implementation:** refactor `diagrams/lambda-cube.typ` from a fixed canvas value into
`lambda-cube-canvas(reveal: 0)`, where `reveal` selects which path edges are drawn in the
highlight colour and which stage tags are shown. Straightforward parameterisation of the
existing drawing; no new geometry.

---

## Part 3 — The deck: 31 main slides, 44:25

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

**S3** — the pivot. Slide reads: *"A test catches the cases you thought of. A type
constrains every call site — whether you thought of it or not."*

**Do not claim tests could not have caught these.** They could: a fixture with two
order lines finds Alice's in a day. The claim that survives scrutiny is about the
*kind* of guarantee — a test is a case somebody has to think of, write down, and
keep correct at every place the rule applies, whereas an encoded rule is applied by
the compiler at every call site whether or not anyone remembered. Overclaiming here
also contradicts the Alice story itself, where a two-line fixture is what finds it.

Then the bridge into the framing sentence: *"The history of what we are doing when
we specify programs and types stretches back about two and a half thousand years,
across philosophy, logic, mathematics, and computer science."* MB's sentence,
lightly restructured; the original is preserved in the slide's note.

### Act 1 — Where this comes from, and why you already write it · 8:15 — *the main new content*

The braid. Each slide = one person, one problem they were solving, one notation, and the Java
the audience already writes in that notation.

| # | Slide | Who / what problem | Time | Origin |
|---|---|---|---|---|
| 4 | What makes an argument valid | **Aristotle**, 4th c. BCE | 1:15 | **NEW** (absorbs `07-toolkit`) |
| 5 | The connectives — `∨` and `∧` | **Boole** 1847 → **Frege** 1879 | 1:30 | **NEW** (absorbs `07-toolkit`) |
| 6 | The quantifiers — `∀` and `∃` | **Frege**'s Begriffsschrift | 1:15 | **NEW** |
| 7 | The crisis, and why it's called a *type* | **Russell** 1901, **Gödel** 1931 | 1:15 | **RESTORED** `08-crisis` |
| 8 | Proposition = Type. Proof = Program. | **Church/Turing** 1936, **Curry-Howard** 1969, **Lambek** | 1:45 | REWORK `curry-howard` + absorbs `09`/`11-convergence` |
| 9 | What lies above — briefly uncovered | **Martin-Löf** 1972, **Coquand** 1988 | 1:15 | **NEW** + absorbs `12-mltt`, `13-convergence3` |

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
thought."*

A thin progress rail runs along the bottom of every Act 1 slide — Aristotle · Boole · Frege ·
Russell · Church · Curry-Howard · Martin-Löf · Coquand — with the current beat lit. It gives the
2,400-year sweep continuously, for free, without ever being a slide of its own.

**S5 — the connectives.** Boole 1847 turns logic into algebra; Frege 1879 builds the first system
that can actually carry mathematics. Formalism left, the Java they already write right.
*Snippets must
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
it shipped in Java 17."* This is where sum-of-products is planted; paid off at S14–S16.

**S6 — the quantifiers.** Frege's real innovation: propositions with holes in them, and
quantifiers that range over values.

```
∀o. medium(o) → needs3DS(o)    static <T> Validator<T> check(…)   ← ∀T
∃p. proof3DS(p) ∧ covers(p,o)  Optional<Proof> find3DS(Order o)   ← ∃
```

Punchline: *"When you wrote your first `<T>`, you wrote a universally quantified statement and
proved it once, for all T. That is not an analogy. It is the same statement."*

**S7 — the crisis, and where the word "type" comes from.** Restored from v1's `08-crisis`, but
reframed from an academic aside into the origin story of the talk's own subject. This is the
philosophy → logic → mathematics → CS hinge, and it is ~40 seconds of genuine narrative:

> *"In 1901 Russell wrote Frege a letter and broke his life's work with one sentence: the set of
> all sets that don't contain themselves — does it contain itself? Either answer contradicts. And
> Russell's own fix was **types** — a strict hierarchy that makes the self-reference unsayable.
> That is where the word comes from. Every `sealed interface` you write is downstream of a man
> trying to stop mathematics from eating itself."*

Gödel gets one line, not a section: *"And then Gödel showed you can't have everything. What you
can have is that it never proves something false — and that is the deal every type checker takes."*
Hilbert's consistent / sound / complete triple is the one genuinely academic beat with low payoff
for this room; it compresses into that line, with the full slide staying in the appendix.

**S8 — Curry-Howard(-Lambek), the fulcrum.** Church and Turing 1936 as a one-line lead-in — *"the
typed lambda calculus is the direct ancestor of the `Function<String,Integer>` you write in Java
8"* — then the correspondence itself, plus Lambek's third leg: *"…and cartesian closed
categories. Logic, computation and algebra turn out to be three descriptions of one structure.
That is, to me, the most beautiful fact in computer science."* Then land it operationally:

> *"So a program that compiles **is** a proof. The only question is: a proof of what proposition?
> `String` proves almost nothing. `Payment<Authorized>` proves the payment was authorized before
> anyone captured it. **The rest of this talk is one question: how strong a proposition can I get
> my compiler to check, and what does it cost me?**"*

The Lambek claim is precise only for STLC ↔ intuitionistic propositional logic ↔ CCCs; the
speaker note must carry that caveat (see Part 3's accuracy items).

**S9 — what lies above, briefly uncovered.** Martin-Löf 1972 and Coquand 1988 — the kernel behind
Lean, Rocq, Agda and Idris. Four one-liners, deliberately *not* explained in depth:

```
(o : Order) → Assessment (riskOf o)   Π    the result TYPE depends on the VALUE
(lvl ** Assessment lvl)               Σ    a value bundled with a proof about itself
(1 ch : Session p) → …                QTT  this resource must be used exactly once
Send[Order, Recv[Auth, End]]          session type — a whole conversation, as a type
```

Contract with the room: *"You will not walk out of here fluent in this syntax. That's fine — it
isn't the point. You'll walk out knowing what each of these **buys** you, and you'll have watched
all four run on a payment flow."* Plus the one-line cube glimpse (Part 2, Device 2).

### Act 2 — Ground floor · 1:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 10 | One scenario | 0:30 | REWORK `15-test-spine` — flow diagram only, nine-row list → appendix |
| 11 | **Types, values, references** | 1:00 | **NEW** |

**S11 is the new grounding slide** requested in review — the hinge between logic and code, kept
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

**Two points that must land here, and must not be conflated** (raised in review):

1. **The value of types for this talk is mostly independent of erasure.** They are a
   *design-time and compile-time* tool. Most of the payoff arrives before the program
   runs — while modelling the domain, while the checker rejects a bad call, while a
   reader infers the contract from a signature. Whether the type survives to runtime
   is largely an implementation question. Do not let the argument rest on erasure.
2. **Dependent types are the deliberate exception, and the nuance must survive.**
   Stage 6 works precisely because a *runtime value* flows into a type:
   `protocolFromSnapshot snap` computes a `SessionType` from data only known at
   runtime. That is a different mechanism from the erased phantom parameters of
   Stages 4–5, and flattening the two into "types are erased anyway" destroys the
   Idris payoff before it arrives. State the general rule, then mark the exception
   explicitly when Stage 6 lands.

**Gradual typing** also belongs here, briefly (raised in review). It is the single
biggest usability story for both TypeScript and Scala, and the audience knows
TypeScript: you can add a type layer to an existing untyped codebase incrementally,
one module at a time, without a rewrite. That matters because it converts "adopt a
type system" from a migration into a series of small local decisions — which is
exactly the adoption question S29 answers. One or two sentences here, one callback
in the cost slide.

This slide pre-empts the "sounds expensive" reflex before it forms, and sets up the cost slide.

### Act 3 — The Java ladder · 13:10 — *the payoff section for this audience*

| # | Slide | Time | Origin |
|---|---|---|---|
| 12 | Stages 1+2 — nominal types & generics | 1:15 | MERGE `17-stage1` + `18-stage2` |
| 13 | Gentzen: how a connective is defined | 1:15 | KEEP `10-gentzen-or`, **moved here** |
| 14 | Stage 3 — records + sealed = sums of products | 2:00 | REWORK `19-stage3` (**fix overflow bug**) |
| 15 | → **LIVE DEMO 1** | 2:30 | delete `case Medium` → ∨E |
| 16 | Payoff — *Bob's bug is now a compile error* | 0:40 | REWORK `20-stage3-payoff` (Device 1) |
| 17 | Stage 4 — phantom typestate | 2:00 | REWORK `22-stage4` |
| 18 | → **LIVE DEMO 2** | 2:00 | uncomment `capture(init)` |
| 19 | Payoff + **Java ceiling** + cube reveal 1 | 1:30 | MERGE `23-stage4-payoff` + `24-java-ceiling` |

**S13 is the structural fix for P2** — Gentzen's ∨I₁/∨I₂/∨E now sit sixty seconds before the
compile error they explain instead of eight minutes before it.

**S14** is where Bob's actual buggy code first appears, beside the sealed version. `Result<T>`
lands here as the same rule applied again: *"no `.get()` escape hatch. Scala spells it `Either`,
Rust spells it `Result`."* The current slide has a real rendering bug — the `RiskDecision.java`
pane wraps comments outside the box and clips at the bottom — fixed as part of this.

**S17** is where Charlie's actual buggy code appears, then dies. Stage 0 (JavaScript) and the
`21-bridge` slide are both gone; each becomes one spoken sentence.

### Act 4 — Scala 3 · 8:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 20 | Stage 5 — what opens up | 1:30 | REWORK `25-stage5` |
| 21 | → **LIVE DEMO 3** | 2:15 | `AutoApproved` → error at `ch.send` |
| 22 | Session types + duality | 1:45 | REWORK `26-session-types` |
| 23 | Mechanisms + **effects / capture checking** | 1:30 | REWORK `stage5-mechanisms` + promote `a01` |
| 24 | Payoff + Scala ceiling + cube reveal 2 | 1:30 | MERGE `27-stage5-payoff` + `scala3-ceiling` |

**S22 is where type-level expressions and pattern matching land explicitly** — `Dual[P] = P match
{ case Send[a,n] => Receive[a, Dual[n]] … }`: pattern matching and recursion, at the type level,
run by the compiler over types. Also Danielle's close.

**S23** carries the effects aside, ~40 seconds: *"`ZIO[Database, DbError, User]` puts 'this needs
a database' in the type. Scala 3's experimental capture checking does the same without the monad
— `User^{db}`. Same idea one level up: not which values you hold, but which capabilities they
carry."* Depth stays in appendix A1.

### Act 5 — Idris 2 · 5:30

| # | Slide | Time | Origin |
|---|---|---|---|
| 25 | Stage 6 + **MLTT running** | 2:00 | MERGE `28-stage6-bridge` + `29-mltt-running` |
| 26 | → **LIVE DEMO 4** | 2:30 | drop `finish done` → linearity error |
| 27 | *Unrepresentable* + cube reveal 3 | 1:00 | KEEP `30-stage6-payoff` (dark slide, emotional peak) |

**S25 is the payoff for the primer.** The Π and Σ notation from minute 8 is now on screen,
running: `protocolFromSnapshot : RiskSnapshot -> SessionType` *is* Π-elimination; `assessOrder :
Order n c -> (lvl ** Assessment lvl n c)` *is* Σ-introduction. Callback: *"That's the notation I
showed you in the primer and promised you'd see run. There it is."*

### Act 6 — Close · 4:00

| # | Slide | Time | Origin |
|---|---|---|---|
| 28 | The climb | 0:30 | KEEP `31-the-climb`, tightened |
| 29 | **What it costs — and why the calculus is shifting** | 1:30 | **NEW** + MERGE `32-agentic` |
| 30 | What to do on Monday | 1:00 | MERGE `where-to-start` + `33-horizon` (3 lines) |
| 31 | Close | 1:00 | KEEP `34-close` |

**S29 is the new cost slide**, merged with the agentic-development argument because they are the
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
| 1 — History braided into the primer | 8:15 |
| 2 — Ground floor | 1:30 |
| 3 — Java ladder | 13:10 |
| 4 — Scala 3 | 8:30 |
| 5 — Idris 2 | 5:30 |
| 6 — Close | 4:00 |
| **Total** | **44:25** |

Against 45:00 hard + 3:00 borrowable, leaving **0:35 of slack**. Draft 2's table said 45:10; that was an arithmetic error (Act 6 sums to 4:15, not 5:00). These are still estimates — the honest number comes from the stopwatch read-through (execution step 11), not this table. The cut list below is the safety margin and reaches 39:40.

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
| `07-toolkit` — 2,500 years of logic | 1:30 | **absorbed** into S4/S5 as each notation's origin |
| `08-crisis` — Russell / Gödel | 1:30 | **restored as S7**; only Hilbert's sound/complete triple → A5 |
| `09/11/13-convergence` — five history beats | 1:45 | **absorbed** into S8 and S9 |
| `12-mltt` — Π/Σ rules standalone | 0:25 | **absorbed** into S9; shown running at S25 → A7 |
| `14-lambda-cube` — the cube as a slide | 1:00 | progressive reveals at S19/S24/S27; full slide → A8 |
| `15-test-spine` — the nine-invariant table | ~1:15 | → A9, the complete inventory |
| `21-bridge` — records → typestate | 1:30 | two sentences between S16 and S17 |
| `16-stage0` — JavaScript baseline | 0:45 | one line on S10 |

Only three of these are genuine time recoveries (the cube slide, the invariant table, the bridge and Stage 0 — about 4:30). The history slides are **absorbed, not cut**: their content moves into Act 1 as each notation's origin story. What actually pays for the longer primer is the removal of v1's *second telling* — the ladder no longer re-teaches ideas the history already covered.

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
| **Philosophy → logic → maths → CS** | **Act 1 entire (S4–S9), braided** |
| **Sum-of-products as core tactic** | planted S5, paid off S14–S16, recalled S28 |
| Typestate | S17, S18 |
| Generics | S6 (as ∀), S12 |
| Type-level expressions & pattern matching | S22 (`Dual[P]` match type), A11 |
| `Either` / `Result` | S14, same ∨E rule applied again |
| Effect systems, capture checking, capabilities | S23 (~40 sec), depth in A1 |
| **Types / values / references / memory model** | **S11** |
| Curry-Howard(-Lambek) | S8, the fulcrum |
| **Why it is called a *type*** | **S7 — Russell's paradox and his own fix** |
| **Cost, honestly** | **S29** |
| Java → Scala 3 → Idris 2 | Acts 3, 4, 5 |
| Pragmatic focus | 27:10 of 44:25 is the code ladder |

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
