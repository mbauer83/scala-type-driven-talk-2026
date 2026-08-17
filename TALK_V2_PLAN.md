# Talk v2 — Rework Plan (DRAFT 6)

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
| Runtime | 45 min hard; up to 3 min borrowable. Base plan **40:50**, 4:10 spare at the measured rate |
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

The cube is **not** front-loaded. It appears four times — one glimpse and three reveals, at the *threshold* moments, gaining
lit edges each time — so it functions as a navigation aid that earns its detail as the audience
acquires it:

| Appearance | Where | What is lit |
|---|---|---|
| Glimpse | `A1-above`, primer — one line, no explanation | nothing lit; "there is a map of this territory; we'll fill it in as we go" |
| Reveal 1 | `A3-ceiling`, the Java ceiling | `f(x)` → `f[A]` edge lit — Java's reach; the two unlit axes named |
| Reveal 2 | `A4-ceiling`, the Scala ceiling | `F[A]` edge lit — type-level computation; one axis still dark |
| Reveal 3 | `A5-payoff`, after Idris | `B(a)` edge lit — the cube is complete |

**Implementation:** refactor `diagrams/lambda-cube.typ` from a fixed canvas value into
`lambda-cube-canvas(reveal: 0)`, where `reveal` selects which path edges are drawn in the
highlight colour and which stage tags are shown. Straightforward parameterisation of the
existing drawing; no new geometry.

---

## Part 3 — The deck: 31 main slides, **40:50 planned against 45:00** (measured rate)

Legend: **NEW** · **KEEP** · **REWORK** · **MERGE** · **→A** (demoted to appendix)

### Act 0 — Open · 5:25 — **AUTHORED, SIGNED OFF**

| # | Slide | Time | Script |
|---|---|---|---|
| 1 | Title — carries the thesis | 1:00 | `scripts/01-title.md` |
| 2 | Four Bugs That Compiled — with the payment domain frame | 2:35 | `scripts/02-incidents.md` |
| 3 | The turn | 1:50 | `scripts/03-the-turn.md` |

Act 0 ran over its original 3:30 estimate because two things moved into it that were
not in draft 3: the **payment-domain frame** (`A0-incidents` now establishes order → assess risk →
authorize → capture → refund before the four bugs use that vocabulary), and the
**thesis promise** (`A0-title` now claims that writing a program which type-checks is, in a
precise sense, the same act as constructing a proof). Both earn the time. The overage
is taken from Act 4, which measured 10:36 in v1 against a 6:30 target.

**`A0-title`** promises the size of the real talk and puts the speaker inside the set of people
who have made these mistakes. **`A0-incidents`** frames the domain, then tells four bugs with no
code panes; the buggy code appears later, at the stage where it stops compiling.
**`A0-turn`** concedes that a test could have caught all four, then draws the distinction that
survives — a test is a case somebody must think of and keep correct, an encoded rule is
applied at every call site by the compiler. It no longer restates `A0-title`'s thesis.


### Act 1 — Where this comes from, and why you already write it · 8:15 — *the main new content*

The braid. Each slide = one person, one problem they were solving, one notation, and the Java
the audience already writes in that notation.

| id | Slide | Who / what problem | Time | Origin |
|---|---|---|---|---|
| `A1-aristotle` | What makes an argument valid | **Aristotle**, 4th c. BCE | 1:15 | **NEW** (absorbs `07-toolkit`) |
| `A1-connectives` | The connectives — and logic becomes mechanical | **Leibniz** (named) → **Boole** 1847 → **Frege** 1879 | 1:30 | **NEW** (absorbs `07-toolkit`) |
| `A1-quantifiers` | The quantifiers — `∀` and `∃` | **Frege**'s Begriffsschrift | 1:15 | **NEW** |
| `A1-crisis` | The crisis, why it's called a *type*, and what checking can promise | **Russell** 1901, **Hilbert**, **Gödel** 1931 | 1:15 | **RESTORED** `08-crisis` |
| `A1-curry-howard` | Proposition = Type. Proof = Program. | **Church/Turing** 1936, **Curry-Howard** 1969, **Lambek** | 1:45 | REWORK `curry-howard` + absorbs `09`/`11-convergence` |
| `A1-above` | What lies above — briefly uncovered | **Martin-Löf** 1972, **Coquand** 1988 | 1:15 | **NEW** + absorbs `12-mltt`, `13-convergence3` |

**`A1-aristotle`** — validity is a property of *form*, not content. Two columns; the right one is the left
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

**`A1-connectives` — the connectives, and the moment logic becomes mechanical.** Boole 1847 turns logic into algebra — the first time inference becomes symbol-pushing a machine could do, which is what **Leibniz** had wanted two centuries earlier when he imagined a *calculus of reasoning* and said *let us calculate*. Leibniz is named here, in a clause, and appears on the rail; he does not get a beat (see Part 6b/D2). Frege 1879 then builds the first system
that can actually carry mathematics. Formalism left, the Java they already write right.
*Snippets must
be lifted verbatim from `03-java-function-types-sealed/`, not invented* — the audience sees this
same code fifteen minutes later and any seam is noticeable.

```
risk = Low ∨ Medium ∨ High
medium → threeDS

  public sealed interface RiskDecision
      permits RiskDecision.Low, RiskDecision.Medium, RiskDecision.High {   ← the ∨

      record Low()    implements RiskDecision {}
      record Medium() implements RiskDecision {}                           ← the ∧
      record High()   implements RiskDecision {}
  }
```

Snippet is verbatim from `RiskDecision.java:9-13` — `public`, the **qualified** permits names on
**one line**, and the records as **nested members**.

**`record Medium()` must be on the slide.** Draft 6 wrote this snippet with Low and High only,
while the punchline says *"exactly one variant"* and while Medium is Bob's entire bug and the
subject of Demo 1 four slides later. That is the third time this paragraph's own instruction was
violated in the act of restating it — do not paraphrase, extract (see the extract-snippet note in
Part 7).

`→` and `¬` appear in the left column but are not taught here; name them and move on, or drop
them. Note also that a classical-looking `¬` sits awkwardly beside `A1-curry-howard`'s claim of an isomorphism
with *intuitionistic* propositional logic.

Punchline: *"`∨` is a sealed interface — exactly one variant. `∧` is a record — all fields at
once. **Sums of products.** That combination carries most domain modelling you will ever do, and
it shipped in Java 17."* This is where sum-of-products is planted; paid off at `A3-stage3` through `A3-payoff-bob`.

**`A1-quantifiers` — the quantifiers.** Frege's real innovation: propositions with holes in them, and
quantifiers that range over values.

```
∀o. medium(o) → needs3DS(o)    static <T> Validator<T> check(…)   ← ∀T
```

Punchline: *"When you wrote your first `<T>`, you wrote a universally quantified statement and
proved it once, for all T. That is not an analogy. It is the same statement."*

**Do not put `Optional<Proof>` on this slide as `∃`.** It was there and it is wrong: `Optional[T]`
is `T ∨ 1`, a disjunction. The Curry-Howard reading of `∃x:A. B(x)` is a *dependent pair*, which
is exactly what `A1-above` introduces as Σ and what Stage 6 shows as the thing Java cannot express. A
listener who joins this slide to `A1-above` would conclude Java has Σ-types. Either show ∀ alone here,
or use the honest weaker form: a returned value, when present, is a *witness* for ∃ — it is not
the existential itself.

**`A1-crisis` — the crisis, and where the word "type" comes from.** Restored from v1's `08-crisis`, but
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

**`A1-curry-howard` — Curry-Howard(-Lambek), the fulcrum.** Church and Turing 1936 as a one-line lead-in — *"the
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

**`A1-curry-howard` must also discharge the promise slide 1 makes.** `A0-title` now claims that writing a
program which type-checks is, *in a precise sense*, the same act as constructing a proof.
That phrase points at rigour rather than hedging, so `A1-curry-howard` has to say where the rigour ends:

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

**`A1-above` — what lies above, briefly uncovered.** Martin-Löf 1972 and Coquand 1988 — the kernel behind
Lean, Rocq, Agda and Idris. Four one-liners, deliberately *not* explained in depth:

```
Approval : RiskLevel -> Type          Π    a TYPE indexed by a runtime VALUE
(lvl ** Assessment lvl)               Σ    a value bundled with a proof about itself
(1 _ : Session p) -> …                QTT  this resource must be used exactly once

`riskOf` does not exist in `06-idris2-payment` — draft 6 invented it. The real value-indexed
families are `data Approval : RiskLevel -> Type` (`PaymentDomain.idr:264`) and
`data AuditTrail : PaymentState -> Currency -> Nat -> Type` (`:284`); the real Π-elimination is
`protocolFromSnapshot`. The linear binder is always `(1 _ : …)`, never named
(`PaymentChannel.idr:82,88,98`).

Type names are verbatim (`Receive`, not `Recv` — `protocol/Proto.scala:13`). **Show it as a
truncated real protocol, not a fabricated short one.** The real `LowRiskProtocol`
(`Derivation.scala:38-43`) is five levels deep and has a `Receive[RiskSnapshot, …]` step between
the send and the authorization; draft 6 invented a two-level `Send[Order, Receive[
AuthorizedPayment[R], End]]` that exists nowhere, one line below the warning against inventing
types. Either truncate the real one with an ellipsis, or say explicitly that it is schematic.
Send[Order, Receive[RiskSnapshot, …]]     session type — a conversation, as a type
```

Contract with the room: *"You will not walk out of here fluent in this syntax. That's fine — it
isn't the point. You'll walk out knowing what each of these **buys** you, and you'll have watched
all four run on a payment flow."* Plus the one-line cube glimpse (Part 2, Device 2).

### Act 2 — Ground floor · 2:45

| id | Slide | Time | Origin |
|---|---|---|---|
| `A2-scenario` | One scenario | 0:30 | REWORK `15-test-spine` — flow diagram only, nine-row list → appendix |
| `A2-values` | **Types, values, references** | 1:00 | **NEW** |
| `A2-promises` | **What a type checker actually promises** | 1:15 | **NEW** — restores the Hilbert/Gödel payoff |

**`A2-promises` (`A2-promises`) was agreed in review and was missing from draft 4 entirely.** Act 2's
budget was raised to make room for it and the slide was never added — the kind of loss that
only surfaces when the numbers stop working. It cashes out Act 1's `A1-crisis` for practitioners:

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
weigh. That hands off to `A6-cost`.

**`A2-values` is the new grounding slide** requested in review — the hinge between logic and code, kept
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

| id | Slide | Time | Origin |
|---|---|---|---|
| `A3-stage12` | Stages 1+2 — nominal types & generics | 1:15 | MERGE `17-stage1` + `18-stage2` |
| `A3-gentzen` | Gentzen: how a connective is defined | 1:15 | KEEP `10-gentzen-or`, **moved here** |
| `A3-stage3` | Stage 3 — records + sealed = sums of products | 2:00 | REWORK `19-stage3` (overflow already fixed, `bdd1601`) |
| `A3-demo1` | → **LIVE DEMO 1** | 2:30 | delete `case Medium` → ∨E |
| `A3-payoff-bob` | Payoff — *Bob's bug is now a compile error* | 0:40 | REWORK `20-stage3-payoff` (Device 1) |
| `A3-stage4` | Stage 4 — phantom typestate | 2:00 | REWORK `22-stage4` |
| `A3-demo2` | → **LIVE DEMO 2** | 2:00 | uncomment `capture(init)` |
| `A3-ceiling` | Payoff + **Java ceiling** + cube reveal 1 | 1:30 | MERGE `23-stage4-payoff` + `24-java-ceiling` |

**`A3-gentzen` is the structural fix for P2** — Gentzen's ∨I₁/∨I₂/∨E now sit sixty seconds before the
compile error they explain instead of eight minutes before it.

**`A3-stage3`** is where Bob's actual buggy code first appears, beside the sealed version. `Result<T>`
lands here as the same rule applied again: *"no `.get()` escape hatch. Scala spells it `Either`,
Rust spells it `Result`."* The current slide has a real rendering bug — the `RiskDecision.java`
pane wraps comments outside the box and clips at the bottom — fixed as part of this.

**`A3-stage4`** is where Charlie's actual buggy code appears, then dies. Stage 0 (JavaScript) and the
`21-bridge` slide are both gone; each becomes one spoken sentence.

### Act 4 — Scala 3 · 8:30 — **the act that has never fit**

| id | Slide | Time | Origin |
|---|---|---|---|
| `A4-opens` | Stage 5 — what opens up | 1:30 | REWORK `25-stage5` |
| `A4-demo3` | → **LIVE DEMO 3** | 2:15 | `AutoApproved` → error at `ch.send` |
| `A4-sessions` | Session types + duality | 1:45 | REWORK `26-session-types` |
| `A4-mechanisms` | Mechanisms + **effects / capture checking** | 1:30 | REWORK `stage5-mechanisms` + promote `a01` |
| `A4-ceiling` | Payoff + Scala ceiling + cube reveal 2 | 1:30 | MERGE `27-stage5-payoff` + `scala3-ceiling` |

**`A4-sessions` is where type-level expressions and pattern matching land explicitly** — `Dual[P] = P match
{ case Send[a,n] => Receive[a, Dual[n]] … }`: pattern matching and recursion, at the type level,
run by the compiler over types. Also Danielle's close.

**`A4-mechanisms`** carries the effects aside, ~40 seconds: *"`ZIO[Database, DbError, User]` puts 'this needs
a database' in the type. Scala 3's experimental capture checking does the same without the monad
— `User^{db}`. Same idea one level up: not which values you hold, but which capabilities they
carry."* Depth stays in appendix A1.

### Act 5 — Idris 2 · 5:30

| id | Slide | Time | Origin |
|---|---|---|---|
| `A5-mltt` | Stage 6 + **MLTT running** | 2:00 | MERGE `28-stage6-bridge` + `29-mltt-running` |
| `A5-demo4` | → **LIVE DEMO 4** | 2:30 | drop `finish done` → linearity error |
| `A5-payoff` | *Unrepresentable* + cube reveal 3 | 1:00 | KEEP `30-stage6-payoff` (dark slide, emotional peak) |

**`A5-mltt` is the payoff for the primer.** The Π and Σ notation from minute 8 is now on screen,
running. The real signatures, from the code rather than from memory:

```idris
protocolFromSnapshot : (snap : RiskSnapshot) -> (n : Nat) -> (c : Currency) -> SessionType
assessOrder : Order n c -> (lvl : RiskLevel ** Assessment lvl n c)
```

`protocolFromSnapshot` takes **three** parameters (`PaymentRules.idr:212-214`) — the one-argument
story belongs to `protocolDerivedFrom` (`:224`) — but note it takes an `Order`, not a
`RiskSnapshot`, plus two implicits, so it is not a drop-in substitute. `assessOrder` lives in
**`PaymentDomain.idr:255`**, not `PaymentRules.idr`. And keep `: RiskLevel` in the Σ-type: dropping it is legal sugar that hides the index
type, which is the entire point of the slide. Callback: *"That's the notation I
showed you in the primer and promised you'd see run. There it is."*

### Act 6 — Close · 3:30

| id | Slide | Time | Origin |
|---|---|---|---|
| `A6-cost` | **What it costs — and why the calculus is shifting** | 1:30 | **NEW** + MERGE `32-agentic` |
| `A6-monday` | What to do on Monday | 1:00 | MERGE `where-to-start` + `33-horizon` (3 lines) |
| `A6-close` | Close | 1:00 | KEEP `34-close` |

**`31-the-climb` is cut, structurally rather than to save time.** The last four minutes
otherwise carry three summaries: the dark *Unrepresentable* slide (the emotional one), the
climb table (the technical one), and the close (the argumentative one). Two of those are
enough, and the dark slide plus the close are the two that work. → appendix.

**`A6-cost` is the new cost slide**, merged with the agentic-development argument because they are the
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
| 1 — History braided into the primer | 8:15 | estimated · **highest volatility** |
| 2 — Ground floor | 2:45 | estimated |
| 3 — Java ladder | 13:10 | estimated |
| 4 — Scala 3 | 8:30 | estimated · **highest volatility + worst budget risk** |
| 5 — Idris 2 | 5:30 | estimated |
| 6 — Close | 3:30 | estimated |
| **Total** | **40:50** | one act measured, six allocated |
| live demos | **9:15** | measured edits, unmeasured narration — **invisible to `make timing`** |

**Measured 2026-08-17 — three solo runs of Act 0, all 177–187 wpm.** The third was standing and
projecting; the conditions of the first two were never reported, and an earlier version of this
plan invented a seated-vs-standing comparison from that gap. **There is no such comparison.**
What the three runs establish is only this: alone in a room, MB delivers at about 180 wpm, and
the instrument is stable.

**Planning rate is 140** — ~180 minus 22%, covering nerves, recovery from a stumble, questions
from the floor, and the pauses audience reaction creates. None of those can be measured solo,
which is exactly why the discount exists.

**A cap is the airtime a slide gets on the night** — a pacing decision. It does not move when
the planning rate moves; the rate only decides how many words fit inside it.

| | |
|---|---|
| Caps total — the talk's intended length | **40:50** |
| Against 45:00 | **4:10 spare** |
| Of which unwritten | 17:05 |
| Allocated to slides that already have notes | 23:45 |
| …which currently hold v1 prose running | **38:12** |

**The real work item, stated plainly: the slides that already have notes must lose about 12:45
during the rework.** That is what REWORK and MERGE mean in Part 3 — not polish, compression. The
worst offenders are named by `make timing` and led by `34-close` (+1:24 over its cap even now),
`10-gentzen-or`, `26-session-types`.

**Two risks remain, and the rate is no longer one of them.**

1. **Volume on the 17:05 that is unwritten.** Those caps are allocations, not measurements. Act 0
   is the only act ever written against an allocation and it came in at **1.55×**. If Act 1
   behaves the same way its 7:10 becomes ~11:00 and the 4:10 of slack is gone.
2. **Demo narration**, 8:00 across four slides, still unwritten.

`make timing` is the number; this document quotes it.

**Cut order if running behind** — apply in this order; never cut Demo 1 or Demo 4:

Referenced by name, not by number — slide numbers have gone stale twice already (Part 8/C12).

1. `A4-demo3` → narrate over the static pane (−1:30)
2. `A4-mechanisms` → name three of six, drop the effects aside (−1:00)
3. `A3-gentzen` → state the rule verbally over the Stage 3 slide (−1:00)
4. `A3-demo2` → narrate over the static pane (−1:15)
5. **Merge `A1-connectives` and `A1-quantifiers`** onto one slide (−1:00) · *the primer-side
   cut, held in reserve.* MB's decision (17 Aug) is to **build Act 1 at six slides, measure, and
   rework only if it does not fit** — the merge was a scheduling default adopted while the
   budget was 2:05 over, and at 4:10 of slack it is no longer forced. Deciding it after
   measurement rather than before is also the right order: the ∀-is-a-generic-method beat may
   earn its own slide, and that is a question about the primer rather than about arithmetic.

Full depth reaches **41:20** (47:05 − 5:45). Draft 6 said 39:05, which was 44:50 − 5:45 — the
retracted draft-5 base, three paragraphs below the sentence diagnosing exactly this drift.

---

## Part 4 — What moves to the appendix

Nothing is deleted; eight things stop being spoken by default.

| Was | v1 cost | Now |
|---|---|---|
| `07-toolkit` — 2,500 years of logic | 1:30 | **absorbed** into `A1-aristotle`/`A1-connectives` as each notation's origin |
| `08-crisis` — Russell / Gödel | 1:30 | **restored as `A1-crisis`**; only Hilbert's sound/complete triple → A5 |
| `09/11/13-convergence` — five history beats | 1:45 | **absorbed** into `A1-curry-howard` and `A1-above` |
| `12-mltt` — Π/Σ rules standalone | 0:25 | **absorbed** into `A1-above`; shown running at `A5-mltt` → A7 |
| `14-lambda-cube` — the cube as a slide | 1:00 | progressive reveals at `A3-ceiling`/`A4-ceiling`/`A5-payoff`; full slide → A8 |
| `15-test-spine` — the nine-invariant table | ~1:15 | → A9, the complete inventory |
| `21-bridge` — records → typestate | 1:30 | two sentences between `A3-payoff-bob` and `A3-stage4` |
| `16-stage0` — JavaScript baseline | 0:45 | one line on `A2-scenario` |

Only four of these are genuine time recoveries — the cube slide, the invariant table, the bridge and Stage 0, about 4:30 between them. The history slides are **absorbed, not cut**: their content moves into Act 1 as each notation's origin story. What actually pays for the longer primer is the removal of v1's *second telling* — the ladder no longer re-teaches ideas the history already covered.

Appendix after the rework: A1 effects/capture · A2 linearity across languages · A3 Idris live
mismatch · A4–A8 the demoted theory · A9 the invariant inventory · A10 reading list · A11 match
types · A12 singletons. A genuine Q&A arsenal rather than dead weight.

---

## Part 5 — Live demos and their fallbacks

**All four edits have been executed against the real compilers.** Two were wrong as previously
documented; both are corrected here. `tools/capture-demos.sh` applies each edit, runs the
compiler, writes real output to `demos/`, and restores the source — it is the authoritative
description of what to type on stage, because unlike prose it is executed and cannot drift.

| id | Where | Edit | Captured output |
|---|---|---|---|
| `A3-demo1` | `03-…-sealed/Demo.java` | delete the `case RiskDecision.Medium m ->` arm | 4 lines · *"the switch expression does not cover all possible input values"* |
| `A3-demo2` | `04-…-typestate/Demo.java` | uncomment the line marked `← UNCOMMENT` | 5 lines · *"incompatible types: Payment&lt;Initiated&gt; cannot be converted to Payment&lt;Authorized&gt;"* |
| `A4-demo3` | `05-scala3-payment/…/PaymentDemo.scala` | `ThreeDSApproved(proof)` → `AutoApproved` | 9 lines · *"Found: payment.AutoApproved.type / Required: payment.Approval[payment.MediumRisk]"* |
| `A5-demo4` | `06-idris2-payment/src/Main.idr` | **replace** `finish done` **with** `pure ()` | 12 lines · *"There are 0 uses of linear name done"* |

**Two corrections worth keeping visible:**

*Demo 3 did not work as documented.* The claimed error — `Found: AuthorizedPayment[LowRisk],
Required: AuthorizedPayment[MediumRisk]` — never appeared. The failure surfaced one line later
at `ch4.send(...)` as `Required: ?1.Msg`, with the real type inside a seven-line `where:` clause
and two cascading not-found errors behind it: twenty lines of noise, on the slide arguing that
types give *precise* feedback. The fix is an explicit `: AuthorizedPayment[MediumRisk]`
ascription on that val, which moves the error to the edited line and reduces it to one. **The
ascription is load-bearing; removing it silently breaks the demo.** The error it now gives is
also a better teaching moment: *the approval you supplied is not the approval this risk level
requires* — Bob's bug, stated in types.

*Demo 4's edit was wrong.* `finish done` is the last statement of its `do` block, so commenting
it out yields `Last statement in do block must be an expression` — a syntax complaint, not the
linearity error the slide promises. Replacing it with `pure ()` keeps the block well-formed so
the linearity checker is what speaks.

**Rendering:** use the existing `code-pane(..., diagnostic: ("bad", label, body))` from
`code-pane.typ`. Part 5 previously called for a "terminal-styled pane"; that component does not
exist and does not need to.

---

## Part 6 — Where each required topic lands

| Required | Slide(s) |
|---|---|
| **Philosophy → logic → maths → CS** | **Act 1 entire (`A1-aristotle`…`A1-above`), braided** |
| **Sum-of-products as core tactic** | planted `A1-connectives`, paid off `A3-stage3`–`A3-payoff-bob`, recalled `A6-cost` |
| Typestate | `A3-stage4`, `A3-demo2` |
| Generics | `A1-quantifiers` (as ∀), `A3-stage12` |
| Type-level expressions & pattern matching | `A4-sessions` (`Dual[P]` match type), appendix |
| `Either` / `Result` | `A3-stage3`, same ∨E rule applied again |
| Effect systems, capture checking, capabilities | `A4-mechanisms` (~40 sec), depth in appendix |
| **Types / values / references / memory model** | **`A2-values`** |
| Curry-Howard(-Lambek) | `A1-curry-howard`, the fulcrum |
| **Why it is called a *type*** | **`A1-crisis` — Russell's paradox and his own fix** |
| **Cost, honestly** | **`A6-cost`** |
| Java → Scala 3 → Idris 2 | Acts 3, 4, 5 |
| Pragmatic focus | 27:10 of 47:05 is the code ladder (Acts 3–5), before demo narration |

---

## Part 6b — Triage by volatility

Draft 5 triaged by *treatment* (which slides need a verbatim script). Wrong axis. Draft 6
triaged by whether an artifact had been executed — closer, but still wrong, because it measured
the **process** and the question is about the **talk's content**.

### Two axes, not one

**Axis 1 — how settled the integration and presentation is.** Not *what are we claiming* — the
argument is clear and consistent throughout the talk, and has been since draft 3. What is
unsettled is **how the material is woven into the talk**: where a piece sits in the sequence,
how it interleaves with what surrounds it, in what order features are introduced and how each
builds on the last, how one act hands off to the next, what carries the point on the slide, and
how much time and detail each beat gets.

That is the work that remains, and it is why "the argument is settled" is no comfort: the same
argument can be delivered as a climb or as a list, and the difference is entirely integration.

**Axis 2 — downstream cost.** How many artifacts depend on the decision, and what does rework
cost if it changes? A decision governing six slides and a shared component is worth an hour of
thought; one governing three sentences is not.

**Focus where both are high.**

Two things that are *not* volatility axes, both of which produced wrong classifications in
earlier drafts: whether an artifact has been executed (that is an acceptance criterion, Part 7),
and whether the prose is written (prose converges quickly once integration is fixed — see the
trap below).

### Integration UNSETTLED × high downstream cost — this is where the thinking goes

| What is unsettled | Downstream | What exactly is open |
|---|---|---|
| **How Scala's additions over Java are introduced and progressed** | Act 4's 5 slides; the act that has never fit any budget | *What* Scala adds is settled. **How it is introduced and progressed is not.** Refinements, opaque types, match types, path-dependent types, session duality, HKT and the effects aside all arrive inside ~8 minutes; no order has been validated, and delivered as a list rather than a progression this act becomes a feature tour. The densest integration problem in the talk. |
| **How history and theory integrate** | Act 1's 6 slides **+ the progress rail component** | *That* history and logic braid into the primer is settled. **The braiding itself is not** — which Java mirror sits beside which notation, in what order, how much formalism each beat carries, and how the rail threads the eight names through six slides without becoming decoration. |
| **How features bridge across Java → Scala 3 → Idris 2** | 3 act boundaries | *That* each language hits a ceiling is settled. **How the transition is staged is not** — these are the joints that decide whether the deck reads as one climb or as three talks stapled together, and each is currently one sentence. |
| **Demo narration and placement** | 4 slides, **9:15 = 20% of the slot** | *Reclassified from SETTLED.* What each demo *proves* is settled; the edits run and the errors are captured. **How each is framed, how long it runs, and where it sits inside its act is not** — and it is **invisible to `make timing`** (Part 3's budget note). The largest unmeasured block in the talk at 20% of the slot. |

### Integration UNSETTLED × low downstream cost — decide fast, do not agonise

| What | Downstream |
|---|---|
| What each lambda-cube reveal actually says | 3 slides, ~3 sentences. The drawing already exists (`diagrams/lambda-cube.typ:29-195`) and its three highlight edges are already separate at `:71-73`, mapping 1:1 onto the reveals. Only the wording is open. |
| Which of `→` and `¬` to name on `A1-connectives` | one line |

### Integration SETTLED — transcription and checking, not design

| What | Why it is settled |
|---|---|
| The four bugs — content **and** placement (one slide up front, code deferred to the stage that kills it) | authored, signed off, measured twice |
| What each demo *proves* — its content, not its framing | four edits executed; four real errors captured to `demos/` |
| The code ladder and what each stage demonstrates | compiles and runs; unchanged by this rework |
| The payoff format (Device 1) | format fixed; only per-stage wording remains |
| The visual system | v1's design is good and is not being changed — **except** the cube parameterisation, Device 1's payoff layout, the first-ever use of `code-pane(diagnostic:)`, and the Act 1 progress rail, all of which are new component work and are budgeted nowhere |

### Two traps this triage exists to avoid

**Settled integration is not settled prose.** Act 0's argument *and* its integration were settled
before a word was written; the wording still took many rounds, and Part 9 exists because of it.
Prose converges quickly once integration is fixed — the linter catches the recurring faults
mechanically — so prose is cheap, and integration is not.

**And settled content is not verified description.** The code examples are stable; the plan's
claims about them were repeatedly not. Draft 6 asserted "stability is a property of the thing,
never of the sentence about the thing" and then, on the same page, invented a `riskOf` function,
a two-level session type, a named linear binder, and a `RiskDecision` missing the `Medium`
variant that Demo 1 is about. **Every code identifier in this plan must be grepped before it
becomes a slide.**

### Part 6b/D — the four decisions, stated as questions

Part 6b named four *areas*. An area is not a decision, and "settle Act 4's sequence" is not
something you can finish by noon. These are the actual questions; each wants one paragraph.

---

**D-A · Act 4 — what organises the Scala act?**

Seven mechanisms arrive in roughly eight minutes: refined types, opaque types, path-dependent
types, match types, session duality, higher-kinded types, and the effects/capture aside. The
current shape is *opens → demo → session types → mechanisms → ceiling*, where `A4-mechanisms`
is a six-row table. **A table of six mechanisms is a feature tour**, which is the failure mode
this act has always had.

- **(a) Mechanism-led** — current. Name each mechanism, show it. Honest, complete, flat.
- **(b) Problem-led** — each mechanism introduced by the bug it kills, the way Act 3 does with
  Bob. Costs coverage: some mechanisms have no incident attached and would be dropped or named
  only.
- **(c) One thread** — take a single order through the whole Scala stage, and let each mechanism
  appear where that thread needs it. Strongest narrative, hardest to author, and it is the shape
  Danielle's protocol story already wants.

*What makes this the highest-cost decision:* it governs five slides, the act that has never fit
any budget, and whether Danielle's close lands as a payoff or as an item.

---

**D-B · Act 1 — chronological or conceptual?**

The six beats are currently ordered by date: Aristotle → Boole/Frege → Frege → Russell →
Curry-Howard → Martin-Löf/Coquand.

- **(a) Chronological** — current. The 2,400-year sweep is the point, and the rail reinforces it.
  Risk: Russell's crisis interrupts the connectives→quantifiers→correspondence build.
- **(b) Conceptual** — connectives, quantifiers, the correspondence, then the crisis as the
  reason types exist at all, then what lies above. Cleaner build; loses the sweep the rail sells.

Sub-questions that fall out of it: which Java mirror sits beside which beat, how much formalism
each carries, and whether the progress rail is a per-slide component or one strip that persists.

---

**D-C · The three bridges — what does a transition assert?**

`A3-ceiling` → Act 4, `A4-ceiling` → Act 5, and `A0-turn` → Act 1.

- **(a) Ceiling-first** — current. State what the language *cannot* reach, then move up. Risk:
  three consecutive "here is what is impossible" beats read as a complaint.
- **(b) Capability-first** — state what becomes newly *possible*, and let the ceiling be implied.
- **(c) Alternate** — ceiling at the Java boundary (where the audience lives and needs the limit
  made concrete), capability at the Scala boundary (where they need a reason to keep climbing).

*What makes this high-cost:* it decides whether the deck reads as one climb or as three talks
stapled together, and it is currently one sentence per boundary.

---

**D-D · Demo narration — what is said, and does the fallback show?**

Eight minutes across four slides, entirely unwritten and invisible to `make timing`.

- What each demo says *before* the edit (setting up what the audience should watch for), *during*
  (silence, or narration over typing), and *after* (reading the error aloud, or letting it sit).
- Placement inside the act: immediately after the setup slide, or after the payoff?
- **Does the captured fallback pane show by default, or only on failure?** Showing it always is
  safer and costs nothing on the night; showing it only on failure keeps the live moment live.
  This is a real trade and it is currently undecided.

---

---

## Part 6b/D2 — decisions taken (MB, 17 Aug)

**D-A — DECIDED: (c) one thread, falling back to (b) problem-led if it will not fit.**

Take a single order through the whole Scala stage and let each mechanism appear where that
thread needs it. If authoring proves too slow, drop to problem-led: each mechanism introduced by
the bug it kills. Both beat the mechanism table, which is the feature tour this act has always
been. Note the two are compatible — the thread *is* a sequence of problems — so starting on (c)
and degrading to (b) costs nothing already written.

**D-B — DECIDED: chronological stays. Two amendments.**

*i. Leibniz earns a place, but not a slide.* The case for a beat: he is the first person to say
that valid inference could be carried out **by a machine** — the *characteristica universalis*
and the *calculus ratiocinator*, "let us calculate" — and mechanical checkability is precisely
what makes this talk's thesis matter. A proof nobody checks is only a claim; the type checker is
the machine Leibniz wanted. He also gives a free hook for this audience in binary encoding.

The case against a beat: he produced no working system, the programme failed in his lifetime,
and Act 1 is already 7:10 across six beats — a seventh costs ~1:10 for an idea that fits in a
clause. **Resolution: Leibniz is named inside the Boole/Frege beat as the man who wanted the
machine, and he appears on the progress rail.** That is a place, at a cost of about fifteen
words rather than seventy seconds.

*ii. Proof-calculi and mechanical checkability get integrated properly*, which is the thing MB
identified as under-served. The fix is a redistribution across two existing beats rather than a
new one:

- **`A1-connectives`** now carries *logic becomes algebra, therefore mechanically manipulable* —
  Boole's algebra is the first time inference becomes symbol-pushing a machine could do, and
  Leibniz is named here as the one who wanted it.
- **`A1-crisis`** now carries *what mechanical checking can and cannot promise* — consistency and
  soundness as the requirements, Gödel as the proof that completeness is not available. This is
  where proof-calculi belong, and it makes `A2-promises` a cash-out rather than a fresh topic.

**D-B/iii — THE EQUIVOCATION TO AVOID (MB, and it is the sharpest point in this section).**

The talk must never blur **the logic *in* the program** with **the logic *about* the program**.

A Java developer who hears "you already write logic" will think of `if (a && b)` — boolean
conditions and control flow. That is *not* what Curry-Howard is about, and if the audience
settles on that reading, the whole primer lands as a triviality they already knew.

The correct statement, in MB's formulation:

> **A program is a construction; under Curry-Howard it *is* a proof. What we are proving is
> expressed by its type — and that holds even in languages with no written types, where the
> proposition is implicit and simply goes unchecked. The type also constrains how you may get
> from one construction to the next.**

So the three things must stay distinct and be *said* distinctly:

| | |
|---|---|
| the **program** | the construction — the proof term |
| the **type** | the proposition being proved |
| the **checker** | the machine that verifies the construction proves the proposition |

Every beat in Act 1 must be checkable against this table. `A1-connectives` is the one most at
risk: a sealed interface declares the proposition `A ∨ B`, while the exhaustive match is the
proof step that eliminates it — the slide must show both halves and name which is which, or it
collapses into "sum types are nice".

**D-C — NOT YET DECIDED. New leading candidate: (d) capability-led, motivated by residual failure.**

MB: *"Leading with capabilities that are motivated from things that can still go wrong sounds
like a good idea."* That is neither of the options as posed. Recorded as (d):

> Do not open a bridge with what the language cannot do (three consecutive complaints), nor with
> a new feature (a feature tour). Open with **what can still go wrong after everything the
> previous act bought you**, then present the capability that removes it.

This is the same organising principle as D-A(b) applied one level up, which is an argument in its
favour: the deck would use one shape at act level and at boundary level. **Decide after Act 4 is
built** — MB wants to see it in context, and Act 4's rework is what produces that context.

**D-D — my judgement, to be revised after the first rehearsal.**

- *Before the edit:* one sentence naming what to watch. "I'm going to delete the Medium case.
  Watch what the compiler does." Nothing else — the audience cannot read code and listen at once.
- *During:* silence. The typing is the beat; narrating over it splits attention.
- *After:* read the error aloud **verbatim**, then one sentence connecting it to the rule the act
  just established. Then undo, visibly.
- *Placement:* immediately after its setup slide and **before** the payoff slide, so the payoff
  lands on a fresh memory of the error rather than on a description of one.
- *Fallback:* **on the next slide, not hidden on the same one.** A fallback that must be revealed
  is a fallback you fumble under stress; a fallback on the following slide is recovered by the
  forward key you are already pressing, and it never shows when the demo works. This also means
  the captured output needs no reveal mechanism at all — it is just a slide.

**Acceptance for step 7:** D-A, D-B and D-D are decided above. D-C is deliberately deferred to
after Act 4 exists, with (d) as the working default. No further paragraph is owed before
authoring begins.

### The cut list — now contingency, not requirement

At the measured rate the talk fits with 4:10 spare, so these are held in reserve for the
Wednesday read-through rather than applied up front. Ordered by what costs the talk least:

Named, in order, against the v1-measured baseline rather than the estimates:

1. **`A3-gentzen` folded into `A3-stage3`** as an inline rule box — P2's fault was *distance*
   between rule and error, and a rule on the same slide fixes that as well as a rule sixty
   seconds earlier (−1:55)
2. **`A3-ceiling` and `A4-ceiling` capped at 1:00 each** — cube reveal plus one sentence, not a
   summary (−2:18)
3. **`A5-mltt` capped at 2:00** — show `assessOrder` and `protocolFromSnapshot`, drop the third
   example (−1:31)
4. **`A6-close` capped at 1:00** — it is one paragraph (−1:24)
5. **`A4-mechanisms` to 1:00**, effects aside to appendix A1 (−0:30)

≈ −7:38 against measured. The existing demo-narration cuts then close the remainder without
touching Demo 1 or Demo 4.

---

### Part 6b/T — authoring treatment: how much scripting each slide gets

**Verbatim burden stays at 9 slides** — Act 0's three and all six of Act 1.

| Act | Slides | Treatment | Why |
|---|---|---|---|
| 0 — Open | 3 | **full verbatim** ✅ done | stumble zone; cold open; no code to lean on; already rehearsed three times |
| 1 — Primer | 6 | **full verbatim**, plus bullet cues alongside | new and abstract, no code to lean on; the cues are a delivery aid for when the script is known and only the order is needed |
| 2 — Ground floor | 3 | cues + one scripted landing line each | conceptual but short |
| 3 — Java ladder | 8 | cues only | MB's own code and two live demos; a script over a live edit is worse than improvising |
| 4 — Scala 3 | 5 | cues only | same |
| 5 — Idris 2 | 3 | cues only | same |
| 6 — Close | 3 | cues + scripted landing line | the last sentence should be exact; the rest need not be |

**The format.** A verbatim slide carries the script *and* a cue layer, because they serve
different moments: the script is for writing and rehearsing, the cues are for the third run-through
when you know the words and only need the order.

- **BEATS** — the delivery order as bullets, with `›` sub-bullets marking phrases that must be
  exact. Fragments here use no double quotes, so `make timing` counts the script once rather
  than twice.
- **VERBATIM** — the full script, in double quotes. This is what the word counter and the prose
  linter read.
- **MUST LAND** — the one thing that has to survive if everything else is fumbled.
- **C13 CHECK** — the program/type/checker distinction, wherever the slide is at risk of it.
- **FACTS** — dates, citations, and every code identifier grepped from source.
- **EST-WORDS: n** — for cues-only slides in Acts 2–6, which have no full script to count. The
  author's declared estimate of how much will be said; `make timing` reads it in place of a word
  count. An inferred count from scattered fragments would be a fiction, and a declared estimate
  is at least an honest one.

### Part 6b/D — the four decisions, stated as questions

Part 6b named four *areas*. An area is not a decision, and "settle Act 4's sequence" is not
something you can finish by noon. These are the actual questions; each wants one paragraph.

---

**D-A · Act 4 — what organises the Scala act?**

Seven mechanisms arrive in roughly eight minutes: refined types, opaque types, path-dependent
types, match types, session duality, higher-kinded types, and the effects/capture aside. The
current shape is *opens → demo → session types → mechanisms → ceiling*, where `A4-mechanisms`
is a six-row table. **A table of six mechanisms is a feature tour**, which is the failure mode
this act has always had.

- **(a) Mechanism-led** — current. Name each mechanism, show it. Honest, complete, flat.
- **(b) Problem-led** — each mechanism introduced by the bug it kills, the way Act 3 does with
  Bob. Costs coverage: some mechanisms have no incident attached and would be dropped or named
  only.
- **(c) One thread** — take a single order through the whole Scala stage, and let each mechanism
  appear where that thread needs it. Strongest narrative, hardest to author, and it is the shape
  Danielle's protocol story already wants.

*What makes this the highest-cost decision:* it governs five slides, the act that has never fit
any budget, and whether Danielle's close lands as a payoff or as an item.

---

**D-B · Act 1 — chronological or conceptual?**

The six beats are currently ordered by date: Aristotle → Boole/Frege → Frege → Russell →
Curry-Howard → Martin-Löf/Coquand.

- **(a) Chronological** — current. The 2,400-year sweep is the point, and the rail reinforces it.
  Risk: Russell's crisis interrupts the connectives→quantifiers→correspondence build.
- **(b) Conceptual** — connectives, quantifiers, the correspondence, then the crisis as the
  reason types exist at all, then what lies above. Cleaner build; loses the sweep the rail sells.

Sub-questions that fall out of it: which Java mirror sits beside which beat, how much formalism
each carries, and whether the progress rail is a per-slide component or one strip that persists.

---

**D-C · The three bridges — what does a transition assert?**

`A3-ceiling` → Act 4, `A4-ceiling` → Act 5, and `A0-turn` → Act 1.

- **(a) Ceiling-first** — current. State what the language *cannot* reach, then move up. Risk:
  three consecutive "here is what is impossible" beats read as a complaint.
- **(b) Capability-first** — state what becomes newly *possible*, and let the ceiling be implied.
- **(c) Alternate** — ceiling at the Java boundary (where the audience lives and needs the limit
  made concrete), capability at the Scala boundary (where they need a reason to keep climbing).

*What makes this high-cost:* it decides whether the deck reads as one climb or as three talks
stapled together, and it is currently one sentence per boundary.

---

**D-D · Demo narration — what is said, and does the fallback show?**

Eight minutes across four slides, entirely unwritten and invisible to `make timing`.

- What each demo says *before* the edit (setting up what the audience should watch for), *during*
  (silence, or narration over typing), and *after* (reading the error aloud, or letting it sit).
- Placement inside the act: immediately after the setup slide, or after the payoff?
- **Does the captured fallback pane show by default, or only on failure?** Showing it always is
  safer and costs nothing on the night; showing it only on failure keeps the live moment live.
  This is a real trade and it is currently undecided.

---

---

## Part 6b/D2 — decisions taken (MB, 17 Aug)

**D-A — DECIDED: (c) one thread, falling back to (b) problem-led if it will not fit.**

Take a single order through the whole Scala stage and let each mechanism appear where that
thread needs it. If authoring proves too slow, drop to problem-led: each mechanism introduced by
the bug it kills. Both beat the mechanism table, which is the feature tour this act has always
been. Note the two are compatible — the thread *is* a sequence of problems — so starting on (c)
and degrading to (b) costs nothing already written.

**D-B — DECIDED: chronological stays. Two amendments.**

*i. Leibniz earns a place, but not a slide.* The case for a beat: he is the first person to say
that valid inference could be carried out **by a machine** — the *characteristica universalis*
and the *calculus ratiocinator*, "let us calculate" — and mechanical checkability is precisely
what makes this talk's thesis matter. A proof nobody checks is only a claim; the type checker is
the machine Leibniz wanted. He also gives a free hook for this audience in binary encoding.

The case against a beat: he produced no working system, the programme failed in his lifetime,
and Act 1 is already 7:10 across six beats — a seventh costs ~1:10 for an idea that fits in a
clause. **Resolution: Leibniz is named inside the Boole/Frege beat as the man who wanted the
machine, and he appears on the progress rail.** That is a place, at a cost of about fifteen
words rather than seventy seconds.

*ii. Proof-calculi and mechanical checkability get integrated properly*, which is the thing MB
identified as under-served. The fix is a redistribution across two existing beats rather than a
new one:

- **`A1-connectives`** now carries *logic becomes algebra, therefore mechanically manipulable* —
  Boole's algebra is the first time inference becomes symbol-pushing a machine could do, and
  Leibniz is named here as the one who wanted it.
- **`A1-crisis`** now carries *what mechanical checking can and cannot promise* — consistency and
  soundness as the requirements, Gödel as the proof that completeness is not available. This is
  where proof-calculi belong, and it makes `A2-promises` a cash-out rather than a fresh topic.

**D-B/iii — THE EQUIVOCATION TO AVOID (MB, and it is the sharpest point in this section).**

The talk must never blur **the logic *in* the program** with **the logic *about* the program**.

A Java developer who hears "you already write logic" will think of `if (a && b)` — boolean
conditions and control flow. That is *not* what Curry-Howard is about, and if the audience
settles on that reading, the whole primer lands as a triviality they already knew.

The correct statement, in MB's formulation:

> **A program is a construction; under Curry-Howard it *is* a proof. What we are proving is
> expressed by its type — and that holds even in languages with no written types, where the
> proposition is implicit and simply goes unchecked. The type also constrains how you may get
> from one construction to the next.**

So the three things must stay distinct and be *said* distinctly:

| | |
|---|---|
| the **program** | the construction — the proof term |
| the **type** | the proposition being proved |
| the **checker** | the machine that verifies the construction proves the proposition |

Every beat in Act 1 must be checkable against this table. `A1-connectives` is the one most at
risk: a sealed interface declares the proposition `A ∨ B`, while the exhaustive match is the
proof step that eliminates it — the slide must show both halves and name which is which, or it
collapses into "sum types are nice".

**D-C — NOT YET DECIDED. New leading candidate: (d) capability-led, motivated by residual failure.**

MB: *"Leading with capabilities that are motivated from things that can still go wrong sounds
like a good idea."* That is neither of the options as posed. Recorded as (d):

> Do not open a bridge with what the language cannot do (three consecutive complaints), nor with
> a new feature (a feature tour). Open with **what can still go wrong after everything the
> previous act bought you**, then present the capability that removes it.

This is the same organising principle as D-A(b) applied one level up, which is an argument in its
favour: the deck would use one shape at act level and at boundary level. **Decide after Act 4 is
built** — MB wants to see it in context, and Act 4's rework is what produces that context.

**D-D — my judgement, to be revised after the first rehearsal.**

- *Before the edit:* one sentence naming what to watch. "I'm going to delete the Medium case.
  Watch what the compiler does." Nothing else — the audience cannot read code and listen at once.
- *During:* silence. The typing is the beat; narrating over it splits attention.
- *After:* read the error aloud **verbatim**, then one sentence connecting it to the rule the act
  just established. Then undo, visibly.
- *Placement:* immediately after its setup slide and **before** the payoff slide, so the payoff
  lands on a fresh memory of the error rather than on a description of one.
- *Fallback:* **on the next slide, not hidden on the same one.** A fallback that must be revealed
  is a fallback you fumble under stress; a fallback on the following slide is recovered by the
  forward key you are already pressing, and it never shows when the demo works. This also means
  the captured output needs no reveal mechanism at all — it is just a slide.

**Acceptance for step 7:** D-A, D-B and D-D are decided above. D-C is deliberately deferred to
after Act 4 exists, with (d) as the working default. No further paragraph is owed before
authoring begins.

### The cut list — now contingency, not requirement

At the measured rate the talk fits with 4:10 spare, so these are held in reserve for the
Wednesday read-through rather than applied up front. Ordered by what costs the talk least:

Named, in order, against the v1-measured baseline rather than the estimates:

1. **`A3-gentzen` folded into `A3-stage3`** as an inline rule box — P2's fault was *distance*
   between rule and error, and a rule on the same slide fixes that as well as a rule sixty
   seconds earlier (−1:55)
2. **`A3-ceiling` and `A4-ceiling` capped at 1:00 each** — cube reveal plus one sentence, not a
   summary (−2:18)
3. **`A5-mltt` capped at 2:00** — show `assessOrder` and `protocolFromSnapshot`, drop the third
   example (−1:31)
4. **`A6-close` capped at 1:00** — it is one paragraph (−1:24)
5. **`A4-mechanisms` to 1:00**, effects aside to appendix A1 (−0:30)

≈ −7:38 against measured. The existing demo-narration cuts then close the remainder without
touching Demo 1 or Demo 4.

---

### Appendix to Part 6b — authoring treatment (unchanged, still useful)

Once a design is settled, this is how much scripting it needs:

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

Reordered after the independent review. Two principles: **make the instrument able to see the
plan before authoring anything**, and **settle the volatile designs (Part 6b) before writing
the prose that depends on them**. Draft 5 put the only feedback signal at step 11 of 11 while
its own budget section said it should come early.

**Act 0 is the only act ever written against an allocation, and it came in at 1.55×** — budgeted
3:30, needed 5:25. The rate risk is now measured away (see Part 3), but the *volume* risk is not:
if Act 1 behaves like Act 0, its 7:10 becomes ~11:00 and the 4:10 of slack disappears. Treat
every unwritten act's allocation as optimistic.

**Dates, because a hard deadline needs them.** Delivery Thu 20 Aug; today is Mon 17 Aug.

| # | Step | When | State |
|---|---|---|---|
| 1 | Stage 3 overflow fix; title metadata | — | ✅ done |
| 2 | Act 0 authored + signed off; scripts, linter, hook, calibration | Mon | ✅ done |
| 3 | Iron refinements in `05-scala3-payment` | Mon | ✅ done |
| 4 | Demo 3 fixed; four fallbacks captured to `demos/` | Mon | ✅ done |
| 5 | Mechanical sweep: complete `budget.tsv` incl. **demo + stub rows**; fix the id/number drift | Mon eve | ✅ done |
| 6 | Delivery-discount calibration — Act 0 standing: **3:45, i.e. 187 wpm** | Mon eve | ✅ done |
| 7 | **Settle the four OPEN×high-cost items on paper** (Part 6b) — one paragraph each, no slide work | Tue 09:00–12:00, **hard stop** | |
| 8 | Author Act 1 — **six slides**; build it, measure it, rework if it does not fit | Tue 12:00 – Wed 12:00 | |
| 9 | Author `A2-values`, `A2-promises`; the four claim fixes in Part 3 | Wed 12:00–15:00 | |
| 10 | Merges, cube parameterisation, **`deck.typ` reorder** | **optional** — only if step 11 comes in under 44:00. The reorder is no longer needed for measurement: `budget.tsv`'s stub rows already let `make timing` report the intended deck |
| 11 | **First real read-through** — Act 0 + Act 1 + whatever else is authored; apply Part 6b's cut list against measured numbers | Wed 16:00 | |
| 12 | `make all`; **dress rehearsal on the real laptop and projector** | Wed 19:00, **immovable** | |

**Why step 6 is not a read-through of the deck.** Acts 1–6 are still v1 notes that this plan
deletes, merges or rewrites; reading them aloud measures a deck we are removing, and `make
timing` already measures those exact words at the same rate without anyone speaking. The number
a read-through would produce is one we have.

What we do **not** have is the **live-delivery discount**. Every cap in `budget.tsv` is scaled
by the 130 wpm planning rate, which is MB's measured *reading* rate (177 and 185 on two
occasions) minus a 28% discount that is a guess. It is the least-supported number in the project
and it multiplies everything.

Measure it on Act 0, which is authored, signed off and already measured seated at 3:48: deliver
it **standing, projecting to the back of a room, with the slides advancing**. Five minutes.

| Live Act 0 | Implied discount | Planning rate | 47:05 becomes |
|---|---|---|---|
| ~4:10 | ~10% | 165 | ~37:00 — comfortable |
| ~4:45 | ~20% | 148 | ~41:30 — fits |
| ~5:25 | ~28% | 130 | 47:05 — the current assumption |
| ~6:15 | ~38% | 115 | ~53:00 — cut hard |

Then `make timing WPM=<measured>` re-scales the whole budget, and Tuesday's cut decisions are
made against a measured rate instead of an assumed one.

**Freeze.** Whatever is authored by **Wed 16:00** ships. Everything else keeps its v1 note.
That is a decision with a time on it, not a contingency — the appendix renumber is cut outright,
since nothing in the talk depends on appendix numbering and Q&A slides can be found by title.

**Acceptance criteria.** Per slide: builds, passes `prose-lint` if it carries a script, and is
within its `budget.tsv` cap at 130 wpm. Per act: the act total matches `make timing`, and every
claim about the code has been checked against the code. Whole deck: `make check` green, the
four demos rehearsed with their fallbacks visible, and a measured read-through under 45:00.

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
strip on `A0-incidents` now precedes them. Applies to every act: **name the frame, then fill it.**

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

`A0-turn` jumped from "more tests would not have helped" straight into the 2,500-year
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

### C13 — Never blur the logic *in* the program with the logic *about* it *(read for it)*

"You already write logic" is heard by a Java developer as `if (a && b)` — boolean conditions and
control flow. That reading makes the primer a triviality and loses the talk. Keep three things
distinct and say which is which:

| the **program** | the construction — the proof term |
| the **type** | the proposition being proved |
| the **checker** | the machine verifying that the construction proves the proposition |

The correct claim: *a program is a construction and, under Curry-Howard, a proof; its type
expresses what is being proved — which holds even in untyped languages, where the proposition is
implicit and unchecked; and the type constrains how you may get from one construction to the
next.*

Highest-risk slides: `A1-connectives` (a sealed interface declares `A ∨ B`; the exhaustive match
is the elimination — show both halves and name them, or it collapses into "sum types are nice"),
`A1-curry-howard`, and `A2-values`.

### C12 — Do not use derived numbers as identifiers *(read for it)*

The plan has been renumbered twice and both times left stale cross-references, because slide
numbers are simultaneously identifiers and positions — so any insertion silently invalidates
every reference downstream. The cut list still said ``A2-promises` Gentzen` after Gentzen became 13.
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

