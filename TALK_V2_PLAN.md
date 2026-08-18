# Talk v2 — Rework Plan (DRAFT 6)

Branch `talk-v2-rework`, off `talk-v1` (`93c8d95`).
**Delivery: Thursday 20 August 2026 — Java Meetup, Inspired Consulting GmbH, Köln.**
45 min + 15 min Q&A (up to 3 min borrowable).

## Status — 2026-08-18 (evening: Act 1 rebuilt, Part 12 added)

| | |
|---|---|
| **Act 0 (slides 1–3)** | **DONE and signed off**, plus Part 10's layout and wording corrections. Linter-clean |
| **Act 1 (6 slides)** | **REBUILT 18 Aug** after MB's review — `A1-connectives` and `A1-quantifiers` from scratch, four other slides corrected. Clean under the Part 12 rules. **Measures 8:47 against a 7:10 cap** |
| **Act 2 (3 slides)** | `A2-values` and `A2-promises` **built** — cues plus a scripted landing line, both inside their caps and swept for the Part 12 faults. `A2-scenario` is still the v1 `15-test-spine` note, 0:19 over |
| Acts 3–6 | not authored; v1 notes still in place and failing the linter in ~19 places (almost all `monotone`) |
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
1. ~~Act 1 authored~~ — **done.** Without it the talk has no primer, which is the whole point of v2.
2. ~~`A2-promises`~~ — **done.** `A6-cost` is the remaining slide carrying content v1 never had,
   and it is now the single highest-value unwritten thing in the deck.
3. Everything else keeps its v1 note and ships as-is. The v1 notes fail the prose linter in
   ~19 places, almost all `monotone`, but a linter failure is a register complaint, not a
   correctness one — those slides are deliverable if unpolished. **The exception is a claim
   that is false rather than flat** — Part 11 names the two.

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

**Dates, because a hard deadline needs them.** Delivery Thu 20 Aug. **Today is Tue 18 Aug**,
and steps 1–9 are done — the schedule below allotted Act 1 until Wed 12:00, so authoring is
roughly a day ahead of it. That buys the read-through (step 11) more room, not more scope.

| # | Step | When | State |
|---|---|---|---|
| 1 | Stage 3 overflow fix; title metadata | — | ✅ done |
| 2 | Act 0 authored + signed off; scripts, linter, hook, calibration | Mon | ✅ done |
| 3 | Iron refinements in `05-scala3-payment` | Mon | ✅ done |
| 4 | Demo 3 fixed; four fallbacks captured to `demos/` | Mon | ✅ done |
| 5 | Mechanical sweep: complete `budget.tsv` incl. **demo + stub rows**; fix the id/number drift | Mon eve | ✅ done |
| 6 | Delivery-discount calibration — Act 0 standing: **3:45, i.e. 187 wpm** | Mon eve | ✅ done |
| 7 | **Settle the four OPEN×high-cost items on paper** (Part 6b) — one paragraph each, no slide work | Tue 09:00–12:00, **hard stop** | ✅ done — D-A, D-B, D-D decided in Part 6b/D2; D-C deferred to after Act 4 with (d) as the working default |
| 8 | Author Act 1 — **six slides**; build it, measure it, rework if it does not fit | Tue 12:00 – Wed 12:00 | ✅ built · **measured 8:43 vs 7:10** · rework deferred to step 11, per MB |
| 8b | **Apply Part 10** — MB's review of Act 0/1 as built, 10/F first | Tue | ✅ done — see Part 10/G |
| 9 | Author `A2-values`, `A2-promises`; the claim fixes in Part 3 | Wed 12:00–15:00 | ✅ slides done (Part 10/H) · **two claim fixes still open**, both on the unauthored `A5-mltt` — see Part 11 |
| 10 | Merges, cube parameterisation, **`deck.typ` reorder** | **optional** — only if step 11 comes in under 44:00. The reorder is no longer needed for measurement: `budget.tsv`'s stub rows already let `make timing` report the intended deck | |
| 11 | **First real read-through** — Act 0 + Act 1 + Act 2 + whatever else is authored; apply Part 6b's cut list against measured numbers | Wed 16:00 | **next** |
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


### L20–L24 — from MB's rewrite of `07`, `08` and `09` (18 Aug)

**L20 — a concrete instance beats an abstract capability.** *"The result type is
computed from the argument"* is a capability and it is abstract. MB added: *a
vector that carries its own length in its type — concatenate three with four and
the type says seven*. The canonical dependent-types example, and the room has it
instantly. I had stated the power without ever letting anyone see it.

**L21 — take evidence from the audience's own language.** *"But in Java, you can
also write `A → B throws C`."* Checked exceptions are already a partial move
toward honest signatures — the thesis demonstrated from inside Java, before the
ladder starts. I had framed Java only as the deficient case, which is both less
true and less persuasive.

**L22 — when you name the repeated move of a talk, check it against every
stage.** Mine: *cutting the disjunction down*. That covers nullability,
exceptions and non-termination and nothing else. MB's: **making implicit things
explicit until our signatures tell the whole story** — which also covers
typestate, refinements, session types and linearity. The generalisation is the
difference between a slogan that fits one slide and one that fits the ladder.

**L23 — define, do not forbid.** Russell's repair was *forbid anything from
talking about things at its own level* — a prohibition the room takes on trust.
MB: define the level instead. **Every statement gets a level, one above whatever
it mentions; the bad sentence would have to sit one level above itself, so there
is nowhere to write it.** The impossibility is now something the audience derives
rather than accepts, and *nowhere to write it* prefigures `A5-payoff`'s
*Unrepresentable*.

**L24 — a speaker note is a delivery instrument, not a design document.** MB:
*"none of the slides have the kind of bullet point list of talking points I need
to fluently get through the talk … it's heaps of prose and lists of instructions
instead of talking points."* Correct, and `06-quantifiers` was the proof: its
script sat at line 172 of 188, behind rationale, corrections and citations.

Every script is now **TALKING POINTS → VERBATIM → PREPARATION**, in that order,
with the third under a rule and explicitly marked *not for the night*. Talking
points are short unquoted lines carrying no rationale, so `make timing` and the
linter ignore them and the presenter view opens on the thing to be delivered.

### L25 — a silent no-op is worse than an error *(process, not prose)*

I reported the `max` fix on `06-quantifiers` as applied. It was not. A
`str.replace` had missed on a line-break difference, returned the string
unchanged, and written it back; the word count moved for unrelated reasons, so
nothing looked wrong. **MB was told a correction had landed when the stale text
was still there, and would have found it on stage.**

The rule: **assert the match before writing, and grep the result after.** Any
edit reported as done must be verifiable by a command whose output is in the
transcript. This is now how every script edit in this project is made.

### L18 — no metaphor the talk has not issued

*"…the first thing we need at the top of the climb."* Two faults in nine words.
**The climb** appears in exactly one other spoken line, on `A1-curry-howard`,
which comes *two slides later*, and the opening announces no ascent at all —
`01-title` names Java and nothing else, so there is no Scala, no Idris and no
summit in the room's head at beat 3. And *the first thing we need* is a ranking
claim with nothing behind it: Stage 6 is led by Π, not Σ.

The forward reference only ever had one job (Part 10/E) — stop a listener
concluding Java has Σ-types — and *we come back to it* does that with no unearned
vocabulary at all.

**The rule: the climb, the top, the summit, the ladder, the stack — every one is
invisible until the deck has spent a sentence issuing it, and none of them has.**
Check any forward reference against what the audience has actually been told by
that slide, not against what the plan calls things.

### L19 — a formula is not explained until the function is named

*"For all T, if T can be compared, then a list of T gives you back a T."* MB:
this makes comparability sound like the thing that gets an element out of the
list. It is not wrong so much as meaningless — the sentence never says what the
function **does**.

Naming `max` fixes it and makes the beat much stronger, because the bound stops
being a technicality: **`max` cannot be written at all without it.** That is the
sharpest available demonstration that an unbounded `T` buys almost nothing, and
it was sitting one word away the whole time.

### L17 — a claim about the whole talk goes where the thesis is formed, not where an example turns up

MB asked for one thing to land early: **all programming already does logic —
conditionals, guards, control flow — and types do logic one level up, where it
specifies and constrains the program.** I put it on `A1-connectives`, beat 2 of
Act 1, as a clause inside a sentence about Boole's `+` and `×`:

> *Watch which level they land on in Java: one above the booleans you compute
> while the program runs, in the shape of the data itself.*

Four things wrong with that, and they are worth separating because only one is
about wording:

1. **It never said the first half.** The claim credits program logic as logic.
   Mine mentioned booleans only as the thing to be above.
2. **It was a disclaimer wearing a positive costume.** R1 again — the shape was
   *these are not those*, dressed up.
3. **Wrong slide.** MB: *"relatively late for such a general point to shape
   expectations of the talk."* A claim about what the whole talk is doing belongs
   where the thesis is formed, not where the first example appears.
4. **Wrong register.** *Watch which level they land on* is a stage direction.

**It now lives on `A0-turn`**, which is the right slide for three reasons: it is
where four war stories become the thesis; it is where the tests-versus-types
concession already sits, so a second sentence about what a type *is* belongs in
the same breath; and Bob's `if (risk != HIGH)` is **one slide old**, so the room
has just watched program-level logic be correct, compile, and be wrong anyway.

`A1-connectives` keeps the **demonstration** and drops the claim: *you know both
already, as `||` and `&&` over booleans — here they are over types.* That is C3
in its usual form: name the frame where the thesis is formed, fill it where the
code appears.

### L12–L16 — from MB's rewrite of `04-aristotle` and `05-connectives` (18 Aug)

He rewrote two scripts I had called finished. Both came out better; one came out
shorter. The patterns are worth more than the sentences.

**L12 — Set up a payoff; do not assert it.** Mine: *"OR became + and AND became
×, and those are still the names."* His: *"…and there's a mathematical reason for
that"* — then the counting delivers it thirty seconds later. I close loops in the
same sentence I open them, which leaves the audience nothing to do.

**L13 — Carry one concrete word through the act as a spine.** He took
*mechanically* from Aristotle's beat and made Boole's beat about *removing the
quotation marks from "mechanically checkable" and actually calculating*. I had two
separate correct statements; he had one word doing work twice. The spine now runs
Aristotle (checkable by hand) → Boole (calculable) → Hilbert (mechanically
checkable) → your compiler, and `A1-crisis` was edited to repeat the word rather
than paraphrase it. **Carry the word; do not announce that you are carrying it** —
an earlier version of that edit said *"that word again"*, which is R3.

**L14 — Do not leave a figure as a failure if the programme is alive.** Mine:
*"He never built it."* His: *"He never built it himself — but our current proof
calculi and recent developments in categorical logic are part of the same
endeavour."* This is not generosity, it is the talk's argument: the thesis is that
this lineage reaches the compiler in the room, and a dead end contradicts it. The
same fix was owed to Hilbert and has been applied — *that did not kill the
programme; it narrowed it into proof theory*.

**L15 — End a beat on what it buys later, not on a transition.** He appended
*"and that shape is what permits effective pattern matching"* to the
sum-of-products landing. Mine stopped at *most domain models are this shape*.

**L16 — Hedge primacy claims.** *"perhaps the first to truly devote himself"*. I
would have written *the first*. C2, in its historical form.

Cost of his two rewrites: `04-aristotle` **162 → 154** words (now at cap),
`05-connectives` **224 → 246**. The overage buys the *mechanically-checkable*
spine and the Leibniz-programme-is-alive point, which are the two best things in
the act. Two typos fixed on the way: *vbalidity*, and *better ways to down
shapes*.

---

## Part 10 — MB review of Act 0/1 as built (17 Aug) — **ALL APPLIED**

Recorded verbatim in substance before any were applied. Each is a defect in what
was on screen, not a plan change. **Every item below is now done**, 10/F first;
see Part 10/G for what each fix cost and the one thing it did not solve.

### Layout

**`A0-incidents`** — too much space between the headline and the first row; too
little for everything below it. In the left column, name and scenario tag are set
too close together. In the right column, the orange cost line and the grey
qualifier under it need more separation.

### Wording and claims

**`A0-turn`** — three problems:
1. *"A type constrains every call site"* is wrong. **Types do not have call
   sites**, and they are useful well beyond functions and methods. → **"A type
   constrains every use."**
2. `philosophy → logic → mathematics → your compiler` reads as a progression in
   which each supplants or improves on the last. **It is not one.** These are not
   successive refinements of one activity.
3. The arithmetic/algebraic turn is **not** what makes logic mechanically
   checkable — **Aristotle's insight already does that**, because a form can be
   checked by inspection. Numeric encoding and the algebraic treatment make it
   *numerically calculable*, which is a different and later thing, and that is
   where Leibniz and binary belong.

**`A1-aristotle`** — *"The content is gone. The argument survived."* is
overused-AI phrasing. Direction: **"Validity comes from shape. True premises →
true conclusions."**

**`A1-connectives`** —
1. Both code panes show a **disjunction at type level**: its declaration and its
   use. The left column pairs `∨` above and `∧` below, which makes the layout
   imply that the upper pane is the disjunction and the lower one the
   conjunction. It does not say that; the layout does.
2. The distinction between **program-level boolean logic** and **type-level
   sum/product construction** is still not sharp enough (this is C13 again, and
   it is the slide most at risk).
3. The code panes themselves are good and stay.

**`A1-quantifiers`** — the added value is not clear, because **the Aristotelian
syllogism on `A1-aristotle` already contains a universal quantification**. The
slide must say what quantification *adds* once you have the syllogism — explicit
binding, quantifying over an unbounded domain, and ∃ as a separate thing — rather
than presenting ∀ as new.

**`A1-crisis`** —
1. Headline *"The crisis, and where the word comes from"* is bad: **"the word" is
   an unintelligible forward reference** until the reader reaches "types".
2. It poses the set-of-all-sets question and then jumps to the repair **without
   naming the problem** — that the contradiction destroys naive set theory and
   with it the foundation being built for logic and proof theory.
3. *"What Hilbert wanted of a system"* arrives unmotivated. **Keep it**, but
   motivate it.
4. Consider opening with the **barber** — the barber who shaves everyone who does
   not shave themselves — above the set-theoretic form, as the intuitive version.

**`A1-curry-howard`** —
1. **Lambek should be a smaller, more general side note**, not a co-equal third.
2. The caveat currently implies **logic cannot capture imperative, impure
   programs. It can** — just not via STLC. Continuations and related machinery do
   exactly this. Rewrite so the limit is about *which calculus*, not about
   *whether it is possible*.

### Rail

Last element must read **"Martin-Löf (+)"** — quantitative type theory, session
types with duality and the rest are all beyond MLTT, and the bare name overstates
where the rail ends.

### Open strategic question — answer before Act 2

**Is introducing the programming meaning of each theoretical concept this early
right, before the ladder has been climbed?** Act 1 currently pairs every notation
with its Java mirror on the spot. The alternative is to keep Act 1 purely
conceptual and let each mirror appear at the stage where it pays off. MB is
unsure; this needs an explicit evaluation, because it governs all six Act 1
slides and the shape of every act after them.

### Part 10/E — the strategic question, ANSWERED

**Keep pairing each concept with its Java mirror in Act 1. Change nothing.**

*For pairing:* it is the thesis of v2. `A0-turn` promises that a good part of what
this room does already sits at the end of the thread. A purely conceptual Act 1
defers that promise by fifteen minutes, and a Java audience given six slides of
logic with no code decides by the third that the payoff is not coming.

*The real risk,* which is narrower than "too early": a mirror shown before the
ladder is climbed invites the room to think the mirror is the whole story. Show
`sealed interface` beside `∨` at minute eight and some of them conclude *fine,
sum types, I have those* — and the ascent has nothing left to sell.

*The fix that was proposed and REJECTED:* give every mirror an explicit "and here
is what it does not yet do". MB: too confusing, too much clutter. Correct — and
it also duplicates something the act already has.

**`A1-above` is the incompleteness beat.** Four notations Java cannot express,
delivered once, as a slide, with the promise that all four will be seen running.
The debt is already stated at act level; restating it five times at slide level
would clutter the slides that work in order to solve a solved problem.

The single local exception stays: `A1-quantifiers` names ∃ and deliberately gives
it no Java mirror. That one is load-bearing — without it, a listener joining that
slide to `A1-above` concludes Java has Σ-types.

### Part 10/F — two corrections that are errors, not preferences

Everything else in Part 10 is a clarity or layout fix. These two are wrong as
written and would ship wrong:

**F1 · `A1-connectives` misattributes mechanical checkability.** The script says of
Boole: *"that is the moment inference becomes something a machine could do"*. False.
**Aristotle's insight already makes inference mechanically checkable** — a form can
be checked by inspection, which is the sense that matters here. What Boole's algebra
and Leibniz's programme add is **numerical calculability**, a different and later
property. Fix the script and the slide so the arithmetic turn buys calculability,
not checkability, and Leibniz sits with binary on the calculable side.

**F2 · `A1-curry-howard`'s caveat overclaims.** As written it implies logic cannot
capture imperative, impure programs. **It can** — continuations, monadic
translation and effect calculi do exactly that. The honest limit is *which
calculus you are in*, not *whether it is possible*. Rewrite so the caveat says the
STLC correspondence does not cover Java's effects, and that richer calculi do,
which is also a better setup for the ladder. As it stands this is a Part 8/C2
overclaim sitting on the slide that carries the thesis.

### Part 10/G — what applying Part 10 changed, and what it cost

Applied in the order MB asked for: 10/F first, then the layout and wording items,
then Act 2's two new slides.

**10/F1 · `A1-connectives` — checkability vs calculability.** The script's claim
that Boole's algebra is *the moment inference becomes something a machine could
do* is gone. Aristotle's beat now carries mechanical checkability explicitly
(*a shape is also something you can check by looking at it*), and the algebra
buys calculation instead: *inference becomes arithmetic, carried out symbol by
symbol*. The slide's new top line states the distinction in one sentence, and
the headline — *Logic becomes something you can calculate* — was already right.
Leibniz sits on the calculable side, with binary.

**10/F2 · `A1-curry-howard` — the caveat no longer overclaims.** It said the
correspondence is exact for total, pure calculi and that Java is neither, which
reads as *logic cannot describe imperative programs*. The caveat now names the
real limit — which calculus you are standing in — and says so: there are calculi
for state, exceptions and control, and continuations answer to classical
reasoning; Java is outside *this* one. This is also a better setup for the
ladder, because every stage is a move toward a calculus that fits.

**The rest.** `A0-incidents` re-spaced (headline gap 44→8, name/tag 4→12, the
cost line and its grey qualifier are separate blocks now rather than a `\`
break). `A0-turn`: *every call site* → *every use*; the four fields lost their
arrows and gained the caption *one question, taken up in four places — none of
them finished with it*. `A1-aristotle`: MB's line, *validity comes from shape*.
`A1-connectives`: `∧` moved out from beside the lower pane into a strip under
both, the `∨` card now says in words that both panes are one connective, and a
line rules out the `if (a && b)` reading. `A1-quantifiers` rebuilt around the
concession MB raised — the syllogism already quantifies — so the slide shows
Aristotle's form beside Frege's and names the three things binding a variable
adds. `A1-crisis`: headline names the word, the barber opens it, the damage to
naive set theory is stated before the repair, and Hilbert's column leads with
the question it answers. Lambek is a faint side note and off the eyebrow. The
rail ends *Martin-Löf (+)*.

**What it cost, honestly (C10).** Act 1 measured 8:23 before this pass and 8:43
after — twenty seconds across six slides, spent almost entirely on `A1-crisis`
(the barber, the damage line, the Hilbert motivation) and `A1-curry-howard` (the
effects-are-not-beyond-logic correction). Both were content MB asked for. The
act is now **1:33 over its 7:10 cap**, and the two worst offenders are
`A1-curry-howard` at +0:31 and `A1-crisis` at +0:25. **Cut #5 — merging
`A1-connectives` and `A1-quantifiers` — remains the reserve, and the decision
still belongs after the read-through, not before it.**

**A bookkeeping correction that was hiding this.** Act 1's rows in
`budget.tsv` were still marked `stub` after the act was written, so `make timing`
printed the planned cap and never compared it to the script that existed. They
are `prose` now. The deck's measured prose went from 31:33 to 42:18 the moment
the tool could see six authored slides and two new ones — none of that is new
words, it is a number that was always true and was not being reported.

### Part 10/H — Act 2's two new slides, built

**`A2-values`** — value, reference, then the turn: a type is neither, it is the
compiler's reasoning about which values may flow where, and most of what it buys
is spent before the program runs. `Payment<Initiated>` and `Payment<Authorized>`
are the same bytes. Then the cheap/costly pair — phantom parameters carry no
data, opaque types are plain `String`s, multiplicities are erased, and what you
erase you cannot ask about later. **The two points Part 3 says must not be
conflated are both carried:** the argument does not rest on erasure (erasure is
why it is cheap, not why it is good), and the Stage 6 exception is flagged in a
footnote so the Idris payoff is not spent here. Gradual typing stays on
`A6-cost`. 118 words against a 0:50 cap.

**`A2-promises`** — Hilbert's three read off against the compiler in the room,
with completeness marked *deliberately given up*. Rice and decidability, named as
such and explicitly not Gödel. Soundness bounded by the hatches, with Java's own
covariant-array hole as the evidence. The landing line concedes what MB insisted
on — you do not feel the missing completeness on a normal Tuesday, because when
the compiler says no it is usually right — and hands the cost question to
`A6-cost`. 150 words against a 1:05 cap.

Both are cues plus one scripted landing line, per Part 6b/T, so both declare
`EST-WORDS` rather than carrying a countable script.

**Two small tooling changes fell out of this.** `code-pane` gained a `pad-y`
parameter (default unchanged) because `A1-connectives` carries two panes and a
caption strip and the default chrome pushed it off the page. And the prose-lint
hook no longer lints `scripts/README.md`: that file documents the banned
constructions by quoting them, so it fails every rule it describes and was
blocking edits to the one file that explains the rules.

**Still open in Act 2:** `A2-scenario` is the v1 `15-test-spine` note, 0:19 over
a 0:25 cap and still carrying the nine-row table Part 2 sends to the appendix.

---

## Part 11 — Remaining work, ordered

State at this commit: Acts 0, 1 and two thirds of Act 2 are authored and
linter-clean; Part 10 is fully applied. `make check` builds, and `make timing`
reports **42:18 of measured prose against 40:50 of caps** inside a 45:00 slot.
Everything below is what is left, in the order it pays.

### A — Two claims on screen that are false, not merely flat

These are the only *correctness* defects known to be in the deck. Both sit on
`A5-mltt`'s source slides, which are unauthored, so they are cheap to fix while
authoring and expensive to ship. Verified against the code, not from memory (C1):

| Where | On the slide | In the code |
|---|---|---|
| `29-mltt-running.typ:42` | `protocolFromSnapshot : RiskSnapshot -> SessionType` | `(snap : RiskSnapshot) -> (n : Nat) -> (c : Currency) -> SessionType` — `PaymentRules.idr:212-214` |
| `29-mltt-running.typ:59` | `assessOrder : Order n c -> (lvl ** Assessment lvl n c)` | `(lvl : RiskLevel ** Assessment lvl n c)` — `PaymentDomain.idr:255` |

The first is self-contradicting: line 47 of the same slide already calls
`protocolFromSnapshot snapshot n c` with three arguments. The second drops
`: RiskLevel`, which is legal sugar that hides the index type — and the index
type is the entire point of the slide.

### B — The read-through (Part 7 step 11). This is the next thing to do.

Nothing else should be authored before it. Act 1 measures **8:43 against 7:10**;
five v1 slides are worse. The cut list in Part 6b is contingency and the
`A1-connectives` + `A1-quantifiers` merge is the primer-side reserve — both are
decisions to take against measured numbers, which is why they were not taken here.

### C — Unwritten, in the order they pay

1. **`A6-cost`** — the last slide carrying content v1 never had, and the one the
   whole ladder argues toward. It also absorbs the gradual-typing material moved
   off `A2-values`.
2. **Demo narration** — four slides, **9:15, 20% of the slot, invisible to
   `make timing`**. D-D settled the shape (one sentence before, silence during,
   the error read verbatim after, fallback on the *next* slide); not one word of
   it is written, and the four fallback slides do not exist.
3. **`A2-scenario`** — still the v1 `15-test-spine` note, +0:19 over a 0:25 cap,
   still carrying the nine-row table Part 2 sends to the appendix.
4. **Acts 3–5** — cues over v1 notes, per Part 6b/T. Deliverable unpolished.

### D — A structural gap the include list is hiding

Seven slide files were dropped from `deck.typ` when Act 1 landed and are in
neither the main deck nor the appendix:

`09-convergence1` · `11-convergence2` · `13-convergence3` · `12-mltt` ·
`14-lambda-cube` · `16-stage0` · **`10-gentzen-or`**

Six of those are the history slides Act 1 absorbs, and Part 4 promises them an
appendix home (A4–A8) that they do not currently have. That is a decision to
confirm, not a bug.

**`10-gentzen-or` is different and is a live gap.** Part 3 lists it as `A3-gentzen`
— *KEEP, moved here* — it is the structural fix for P2, it still has a `prose`
row in `budget.tsv`, and `make timing` prints it as "not written yet" because it
is not in the deck. The file exists and is written. **Act 3's rework has to put
the `#include` back**, or the rule that explains Demo 1's compile error is not in
the talk at all.

### E — Deferred by decision, not by omission

- **D-C, the three bridges.** Decide after Act 4 exists, (d) capability-led
  motivated by residual failure as the working default (Part 6b/D2).
- **Cube parameterisation and the three reveals** (Part 2, Device 2). Not built;
  `lambda-cube-canvas` is still the fixed unparameterised value and no slide
  calls it. Part 7 step 10 marks this optional.
- **`deck.typ` reorder** — optional; `budget.tsv` already lets `make timing`
  report the intended deck.

### F — Component work still budgeted nowhere (Part 6b's own warning)

The Act 1 progress rail is built and documented. Still outstanding: **Device 1's
payoff layout**, the **first use of `code-pane(diagnostic:)`** — no slide uses it
yet, and the four captured fallbacks in `demos/` have nowhere to render — and the
**cube parameterisation** above.

---

## Part 12 — Register faults the linter could not see (MB review, 18 Aug)

Part 9 came from comparing my Act 0 draft against what MB shipped. This part
comes from something worse: a review of Act 0/1 *after* Part 10 had been applied,
in which four separate lines were identified as the worst kind of machine
phrasing. All four were written by me in one pass, all four passed the linter,
and one of them was a "fix" for a problem MB had raised the day before.

The four:

| shipped | fault |
|---|---|
| *one question, taken up in four places — none of them finished with it* | balanced clauses, no content in either half |
| *None of this is `if (a && b)` — a boolean is computed while the program runs; these shapes are fixed before it runs at all* | defining by exclusion; a disclaimer standing in for a design |
| *You write the universal already — and the signature is the claim, the body is what makes good on it* | aphorism; MB: "almost devoid of useful information" |
| *Four notations, and I am deliberately not going to teach them* | the talk narrating itself |

### The five rules that generate all four

**R1 — Define positively. Never by exclusion.** *None of this is X* makes the
audience hold X in mind while you deny it, and it is the shape of a disclaimer
rather than a claim. If the wrong reading is available, the fix is to change the
slide until it is not, which is what happened to `A1-connectives`.

**R2 — No sentence may exist to explain another element of the same slide.**
*Both panes are this one connective* was a caption apologising for a layout. A
slide that needs a sentence to explain its own arrangement has the wrong
arrangement, and adding the sentence hides the defect instead of fixing it.

**R3 — The talk does not narrate itself.** No announcing what a slide will not
cover, no *that is the map for the next half hour*, no *the point of this beat
is*. Delete the sentence and check what information was lost. Usually none.

**R4 — Balanced clauses are suspect on sight.** *The X is the claim, the Y is
what makes good on it.* The shape of an insight is not an insight. Test: could
someone act differently having heard it? If not, it is decoration.

**R5 — Enumerate-then-declare is a tell.** *[n] X — [declaration]* or *[n] X,
[declaration]*: **Four notations, all of which you will see running later** ·
**One honest caveat, and it is the reason this talk has stages** · **Two more
pieces and this closes**. The sentence announces a count and then comments on the
count, which is airtime spent on bookkeeping. Say what the things are, or lead
with what they buy. The audience can count.

**R6 — A headline names a concept.** It is a label on a section of the argument,
not a line of speech. *You have already seen a quantifier* is something you say;
in 60pt it spends the biggest text on the slide on nothing anyone can carry away.

**R8 — Introduce before use; and the room is mixed, so a term standard for
*part* of it still needs introducing.** (MB, 18 Aug, on *a bound* and then on
*phantom type*.) C5 said "do not add jargon the room does not share", which is
too blunt in both directions. The talk **may and should** use technical terms
where they are the subject — *phantom type* is the right word at `A3-stage4`,
which names it and glosses it in the same breath, and the audience wants the name
so they can go and read about it afterwards. Two things make a term a fault:

1. **Using it before the beat that teaches it.** *Phantom parameters* on
   `A2-values` was wrong because Stage 4 introduces the idea two acts later —
   that is C3, name the frame then fill it, not a vocabulary problem.
2. **Using it in passing, where teaching it costs more than the name earns.**
   *A bound* on `A1-quantifiers` is the case: `<T extends Comparable<T>>` is
   ordinary Java, a good part of a meetup audience still will not place the noun,
   and it arrives mid-sentence beside *universal quantification*, so two
   unfamiliar things have to be resolved at once. There is no beat here that
   teaches bounded quantification and no budget to add one, so **show the code
   they can read, say what it does, and leave the name out.**

The test is therefore not *is this jargon* but **has this talk earned the word by
this point, and is this the beat that should earn it.** Where the answer is no
and the term is only passing through, five instances in Acts 0–2 were replaced:

| was | now |
|---|---|
| *an unbounded `T`* · *a bound* | *it can only pass a `T` around and never call anything on it — which is why in practice you write `<T extends Comparable<T>>`* |
| *no well-typed program can inhabit an impossible type* | *…can produce a value of an impossible type* |
| *loops that never return and so inhabit anything at all* | *loops that never return, which type-check as anything you like* |
| *phantom parameters carry no data* (two acts before Stage 4 names them) | *a type parameter like the `<Initiated>` above carries no data at all* |

Plus *multiplicities* → *use-once markers* (the phrase `A1-above` already used),
and Russell's *a predicate may not apply to things at its own level* → *nothing
may talk about things on its own level*.

### And one that is about structure rather than words

**R7 — Lead with the capability or the problem, then the notation, then the
code.** `A1-quantifiers` failed because it led with notation, bolted a Java
mirror on, and never said why any of it mattered — so the first question a
competent listener asks is *why are you telling me this*. Every Act 1 beat has to
survive that question asked at its opening line, not at its close.

### What is now mechanical

`tools/prose-lint.py` gained four rule families the day these were found, and
they catch all four examples above plus two more I had not noticed:

| rule | catches |
|---|---|
| `negative-definition` | *none of this is…*, *X is neither…*, leading *that is not…* |
| `meta-commentary` | *I am not going to…*, *the slide is…*, *that is the point of…* |
| `aphorism` | *the X is the Y and the Z is the W*, *makes good on it*, trailing summary clauses |
| `title-is-a-sentence` | a headline opening with You / We / I / Here / Now / So |
| `enumerate-then-declare` | *[n] X, [remark about the count]* — caught all three instances in the deck, no false positives across Acts 3–6 |
| `jargon` (extended) | `unbounded`, `inhabit`, `phantom type`, `multiplicity`, `parametricity`, `stratify` added to the existing list. Acts 0–2 are clean; the remaining hits are all in Acts 3–6, which do throw these at the room and are now on the backlog for it |

### One claim that had to be weakened at the same time

**Unbounded generics are barely useful, and `A1-quantifiers` has to admit it**
(MB, 18 Aug). `∀T. T → T` has one inhabitant; `∀T` in general lets you carry a
`T` around and do nothing else to it. Saying a generic *proves something for
every type* without that qualification is a C2 overclaim, and the people most
likely to catch it are the ones the primer needs. The honest framing costs one
clause and is now on the slide: **the body's inability to inspect `T` is both the
payoff and the limit** — it is what makes one implementation cover every `T`, and
it is why an unbounded `T` can only be carried around. A bound is where you buy
back the ability to act on it, and a bound is the quantifier's domain written in
Java. Depth (parametricity, System F-sub, the line to Act 4's refinements) is in
the script's Q&A block and gets **no airtime**.

**The honest limit: a linter encodes faults it has already seen.** It cannot
catch the next shape, only this one. R1–R6 above are the part that has to be
checked by reading, and the reading has to happen before the slide is built, not
after MB sees it.

### R9 — an example that cannot be counted cannot demonstrate counting

`A1-connectives` showed the real `OrderLine(String sku, int unitPriceCents, int
quantity)` as its product. Verbatim from the repo, and useless: `String` is
unbounded, so the caption could only say *as many as sku × price × quantity* —
asserting the arithmetic rather than performing it, on the one slide whose whole
job is that you can count the values. MB: *"it really obscures something."*

The replacement is `record RefundRule(RiskDecision risk, RefundMechanism how)` —
3 × 2 = 6, both field types real, both numbers verifiable on screen (RiskDecision's
three variants are in the pane beside it; RefundMechanism's two are named
underneath). Only the wrapper is illustrative, and it is rendered as a plain
card — **no filename tab, no line numbers, no syntax colour** — so nothing on the
slide claims it is a file.

**The general rule: verbatim-from-source is a means, not the end.** Part 6b's
trap is presenting invented identifiers *as repository code*; it is not a ban on
ever drawing a shape. When a real example cannot carry the point, the honest move
is an illustrative one that is visibly illustrative — not a real one that
quietly fails.

### Standing state of the rest of the deck under these rules

Acts 0, 1 and 2 are clean. Everything from `A3-stage12` onward is still v1 prose
and fails as follows — this is the rework backlog, not a list of bugs:

| rule | count | where |
|---|---|---|
| `monotone` / `monotone-overall` | 19 | spread across Acts 3–6 and the appendix |
| `em-dash-density` | 17 | warnings; dashes used for drama |
| `long-sentence` | 15 | warnings; delivery risk, not register |
| `tricolon`, `rhetorical-qa`, `kicker`, `fragment-climax` | 4 | one each |
| `superlative`, `jargon`, `overclaim`, `ai-diction` | 5 | warnings |

Zero hits for the four new families outside Acts 0–2, which is expected: those
are *my* faults, and Acts 3–6 are still MB's v1 prose.

---

## Part 13 — External adversarial review, 18 Aug: disposition

Fifteen findings against Acts 0–2, in `ADVERSARIAL_REVIEW_ACTS_0_2.md`. **Eleven
accepted, two accepted with a different fix than proposed, one deferred, one
escalated to MB.** Every factual claim in the review was re-verified against
source before being acted on; all of them held.

| ID | Sev | Verdict | What was done |
|---|---|---|---|
| F-01 | MAJOR | **rejected; resolved the other way** | The premise was wrong. `A0-title` needs no hedging; the *caveat* was the defective half — see Part 13/A |
| F-02 | MAJOR | accepted, own fix | Code was 15 px on a 1080-px slide. Now **21 px** |
| F-03 | BLOCKER | accepted | Java wildcards *are* restricted existentials |
| F-04 | MAJOR | accepted | An unbounded `T` still has `Object`'s methods |
| F-05 | BLOCKER | accepted | Hilbert's third was decidability, not soundness; Gödel needs his hypotheses |
| F-06 | MAJOR | accepted, own fix | Trimmed by tightening, not by the proposed cuts — see below |
| F-07 | MAJOR | accepted | Agda is MLTT-based, Idris 2 is QTT-based; they do not share CoC |
| F-08 | MAJOR | **deferred** | The join is real; its fix couples to v1 text that `A2-scenario`'s rework deletes |
| F-09 | BLOCKER | accepted | `==`/`.equals`/`record` were all three wrong |
| F-10 | MAJOR | accepted | "The compiler's reasoning" merged type and checker — C13, on a C13 slide |
| F-11 | MAJOR | accepted | The landing line erased the Stage 6 exception the same slide had just made |
| F-12 | BLOCKER | accepted, narrowed | Precision fix, not the proposed table rewrite — see below |
| F-13 | BLOCKER | accepted, reframed | Array covariance is an unsound *rule*, and the exception is the enforcement |
| F-14 | MAJOR | accepted | 17 px → **23 px** |
| F-15 | MINOR | accepted + guarded | Headers synced, and `make timing` now fails loudly on the next drift |

### The three where the diagnosis was right and the proposed fix was not

**F-01 — the review found a real inconsistency and blamed the wrong half.**
Its premise is that the opening overclaims. It does not. MB's counter-question
settles it, and the answer is worth writing down because it improves the talk:

> Do impure, procedural languages like Java construct proofs in a precise sense,
> of weaker propositions and with more convoluted machinery?

**Yes, and precisely.** Under the standard monadic reading of an impure language,
a method written `A → B` really has type `A → T(B)`, with `T` carrying
nullability, thrown exceptions and non-termination. It therefore constructs a
proof of `A ⇒ (B ∨ null ∨ throw ∨ ⊥)`. That is a real proposition and a real
construction. It is simply weak — and, because `⊥` inhabits it, nearly free.

So the opening is exact as written. What was wrong was the caveat, which said *a
Java method from A to B does not prove that A implies B* — phrasing that sounds
like no proof occurs, and which is what put the two slides in apparent conflict.
The caveat is now a positive claim about **which proposition**, and the ladder
becomes one repeated move: cut the disjunction down until the arrow means what it
says. Stage 6's totality checker is what finally deletes `⊥`.

**Two precisifications, so the claim survives a specialist.** Java's `try`/`catch`
is upward-only and one-shot, so it is monadic (`A + E`) and stays intuitionistic —
the `call/cc` ↔ Peirce's law result (Griffin 1990) is about *first-class*
continuations, which Java does not have, so "in the limit" carries that clause.
And with unrestricted recursion the naive reading is outright inconsistent, so
the honest word is *nearly free* rather than *weak*.

**Net: slide 1 keeps its full strength, the caveat gets stronger, and the tension
the review found is gone.** Recorded here because it is the sharpest improvement
to the argument since the primer was built, and it came from MB.

**F-06 — the time problem is real; the proposed cuts are not available.** The
review wanted 84 words gone: Church/Turing, Lambek, and the effects paragraph.
Lambek is named in Part 1 as the central fascination and MB has already ruled on
him once (smaller, not gone). The effects paragraph *is* Part 10/F2, which MB
required two days ago. Church is lit on the rail. Trimmed by tightening instead;
the slide is still +0:28 and that is a read-through decision, not a silent cut.

**F-12 — accepted the precision point, rejected the table rewrite.** The review
is right that "complete" never said *complete with respect to what*, and that the
Rice paragraph slid from the typing judgment to all semantic safety. Both fixed
in place: the checker decides its own rules exactly, and the undecidable thing is
the property you wanted. The proposed replacement table (typing judgment /
encoded guarantee / semantic safety) would lose the Hilbert callback, which is
the only reason this slide exists.

**F-13 — accepted and reframed into a better beat.** The review is right that
Java is not failing here: the store check is the enforcement. But the static
subtyping rule *is* unsound, and the interesting fact is who pays — the JVM
checks every store into a reference array, in all your code, for ever, because
one rule was left unsound. That is the talk's whole thesis in miniature, so the
example earns its place more strongly than it did as "a hole".

### Open questions carried to MB

1. ~~**F-01.**~~ **Closed** — see Part 13/A. Slide 1 stands as written.
2. **Act 1 is 1:36 over.** Recover it from the `A1-connectives` +
   `A1-quantifiers` merge held in reserve, or from per-slide trims at the
   read-through? Unchanged from Part 11/B — decide against measured numbers.

---

## Part 14 — Lessons from the 18 Aug review of Acts 1–2

Part 12 holds the register rules; these are about claims, examples and slide
construction. Each is a defect MB found in work I had called finished.

### L26 — a claimed common thread must be checked against every instance

The caveat on `A1-curry-howard` closed with *"Every stage from here deletes one of
those alternatives"* — the alternatives being `null`, `throws C` and `never`. MB:
*"is that even true? Don't we do much more in the breadth of type-level features
we talk about?"*

It is not true. Checked against the ladder:

| stage | what it moves into the type | deletes null / throws / never? |
|---|---|---|
| 1 · simple types, smart constructors | which values can exist at all | no |
| 2 · generics | one claim over many types | no |
| 3 · sealed + records | a closed set of alternatives; `Result` makes failure explicit | partly — `Result` replaces two of them |
| 4 · phantom typestate | which operation is legal in which state | no |
| 5 · refinements, session types | a predicate; a protocol; types computed from types | no |
| 6 · dependent types, QTT, totality | a type that depends on a value; use-exactly-once; termination | `never`, via the totality checker |

Two of six touch that disjunction. **The real common thread is MB's own, from his
`08` rewrite: each stage takes something the code only *promises* and makes the
type *state* it** — a rule that lived in a comment, a test, a code review or
nobody's head moves to where the compiler enforces it. That covers all six, and
it is continuous with `A0-turn`'s *a test is a case somebody has to think of and
keep correct*.

**The rule: before writing "every stage does X", write the stages out and check.**
A through-line is the most load-bearing sentence in a talk and the easiest to
assert without testing.

### R10 — a slide arguing for precision cannot carry an imprecise example

`A1-quantifiers` had `max : List<T> → T`. The empty list has no maximum, so the
signature is false; the honest forms are `List<T> → Optional<T>`, a non-empty
list, or a nullable return. On the slide whose whole subject is what a type
promises, that is the worst possible place for it. Replaced with `max : T × T →
T`, which is total, needs no `Optional` to explain, keeps the bound load-bearing,
and reuses the `×` from two beats earlier. **Compiled before it went on.**

### R11 — if the content is a comparison, show the comparison

The caveat block was eighty-five words of prose *describing* the gap between what
a signature claims and what Java delivers. MB: put the two side by side. It is
now two lines and one sentence:

```
A → B                                 the proposition your signature claims
A → ( B | null ) throws C | never     the one Java can actually keep
```

Generalises: a slide that spends a paragraph describing a structure should
usually be showing the structure. Prose is for the things that are not visual.

### R13 — slide copy is read, and it reads as machine-written too

*"Neither stage touched Bob. The risk level is a proper type. Nothing forces you
to handle all of it."* — three short declaratives, on the wall, in 25pt. MB found
it; no rule could, because **the linter had only ever read the spoken script.**
Slide copy has carried the same faults all along and nothing was looking.

`tools/prose-lint.py` now extracts slide prose from the Typst source and runs the
claim rules and the monotone rule over it, warning-only because the extraction is
approximate, and with one extra sentence of rope since a four-item labelled list
is ordinary slide structure and the extractor cannot tell a list from a
paragraph. It found four more instances on the first run, all in unauthored
slides.

The line is now one sentence with subordination: *Bob's bug survives both stages
— the risk level has a type of its own by now, and still nothing makes you handle
every case.*

### R14 — no double quotes in TALKING POINTS

`10-scenario` opened with `"12" + "34" is "1234"` in its talking-point list.
Double quotes delimit **spoken text**, so the word counter scored those three
fragments as speech and the linter read them as the opening of the script — which
is how a `monotone` error appeared on a paragraph that did not have one. Talking
points, cues and prep notes use backticks or plain words. Checked across all
twelve scripts; that was the only one.

### R15 — a retraction is not finished until the phrase is gone from every file

Three times now, a correction was applied to a script, reported as done, and left
standing on the slide — most recently the closing line of `A3-ceiling`, where the
script said one thing and the wall said the retracted one. MB caught all three.
The failure is not carelessness about wording; it is that I verify the file I
edited instead of searching the deck.

`tools/retired.tsv` now lists every phrase that has been retracted, with the
reason, and `prose-lint` **fails** if any of them reappears in a slide or in the
spoken half of a script. PREPARATION blocks are exempt, because they quote
retired wording on purpose to record what was wrong with it.

It earned its keep on the first run: it found a stale `//` comment on
`A3-ceiling` still asserting *Java CAN encode all three*, the position that slide
had just abandoned.

**The habit the tool encodes: after retracting anything, grep the repository for
it, not the file you were looking at.**

### R12 — execute the plan's own decisions, or delete them

`15-test-spine` sat in the main deck for eight drafts with the nine-row inventory
and its `CLOSES` column, which Part 2 had removed and P5 had diagnosed by name.
Nobody was checking the deck against the plan. `make timing` reports slides that
are over budget; nothing reported slides the plan says should not be there.


---

## Part 15 — STATE OF PLAY · 18 Aug, end of session 3 · READ FIRST

**Delivery: Thursday 20 August.**

### The deck is written

**All 30 main beats carry a finished three-part script.** Acts 0 through 6 are
authored and lint-clean; the four demos are captured from the real compilers.

| act | beats | state |
|---|---|---|
| 0 — Open | 3 | done · reviewed and amended by MB · **measured** |
| 1 — Primer | 6 | done · reviewed twice · **measured** |
| 2 — Ground floor | 2 | done (`a2-values` cut) · **measured** |
| 3 — Java ladder | 8 beats / 12 files | done |
| 4 — Scala 3 | 5 beats / 7 files | **done** |
| 5 — Idris 2 | 3 beats / 5 files | **done, this session** |
| 6 — Close | 3 | **done, this session** |

`make timing`: **40:07 of prose against 40:45 of caps**, in a 45:00 slot. Nothing
is unwritten. **Every slide from `A3-stage12` onward is at or under its cap**;
the only overruns left are Act 0 and Act 1, which MB has read standing and which
Part 13's open question 2 leaves to the read-through.

### Where the four notations from `A1-above` get paid off

`A1-above` puts four rows on the wall at minute nine with their real code, and
promises *you will walk out knowing what each one buys, having watched all four
run on the payment flow*. That promise is now the spine of Acts 4 and 5:

| row | promised as | paid off at |
|---|---|---|
| ⇄ `Send[Order, Receive[RiskSnapshot, …]]` | a whole conversation, as one type | `A4-sessions` |
| Π `Approval : RiskLevel -> Type` | a type indexed by a runtime value | `A5-mltt` |
| Σ `(lvl : RiskLevel ** Assessment lvl n c)` | a value paired with a proof about it | `A5-mltt` |
| 1 `(1 _ : Session p) -> …` | a binding used exactly once | `A5-mltt`, fired by Demo 4 |

`A4-ceiling`'s two remaining limits are Π and 1 stated as absences, so the act
boundary is the promise and the payoff meeting. Each callback costs one clause
and no slide narrates the structure.

### Acts 4, 5 and 6 as built

| id | file | cap | does |
|---|---|---|---|
| `A4-opens` | `25-stage5` | 1:20 | `Approval[R]`, and `:| MinLength[1]` with `firstLine` total |
| `A4-demo3` | `a4-demo3` ×3 | 1:55 | `ThreeDSApproved(proof)` → `AutoApproved`, live |
| `A4-sessions` | `26-session-types` | 1:30 | `Dual[P]` as a match type · **Danielle** |
| `A4-mechanisms` | `stage5-mechanisms` | 1:20 | names what ran, then ZIO / capture checking |
| `A4-ceiling` | `27-stage5-payoff` | 1:20 | the payoff, then the two limits Act 5 removes |
| `A5-mltt` | `28-stage6-bridge` | 1:45 | `protocolFromSnapshot` → `openSession`; Σ; the `1` |
| `A5-demo4` | `a5-demo4` ×3 | 2:10 | `finish done` → `pure ()`, live |
| `A5-payoff` | `30-stage6-payoff` | 0:50 | the dark *Unrepresentable* slide, unchanged |
| `A6-cost` | `32-agentic` | 1:45 | what each stage costs · erasure · the agentic shift |
| `A6-monday` | `where-to-start` | 0:55 | the ladder, framed by gradual typing |
| `A6-close` | `34-close` | 0:50 | the thesis from `A0-title`, returned |

**`openSession : (p : SessionType) -> L1 IO (LPair (Session p) (Session (dual p)))`**
(`PaymentChannel.idr:73`) is the best single line in the repositories for this
talk: the return type is indexed by the argument *value*, and both ends come out
of one expression. It is the centre of `A5-mltt`.

### Deviations from Part 3, all deliberate and all reversible

1. **Gradual typing moved from `A6-cost` to `A6-monday`.** That slide *is* the
   incremental ladder, so the point is its frame rather than a twenty-second
   aside. In the room's own terms, which was Part 3's own instruction.
2. **The landing line is positive.** *The question was never "should I use
   dependent types for my CRUD endpoints"* is R1, and v1 had the same shape on
   `33-horizon`. The positive half loses nothing.
3. **No incident tally on `A4-ceiling`.** `A3-ceiling` says *two of the four* and
   Alice's closed silently at Stage 1, so a count would relitigate Act 3's
   bookkeeping on stage. The collective view stays where it was decided: once, on
   `A5-payoff`.
4. **Act 5's header cap corrected 5:30 → 4:45** to match its rows, which is what
   the act needed once `29-mltt-running` was merged in. **Act 6's rows corrected
   3:00 → 3:30** to match *its* header and Part 3; they were never updated when
   `A6-cost` was specified as a new slide. Deck caps 40:15 → 40:45.

### Three pre-existing defects fixed on the way

- **`talk.pdfpc` had been 0 bytes.** `touying compile --format pdfpc` runs its
  own `typst query` without `--root`, so it fails *access denied* on every slide
  that `#read()`s above `touying/` — all nine recorded demo frames. `make check`
  still printed *build OK* because the file existed. The `Makefile` now uses the
  `typst query --root .` invocation `deck.typ` documented all along. **This is
  the presenter view pympress reads from on the night.**
- **`25-stage5`'s pane was not repository code** — `order.id`, `p.id`, `a.id`,
  `audit =` are all invented; the real fields are `order.orderId.orderIdStr`,
  `p.challengeId`, `a.reviewer`, `auditTrail`.
- **Deck hygiene the plan decided and nobody executed** (R12): `scala3-ceiling`,
  `29-mltt-running` and `33-horizon` are deleted, `31-the-climb` is in the
  appendix. `budget.tsv` had listed all four as merged or cut for days.

### Demos — all four captured from the real compilers

`tools/capture-terminal.sh` now has a `frame3` for `sbt` and a `frame4` for
`idris2` beside the two `javac` frames, so every demo has an `-edit` and a
`-term` frame and every one of them restores its sources.

- **Demo 3.** `PaymentDemo.scala:123`. **Do not remove the ascription on line
  122** — without it the error moves off the edited line and becomes twenty lines
  of noise.
- **Demo 4.** `Main.idr:115`. **Replace `finish done` with `pure ()`; do not
  comment it out** — it is the last statement of its `do` block, so deleting it
  yields a syntax complaint instead of the linearity error. Both traps are
  recorded in `tools/capture-demos.sh`, which is executable and therefore cannot
  drift.

### Measured, not estimated

MB read slides 1–12 standing, twice: **13:29**, then **14:15** deliberately
slower after the title slide came in at 284 wpm. 2577 words → **181 wpm**.
Planning rate stays **140** — MB: *"we still need a comfortable margin for
nervosity & interruptions, so don't take my WPM as the target."*

### Next, in order

1. **MB reads Acts 4, 5 and 6.** They have not been reviewed by anybody.
2. **Wednesday read-through, whole deck, standing, timed.** The one open budget
   question is Part 13's: Act 1 is ~1:36 over its caps, and the reserve is the
   `A1-connectives` + `A1-quantifiers` merge. Decide it against a measured
   number, not an estimate.
3. **If the read-through comes in short**, the things worth adding back, in
   order: the lambda-cube reveals (`diagrams/lambda-cube.typ` needs
   parameterising, about an hour); the higher-kinded row on `A4-mechanisms`
   (`interpret[F[_]: Functor, A]`, `payment/Rules.scala`); `summon[Dual[P] =:=
   …]` as a spoken beat on `A4-sessions`.
4. **Dress rehearsal**, with the demos run live at least once end to end.

### Standing decisions that are easy to lose

- **No stage-opener slides, and the language change is a chip plus a clause.**
  v1 had a dark `stage-opener-slide` for every stage 0–6; the v2 rework dropped
  all seven, and MB caught the consequence on 18 Aug — nothing announced the move
  to Scala, and the word was not spoken at the boundary either. Two openers were
  built and cut again. Rendered, the v1 template is two-thirds empty at 0:12 of
  speech and its dominant element is a 320px numeral nobody needs; a dark card
  two slides before `a4-demo3`'s dark card weakens the one signal that has to
  work; and it costs 0:30 of the margin that absorbs nerves and questions. The
  fix is a filled accent **language chip** in the eyebrow slot of `A4-opens` and
  `A5-mltt` — the only two slides that use it, because they are the only two
  places the syntax on the wall changes — and the language **named in the first
  clause** of both scripts. Zero slides, zero seconds. Act 3's eyebrows already
  say `java` on every stage, so the chip reads as an escalation from them.
- **Cube reveals are cut, and no axis is ever named out loud.** The deck's only
  issuance is `A1-above`'s *there is a map of this territory*. Both ceiling
  slides do the reveal's job in words.
- **`a2-values` is cut.** Same-bytes moved to `A3-stage4`, affordability to `A6-cost`.
- **No payoff slide carries a scoreboard.** The collective view happens once, on
  `A5-payoff`, which is why `31-the-climb` is in the appendix.
- **Demo fallbacks are recorded terminal frames, not video.**
- **Java's real ceiling is protocol duality only.** Conceding the first two of
  the three is what makes the third believable.
- **Scala 3's real ceiling is two things:** the protocol menu written out in
  advance, and no way to say *used exactly once*. `dualInvolution` — which Idris
  does prove, `PaymentSessionTypes.idr:23-34` — is Q&A, not a slide claim.
- **Idris's remaining gap is honest and is Q&A:** `PaymentChannel.idr` uses
  `believe_me` casts in the transport, so a wire-format mismatch is still a
  runtime error.

### Tooling

`make check` = build + prose lint + timing. The linter reads **slide copy as
well as spoken script**, enforces Parts 8/9/12/14, fails on any phrase in
`tools/retired.tsv`, and there is a PostToolUse hook running it on every script
write — it caught five register faults this session before they reached a build,
including one retired phrase I walked straight into.

**Double quotes belong only in VERBATIM.** A quoted sentence in a PREPARATION
block is scored as speech and lints against the end of the real script. That
happened three times this session; `»…«` or italics below the rule.

**Every remaining lint ERROR is outside the main deck** except `curry-howard`
(Act 1, MB-reviewed, `monotone-overall`). The rest are appendix slides and three
orphan files that `deck.typ` does not include at all
(`11-convergence2`, `a04-tracking`, `a06-tracking`).

### (superseded — kept for the record)

### Where the deck stood earlier on 18 Aug

**Authored: 26 of 31 main slides.** Acts 0, 1, 2 and 3 are written to the
three-part script standard (TALKING POINTS / VERBATIM / PREPARATION) and are
lint-clean. Acts 4, 5 and 6 are untouched v1 prose.

| act | slides | state |
|---|---|---|
| 0 — Open | 3 | done · MB reviewed and amended · **measured** |
| 1 — Primer | 6 | done · MB reviewed twice · **measured** |
| 2 — Ground floor | 2 | done (`a2-values` cut) · **measured** |
| 3 — Java ladder | 12 files / 8 beats | **done, this session** |
| 4 — Scala 3 | 5 | **v1 — next** |
| 5 — Idris 2 | 3 | v1 |
| 6 — Close | 3 | v1 |

Act 3's twelve files: `17-stage1` (Stages 1+2 merged) · `19-stage3` ·
`10-gentzen-or` · `a3-demo1` + `-edit` + `-out` · `20-stage3-payoff` ·
`22-stage4` · `a3-demo2` + `-edit` + `-out` · `24-java-ceiling`.

### Measured, not estimated

MB read slides 1–12 standing, twice: **13:29**, then **14:15** deliberately
slower after the title slide came in at 284 wpm. 2577 words → **181 wpm**.
Planning rate stays **140** (MB: "we still need a comfortable margin for
nervosity & interruptions"). Caps were rebalanced against that run — time moved
between slides, never shaved.

### The next three things, in order

1. **Act 4 — Scala, five slides plus Demo 3.** The act that has never fit any
   budget. D-A decided **(c) one thread through the Scala stage**, falling back
   to (b) problem-led. D-C is still open and was deliberately deferred until Act
   4 exists, with **(d) capability-led, motivated by residual failure** as the
   working default — and `A3-ceiling` now ends on exactly that residual failure,
   so the joint is ready.
2. **Act 5 (3 slides) and Act 6 (3).** `34-close` is +1:24 and is the single
   worst slide in the deck; the last minute should be exact.
3. **Demo 3 and Demo 4** — same four-slide shape as Demos 1 and 2, and
   `tools/capture-terminal.sh` already knows how to record them.

### Standing decisions that are easy to lose

- **Cube reveals are cut.** `diagrams/lambda-cube.typ` was never parameterised;
  the full cube is in the appendix for Q&A. First thing worth adding back if
  Wednesday's read-through comes in short.
- **`a2-values` is cut.** Same-bytes moved to `A3-stage4`, affordability to
  `A6-cost`.
- **The nine-row inventory is `a10-invariants`**, appendix only.
- **`21-bridge`, `18-stage2`, `23-stage4-payoff` are deleted**; their content is
  merged or spoken.
- **Demo fallbacks are recorded terminal frames**, not video —
  `tools/capture-terminal.sh`, rendered by `terminal-pane`.


