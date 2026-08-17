# Talk v2 — Rework Plan (DRAFT 4)

Branch `talk-v2-rework`, off `talk-v1` (`93c8d95`).
**Delivery: Thursday 20 August 2026 — Java Meetup, Inspired Consulting GmbH, Köln.**
45 min + 15 min Q&A (up to 3 min borrowable).

## Status — 2026-08-17

| | |
|---|---|
| **Act 0 (slides 1–3)** | **DONE and signed off.** Verbatim scripts in `touying/scripts/`, linter-clean, 5:23 at planning rate / 3:48 at MB's measured rate |
| Acts 1–6 | not authored; v1 notes still in place and failing the linter in ~23 places (almost all `monotone`) |
| Toolchain | typst 0.15.1, touying 0.7.4, cetz 0.5.2 — verified |
| Tooling | `make check` = build + prose lint + timing. Prose linter runs as a PostToolUse hook |
| Speaking rate | measured twice: 177 and 185 wpm. Planning rate 130 (~28% live discount) |
| Code | Iron refinements landed in `05-scala3-payment` (`MinLength[1]` on lines, `GreaterEqual[0]` on quantities); compiles and runs |

**Read Part 8 and Part 9 before authoring any slide.** They are the accumulated
corrections, and every one of them was a mistake made once already.

---

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
| Runtime | 45 min hard; up to 3 min borrowable. Base plan 44:50 — the cut list is part of the plan |
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

## Part 3 — The deck: 30 main slides, 44:50 (Act 0 measured, rest estimated)

Legend: **NEW** · **KEEP** · **REWORK** · **MERGE** · **→A** (demoted to appendix)

### Act 0 — Open · 5:25 — **AUTHORED, SIGNED OFF**

| # | Slide | Time | Script |
|---|---|---|---|
| 1 | Title — carries the thesis | 1:00 | `scripts/01-title.md` |
| 2 | Four Bugs That Compiled — with the payment domain frame | 2:35 | `scripts/02-incidents.md` |
| 3 | The turn | 1:50 | `scripts/03-the-turn.md` |

Act 0 ran over its original 3:30 estimate because two things moved into it that were
not in draft 3: the **payment-domain frame** (S2 now establishes order → assess risk →
authorize → capture → refund before the four bugs use that vocabulary), and the
**thesis promise** (S1 now claims that writing a program which type-checks is, in a
precise sense, the same act as constructing a proof). Both earn the time. The overage
is taken from Act 4, which measured 10:36 in v1 against a 6:30 target.

**S1** promises the size of the real talk and puts the speaker inside the set of people
who have made these mistakes. **S2** frames the domain, then tells four bugs with no
code panes; the buggy code appears later, at the stage where it stops compiling.
**S3** concedes that a test could have caught all four, then draws the distinction that
survives — a test is a case somebody must think of and keep correct, an encoded rule is
applied at every call site by the compiler. It no longer restates S1's thesis.


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

**S8 must also discharge the promise slide 1 makes.** Slide 1 now claims that writing a
program which type-checks is, *in a precise sense*, the same act as constructing a proof.
That phrase points at rigour rather than hedging, so S8 has to say where the rigour ends:

> **The correspondence is exact for total, pure calculi. Java is neither.** `null` inhabits
> every reference type, unchecked exceptions escape any signature, and non-termination
> inhabits anything at all — so a Java method `A → B` does *not* prove `A implies B`, and
> Java's type system is not a sound logic.

This is a gift, not an embarrassment: it is the reason the ladder climbs. Each stage buys a
correspondence closer to exact — Stage 3 closes the disjunction, Stage 4 the lifecycle,
Stage 5 the predicate and the protocol, Stage 6 the runtime-to-type bridge and linearity —
and Idris's totality checker is what finally makes "well-typed means proved" literal.
Delivered this way, the caveat converts slide 1's promise into the talk's spine rather than
undercutting it. Delivered badly, someone in the room supplies `return null;` and the thesis
looks naive (see Part 8/C2).

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

### Act 2 — Ground floor · 2:45

| # | id | Slide | Time | Origin |
|---|---|---|---|---|
| 10 | `A2-scenario` | One scenario | 0:30 | REWORK `15-test-spine` — flow diagram only, nine-row list → appendix |
| 11 | `A2-values` | **Types, values, references** | 1:00 | **NEW** |
| 12 | `A2-promises` | **What a type checker actually promises** | 1:15 | **NEW** — restores the Hilbert/Gödel payoff |

**S12 (`A2-promises`) was agreed in review and was missing from draft 4 entirely.** Act 2's
budget was raised to make room for it and the slide was never added — the kind of loss that
only surfaces when the numbers stop working. It cashes out Act 1's S7 for practitioners:

| | In logic | In your type checker |
|---|---|---|
| **Consistent** | never derives a contradiction | no well-typed program can inhabit an impossible type |
| **Sound** | provable ⟹ true | if it compiles, the property holds |
| **Complete** | true ⟹ provable | every safe program is accepted — **deliberately abandoned** |

Two things must land, and one correction must not be lost:

1. **Completeness is given up for decidability, and that is Rice's theorem, not Gödel.** Every
   non-trivial semantic property of programs is undecidable, so a checker that always
   terminates must approximate, and it approximates on the safe side. Conflating this with
   Gödel's incompleteness is a real error and someone in the room may know it.
2. **Soundness is bounded by the escape hatches you use.** Java's own famous hole is the
   honest evidence:
   ```java
   Object[] arr = new String[1];
   arr[0] = 42;              // compiles. ArrayStoreException at runtime.
   ```
   Plus `null`, unchecked casts, Scala's `asInstanceOf`, Idris's `believe_me`.

**Do not claim the audience feels incompleteness daily** — MB's experience is that they mostly
do not, because when the compiler says no it is usually right. You start feeling it when you
try to encode a *stronger* invariant, which is exactly the cost this talk is asking them to
weigh. That hands off to S29.

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

### Act 4 — Scala 3 · 6:30

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

### Act 5 — Idris 2 · 5:15

| # | Slide | Time | Origin |
|---|---|---|---|
| 25 | Stage 6 + **MLTT running** | 2:00 | MERGE `28-stage6-bridge` + `29-mltt-running` |
| 26 | → **LIVE DEMO 4** | 2:30 | drop `finish done` → linearity error |
| 27 | *Unrepresentable* + cube reveal 3 | 1:00 | KEEP `30-stage6-payoff` (dark slide, emotional peak) |

**S25 is the payoff for the primer.** The Π and Σ notation from minute 8 is now on screen,
running: `protocolFromSnapshot : RiskSnapshot -> SessionType` *is* Π-elimination; `assessOrder :
Order n c -> (lvl ** Assessment lvl n c)` *is* Σ-introduction. Callback: *"That's the notation I
showed you in the primer and promised you'd see run. There it is."*

### Act 6 — Close · 3:30

| # | id | Slide | Time | Origin |
|---|---|---|---|---|
| 28 | `A6-cost` | **What it costs — and why the calculus is shifting** | 1:30 | **NEW** + MERGE `32-agentic` |
| 29 | `A6-monday` | What to do on Monday | 1:00 | MERGE `where-to-start` + `33-horizon` (3 lines) |
| 30 | `A6-close` | Close | 1:00 | KEEP `34-close` |

**`31-the-climb` is cut, structurally rather than to save time.** The last four minutes
otherwise carry three summaries: the dark *Unrepresentable* slide (the emotional one), the
climb table (the technical one), and the close (the argumentative one). Two of those are
enough, and the dark slide plus the close are the two that work. → appendix.

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
- **Gradual typing** (raised in review). Moved here from `A2-values`: it is an *adoption*
  argument, not a claim about what a type is, and "how do I start without a rewrite" is the
  question this slide exists to answer. Frame it in terms this room already lives in — `var`,
  raw types interoperating with generics, `@Nullable` layered onto an existing codebase,
  Kotlin's platform types at the Java boundary — and name TypeScript only as the cleanest
  large-scale demonstration. The point: a type layer can be added incrementally, one module at
  a time, which turns "adopt a type system" from a migration into a series of local decisions.
- Landing line: *"The question was never 'should I use dependent types for my CRUD endpoints.'
  It's: is this invariant expensive enough to encode? The tools keep getting cheaper, so that
  set keeps getting bigger."*

### Budget

| Act | Time | State |
|---|---|---|
| 0 — Open | **5:25** | **measured** |
| 1 — History braided into the primer | 8:15 | estimated |
| 2 — Ground floor | 2:45 | estimated |
| 3 — Java ladder | 13:10 | estimated |
| 4 — Scala 3 | 6:30 | estimated — measured 10:36 in v1, so this is the least trustworthy row |
| 5 — Idris 2 | 5:15 | estimated |
| 6 — Close | 3:30 | estimated |
| **Total** | **44:50** | one act measured, six guessed |

Against a 45:00 hard stop, that is **0:10 spare** — which is rounding, not slack.

**Say this plainly rather than manufacture margin: the base plan does not comfortably fit, and
the cut list below is therefore part of the plan, not a contingency.** Six of the seven acts
are estimates by someone who is not the speaker; Act 4 in particular measured 10:36 in v1 and
is budgeted at 6:30, which is the single largest act of optimism in the table. The number that
decides this is the stopwatch read-through (execution step 11), and it should happen as soon as
Act 1 and Act 3 exist rather than at the end.

Draft 2's table said 45:10 and draft 4's said 45:20 while claiming 0:35 of slack; both were
wrong, in the same direction. See Part 8/C10.

**Cut order if running behind** — apply in this order; never cut Demo 1 or Demo 4:

Referenced by name, not by number — slide numbers have gone stale twice already (Part 8/C12).

1. `A4-demo3` → narrate over the static pane (−1:30)
2. `A4-mechanisms` → name three of six, drop the effects aside (−1:00)
3. `A3-gentzen` → state the rule verbally over the Stage 3 slide (−1:00)
4. `A3-demo2` → narrate over the static pane (−1:15)
5. **Merge `A1-connectives` and `A1-quantifiers`** onto one slide (−1:00) · *the first
   primer-side cut; take it only if Act 1 measures long in the read-through*

Full depth reaches **39:05**, which is the real floor if the read-through comes in long.

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

Only four of these are genuine time recoveries — the cube slide, the invariant table, the bridge and Stage 0, about 4:30 between them. The history slides are **absorbed, not cut**: their content moves into Act 1 as each notation's origin story. What actually pays for the longer primer is the removal of v1's *second telling* — the ladder no longer re-teaches ideas the history already covered.

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
| Pragmatic focus | 24:55 of 44:50 is the code ladder (Acts 3–5) |

---

## Part 6b — Authoring triage: what actually needs a verbatim script

Act 0 was scripted verbatim because it is the stumble zone — cold open, unfamiliar material,
highest stakes, and the place MB measured a 3–4× overrun on his first attempt. **That reasoning
does not apply uniformly, and treating all 30 slides as verbatim work is not a plan.**

| Act | Slides | Treatment | Why |
|---|---|---|---|
| 0 — Open | 3 | **verbatim** ✅ done | stumble zone; no code to lean on |
| 1 — Primer | 6 | **verbatim** | new, abstract, no code to lean on; the biggest authoring block left |
| 2 — Ground floor | 3 | cues + one scripted landing line each | conceptual but short |
| 3 — Java ladder | 8 | **cues only** | MB's own code and two live demos; reading a script over a live edit is worse than improvising |
| 4 — Scala 3 | 5 | **cues only** | same |
| 5 — Idris 2 | 3 | **cues only** | same |
| 6 — Close | 3 | cues + scripted landing line | the last sentence should be exact; the rest need not be |

**Verbatim burden: 9 slides, not 30.** Act 1 is the block that matters.

**Fallback if authoring stalls.** In priority order, what ships:
1. Act 1 authored — without it the talk has no primer, which is the whole point of v2.
2. `A2-promises` and `A6-cost` — the two slides carrying content v1 never had.
3. Everything else keeps its v1 note and ships as-is. The v1 notes fail the prose linter in
   ~23 places, almost all `monotone`, but a linter failure is a register complaint, not a
   correctness one — those slides are deliverable if unpolished.

---

## Part 7 — Execution order

Three days. Ordered so that a stop at any point still leaves a deliverable deck.

1. ~~**Bug fix + metadata** — Stage 3 code-pane overflow; title slide date/venue~~ **DONE**
1b. ~~**Act 0 authored and signed off**; scripts extracted to `touying/scripts/`; prose
    linter + hook; timing tool calibrated against two real read-throughs~~ **DONE**
1c. ~~**Iron refinements** in `05-scala3-payment`~~ **DONE**
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

---

## Part 8 — Standing corrections

Every item below is a mistake made once in this rework and corrected by MB. They
are recorded because they recur, and because most of them are not matters of taste.
Where a rule is mechanically checkable it is enforced by `tools/prose-lint.py`;
the rest have to be checked by reading.

### C1 — Do not read a plan as a description of reality *(enforced by nothing)*

`DOMAIN_REWORK.md` describes desired state in the present tense. An earlier memory
read it as achieved and was wrong about stage count, stage numbering, and which
incident closes where. **Verify against artifacts** — the slides, the code, the
build — never against a document that says what should be true.

### C2 — Overclaiming makes the argument weaker *(enforced: `overclaim`)*

Three separate instances, all with the same shape: reaching for a stronger contrast
than the facts carry, so the audience immediately supplies the counterexample.

| Claimed | True |
|---|---|
| "four production incidents" | Alice's was caught in test; escaping to production is process and luck |
| "more test coverage would not have changed that" | a two-line fixture is exactly what found Alice's |
| "not easier to test for — impossible" | also a negative-contrast construction |
| "Java cannot express approval indexed by risk" | it can, via phantom generics and witness encodings; the real limit is narrower |

The pattern: **the weaker claim is usually the stronger argument.** Concede what is
true, then draw the distinction that survives scrutiny.

### C3 — Establish a domain before using its vocabulary *(read for it)*

The four bugs used *authorize*, *capture*, *risk tier*, *payment rail*, *refund* and
*KYC* before anything told the audience what a payment flow looks like. The domain
strip on S2 now precedes them. Applies to every act: **name the frame, then fill it.**

### C4 — Examples must survive a practitioner's disbelief *(read for it)*

Alice's bug originally produced a €450,015 invoice in a staging batch, which is not
credible — and the credible version turned out to be *better*, because the reason it
survived (`reduce` over one element returns that element, so single-line fixtures all
pass) is itself the point about tests covering only the cases you thought of. Ask of
each example: would somebody who has built this believe it happened?

### C5 — Do not add jargon the room does not share *(enforced: `jargon`)*

KYC was the only story outside the payment domain, and the term is not universal in
a Java meetup. It also revealed a deeper mismatch: the Scala session-type code models
the *payment* protocol, so the story and the code meant to close it described
different systems. **Prefer a term the talk has already established.**

### C6 — Prose register *(enforced: `tricolon`, `negative-contrast`, `fragment-climax`, `anaphora`, `padding`, `rhetorical-qa`, `kicker`, `monotone`)*

The banned constructions are in `touying/scripts/README.md`. The one worth restating
here, because it is counter-intuitive and I got it backwards once: **a flat run of
short declaratives is itself a machine tell.** Shortening everything is not the fix
for bad prose; varied rhythm with real subordination is. An earlier version of the
linter enforced a 25-word hard cap and would have driven the prose straight into the
fault it existed to prevent.

### C7 — Check the joins, not only the beats *(read for it)*

S3 jumped from "more tests would not have helped" straight into the 2,500-year
framing sentence with nothing between them. Each beat can be right while the
sequence is unreadable. **After drafting a slide, read the last sentence of the
previous one and the first of the next.**

### C8 — Facts and theory claims both need checking *(read for it)*

Errors found: 3DS liability runs *to the issuer* on success, so skipping it leaves it
with the merchant (had it backwards); Aristotle is ~350 BCE, so 2,400 years, not
2,500; type-checker conservatism is **Rice's theorem and decidability**, not Gödel's
incompleteness; Curry-Howard-Lambek is precise for STLC ↔ intuitionistic propositional
logic ↔ cartesian closed categories, and extending it to dependent types is more
delicate. "Sounds right" is not checked.

### C9 — When told to diagnose, check placement before proposing deletion *(read for it)*

Draft 1 cut the history section because it "motivated in the wrong direction". The
real fault was that v1 told every idea twice — once abstractly, once concretely —
and the fix was to braid them, not to amputate the first telling. **Ask whether the
fault is the content or its position.**

### C10 — Budget honestly; do not shave to fit *(enforced: `make timing`)*

I twice made the arithmetic work by trimming fifteen seconds from several slides,
which is how a deck overruns on the night. Caps are now set to what the written
script measures, and when a section grows the time is taken from a named other
section. Rate is calibrated against a real read-through, not assumed.

### C12 — Do not use derived numbers as identifiers *(read for it)*

The plan has been renumbered twice and both times left stale cross-references, because slide
numbers are simultaneously identifiers and positions — so any insertion silently invalidates
every reference downstream. The cut list still said `S12 Gentzen` after Gentzen became 13.
**Cross-references now use stable ids** (`A3-gentzen`, `A4-mechanisms`) and the numbers are
treated as derived. Same failure mode as C1: trusting a representation that drifts from what
it describes.

### C11 — Write MB's voice only where asked, and always flag the edit *(read for it)*

MB wants verbatim script for the opening. Where his own sentence is restructured,
the original stays in the script file with the reason, so the change is reversible.

---

## Part 9 — What the Act 0 prose diff taught

Part 8 came from MB's change-requests. This part comes from something narrower and
more useful: comparing what I drafted for Act 0 against what MB actually shipped
after three rounds. The corrections cluster, and the clusters are not about grammar.

### L1 — I under-promise in openings

| mine | shipped |
|---|---|
| "a line of thinking a great deal older than any of us, which most of you already use without calling it that" | "By the end I think you'll see that writing a program that type-checks is, **in a precise sense, the same thing as constructing a proof in formal logic** — and that you've been doing it all along" |

I gestured at the thesis; MB stated it and accepted being held to it. My version was a
tease, and "already use without calling it that" is the shape of a claim rather than a
claim. **The strong version is also the honest one** — it tells the audience what they
are buying. Note this is the *opposite* of the overclaiming in Part 8/C2: I overclaim
about facts I cannot support and underclaim about the thesis I can. Both are failures
to say the true thing at its true strength.

### L2 — Put the speaker inside the set

I wrote the four bugs as things that happened to other people. MB added: *"Programmers
have made these kinds of mistakes for as long as there has been software, and I've
certainly been one of them."* For a talk arguing that the audience should change how
they work, the participant stance is far less alienating than the authority stance —
and it costs one sentence.

### L3 — Name the consequence, not the mechanism

| mine | shipped |
|---|---|
| "…almost every fixture used a single-line order, and reduce over one element just hands that element back" | "…almost every fixture used a single-line order — **and so summing wasn't actually tested**" |

Mine correctly explains *how* the symptom is produced. MB's names *what was missing*,
which is the point of the beat. The `reduce` detail is still needed — for credibility —
but it belongs in the fact-sheet, not the spoken line. **Explain the mechanism only
where the mechanism is the argument.**

### L4 — Voicing beats narrating, and it is where the humour lives

| mine | shipped |
|---|---|
| "Medium satisfies that condition. So medium-risk orders took the fast path too" | "**Well — medium isn't high… so off to the fast path we go.**" |

MB voices the machine's reasoning in the first person. That is the levity in Act 0, and
it is not decoration: it dramatises the compiler's indifference, which *is* the thesis.
Humour in a technical talk lives in voicing the mechanism, not in jokes bolted onto it.

### L5 — Name the topic's real concepts when bridging into it

| mine | shipped |
|---|---|
| "What a language lets you say in the first place is a much older question than programming" | "**How we can tell whether something is valid, and how we can say what that means** — those questions are much older than programming" |

Mine was about permission. MB's names **validity** and **meaning** — precisely the two
threads Act 1 then follows (Aristotle and Gentzen for validity, semantics for meaning).
A bridge should be built from the material on the far side, not from a generic paraphrase.

### L6 — Compress by fusing, not by deleting

Mine offered the proposition reading only ("a claim about every possible type"). MB's
fuses proposition and program into one clause — *"stating that you can do something for
every type"* — which is the Curry-Howard pairing four slides before it is named. And
"present and future" carries the parametricity point in two words where I had proposed
nine. **My compression removes content; his compresses content together.**

### L7 — Check what a metaphor implies about the audience's status

I wrote "I want to give you the vocabulary for that." MB: reads like foreign-language
homework. The metaphor makes the audience pupils. What the talk actually does is show
connections and the capabilities that follow — which makes them practitioners who gain
power. Same content, opposite social position. **Ask what relationship a metaphor
implies before using it.**

### L8 — Monotone register, one level above monotone rhythm

MB's prose moves between registers: *"for as long as there has been software"*, *"off to
the fast path we go"*, *"twelve digits instead of two"*, then formal precision for the
thesis. Mine sits at a uniform mid-formal level throughout. This is the same fault the
linter catches as `monotone` — flatness — but at the register layer, where no rule can
see it. **Vary the register deliberately; the informal moments are where an audience
relaxes enough to follow the hard part.**

### L9 — A number lands by contrast, not magnitude

Mine: "a daily total with twelve digits." MB: "twelve digits **instead of two**." The
comparison does the work; the magnitude alone does not.

### L10 — The unit of coherence is the sequence, not the slide

Caught twice, both by MB. Slide 3 restated slide 1's thesis more weakly once slide 1 had
been strengthened. Slide 3 re-derived how a test would have caught Alice's, which slide 2
had already shown happening. I check each slide against its own brief; nobody was
checking each slide against **what the audience has already been told**. After drafting
any slide, re-read the two either side of it.

### L11 — Edits have blast radius

In one pass I changed *"I've certainly been one of them"* to *"made my share"* while
tightening for length — a phrase that was never the problem. Restoring it then created a
pronoun collision with a later clause ("tools to prevent them" reading as preventing
programmers). **When editing for one property, diff for changes to the others. A restore
is an edit too, and needs its neighbourhood re-checked.**

