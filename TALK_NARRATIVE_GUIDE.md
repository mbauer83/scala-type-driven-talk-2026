# Type-Driven Payments Talk: Narrative Guide

This file defines how to turn the stage implementations into a coherent, persuasive, audience-appropriate talk.

This guide assumes the personal introduction is handled separately.

## Core Narrative Promise

The talk should make one promise early and keep returning to it:

> Some classes of production incidents are not “just part of engineering life.” They are artifacts of using a language and design level that cannot express the invariants we actually care about.

The ending should cash that promise out:

> We can build systems where whole families of operational pain never make it to staging or production, because the invalid program cannot be constructed.

That is the emotional and intellectual spine of the talk.

There is a second hook that should be present, but not overplayed:

> This is a story about proving more things. First about values, then about functions, then about branches and state transitions, then about interacting procedures, and finally about programs whose next legal steps depend on evidence we have constructed.

That hook gives the theory section and the later Scala/Idris material a clear through-line, but it should not crowd out the broader engineering story:

- stronger modeling,
- clearer boundaries,
- fewer invalid states,
- better composition,
- reduced test burden,
- and fewer operational incidents.

## Target Shape

Hard constraint: the talk itself must finish in `45 minutes`, including:

- brief personal introduction,
- history and motivation,
- practical example progression,
- conclusion.

The additional `15 minutes` are reserved for Q&A and should not be relied on to finish the core argument.

Recommended structure:

1. `0:10-0:30` personal introduction
2. `5 min` opening incidents and human cost
3. `6 min` history, motivation, and theory
4. `28-30 min` practical progression through the examples
5. `4 min` conclusion and “beyond” glimpse

This balance matters. The theory should orient the audience, but the center of gravity must remain the practical progression.

## 45-Minute Delivery Plan

Use this as the default live schedule:

1. `00:00-00:30` personal intro
2. `00:30-05:30` cold open with incidents (5 min; ~75 sec per story for four stories)
3. `05:30-11:30` history, motivation, lambda-cube map (6 min)
4. `11:30-14:00` Stage 0 + Stage 1: JS and simple Java as a comparative moment (2.5 min)
5. `14:00-15:30` Stage 2 + Stage 3: one beat — "architectural wins, bug still compiles" (1.5 min; generics ~1 min, function pipelines ~20 sec spoken reference, no demo)
6. `15:30-21:00` Stage 4: records/sealed — the Java payoff (5.5 min; include the live delete-Medium-case moment)
7. `21:00-27:00` Stage 5: Java typestate — lifecycle as type (6 min)
8. `27:00-35:00` Stage 6: Scala 3 — a higher rung (8 min)
9. `35:00-41:00` Stage 7: Idris 2 — the runtime-to-type bridge (6 min)
10. `41:00-45:00` return to opening promise, Capture Checking pointer, closing horizon (4 min)

This schedule is intentionally back-loaded toward Java typestate, Scala 3, and Idris 2. Those are the stages where the audience gets the strongest “this changes what programs are expressible” payoff.

## What To Compress

To stay within 45 minutes:

- do not give every stage equal code time,
- group early stages by “what class of bug still survives here,”
- show one representative code fragment per stage, not a full walkthrough,
- use the same recurring incidents rather than inventing new examples as you go.

Recommended compression:

- JS and simple Java should be one comparative movement, not two deep dives.
- Generics and function pipelines should be shown as architectural improvement and setup, not as the climax.
- Records/sealed is important, but keep the code view narrow and focused on honest domain branching.
- The real depth belongs to Java typestate, Scala 3, and Idris 2.

## Live Demo Medium

The talk is not slide-only. Plan around three presentation modes:

- short conceptual slides,
- code shown in an IDE with syntax highlighting and hoverable types,
- running examples that emit readable logs.

Use the IDE actively:

- hover types when introducing a new guarantee,
- highlight the exact signature that carries the new proof obligation,
- collapse surrounding code aggressively so the audience sees one idea at a time.

Use runtime output actively:

- show logs for the “good” path,
- where possible, show that the “bad” path either fails early at the boundary or cannot even be compiled in the stronger stage,
- use the log output to make protocols and state transitions concrete.

## Must-Land Messages

If time pressure hits, these are the points that absolutely must land:

1. Some production incidents exist because invalid programs are expressible.
2. Each increase in type-level expressivity removes a more realistic class of bug — and a class of test.
3. Modern Java already goes surprisingly far: sealed interfaces, records, and phantom generics let us encode sum types, ADTs, and typestate-style lifecycle enforcement.
4. Scala 3 makes match types, phantom indexing, refined types, and compiler-derived evidence available as first-class tools — each removes a class of invalid construction — and session types with duality make protocol mismatches a compile error.
5. Full dependent types remove the remaining runtime-to-type bridge.

Everything else is subordinate to these five points.

Notice that none of these five points require the talk to sound like a theorem-proving lecture. “Proving more things” is a useful explanatory thread, but the primary payoff should still feel like ordinary engineering value.

## Opening: Human Stakes First

The opening should not begin with definitions, the lambda cube, or “what is a type?”.

It should begin with credible operational pain.

The audience should first feel:

- these are bugs I have seen,
- these are bugs that cost sleep, money, and trust,
- these are bugs that were not caused by stupidity,
- these are bugs that a stronger type-level design could have prevented.

Do not mention the solution yet. Let the pain stand on its own for a moment.

## Suggested Cold Open: Four On-Call Mini-Stories

Use named developers because people remember people better than abstract failure modes.

Keep the stories short, concrete, and slightly uncomfortable. They should sound like incidents that happened in a competent team under normal pressure.

In a 45-minute talk, use four stories, not five. Evan should remain optional and likely be omitted live unless the room is highly engaged and pacing is ahead of schedule. The 5-minute cold open budget allows approximately 75 seconds per story — enough for a three-sentence beat (setup, bug, consequence) plus a breath, but no embellishment. Rehearse all four stories to time; 75 seconds is faster than it sounds when you are also watching the room.

These opening stories do not all have to come from the payment domain. In fact, using multiple domains can make the talk more broadly relatable, as long as each story foreshadows a kind of proof the later examples will make possible.

## Concrete Incident Suggestions

These are not mandatory scripts, but they are concrete enough to present directly with only minor wording changes.

### Alice: stringly-typed input at a pricing boundary

Scenario:

- an internal admin tool exports a CSV of order lines with a pre-computed `lineTotal` column,
- a Node.js import job reads those rows and aggregates them to build draft invoices.

Concrete bug:

- `lineTotal` values arrive from the CSV parser as strings; the code sums them without parsing first,
- `total = row1.lineTotal + row2.lineTotal` performs string concatenation, not addition,
- for `lineTotal = "4500"` and `lineTotal = "1500"`, the stored invoice total becomes `"45001500"` instead of `6000`.

Note: `*` would not have caught this — JavaScript coerces strings to numbers for `*`, `/`, and `-`. Only `+` silently concatenates. The bug lives specifically at the boundary where `+` is the correct operation but the operands are unintentionally strings.

Why this is a good opening example:

- everybody understands it immediately,
- it is low on theory and high on relatability,
- it cleanly motivates the first rung: basic static typing and boundary validation.

### Bob: forgotten workflow branch in a risk decision

Scenario:

- an e-commerce checkout service classifies orders as `low`, `medium`, or `high` risk,
- only medium-risk card orders must go through 3DS.

Concrete bug:

- the application flow was originally written as `if (risk != high) fastPath() else manualReview()` — a default-open condition that assumed only two risk levels existed,
- when `medium` was added to the risk engine, medium-risk card orders silently fell through to `fastPath()` and skipped 3DS entirely.

Why this is a good second example:

- it motivates honest branching,
- it sets up product/sum types and exhaustive handling,
- it also foreshadows the later payment demo directly.

### Charlie: illegal state transition in a review pipeline

Scenario:

- a deployment approval system tracks `Draft`, `Reviewed`, `Approved`, and `Released` rollouts,
- only reviewed rollouts may be approved, and only approved rollouts may be released.

Concrete bug:

- a maintenance endpoint calls `releaseRollout(id)` directly on a rollout fetched from storage without verifying that it has passed through `Approved`,
- one rollout still in the `Reviewed` state is accidentally released to production during an overnight incident.

Why this is a good typestate example:

- it is not payment-specific,
- the state machine is obvious,
- the pain of reconstructing “legal next steps” from comments and booleans is easy to explain.

### Danielle: protocol drift between two services

Scenario:

- a B2B fintech platform lets small businesses apply for higher payout limits,
- the frontend onboarding service uploads company documents to a compliance/KYC service,
- for ordinary cases the workflow is simple, but for larger requested limits the compliance service now requires an extra acknowledgment that the submitted evidence passed enhanced review before final confirmation.

Concrete bug:

- the server now expects `Upload -> EvidenceRequest -> EvidenceProvided -> EvidenceAccepted -> FinalConfirmation`,
- but the client still assumes `Upload -> EvidenceRequest -> EvidenceProvided -> FinalConfirmation`,
- integration tests miss the exact branch and production clients start timing out only for large uploads.

Why this is a good later-stage example:

- it naturally motivates protocol structure and duality,
- it is relatable beyond finance,
- it shows why plain enums and comments are not enough for interacting procedures.

### Evan: missing audit evidence on a rare branch

Scenario:

- a subscription SaaS company has a customer-support backoffice where agents can issue account credits and goodwill refunds,
- for small cases a team lead can approve the credit directly, but for suspicious cases the request is routed through an internal fraud-review workflow first,
- finance and compliance expect every issued credit to leave behind a clear audit trail with ticket ID, actor, and reason.

Concrete bug:

- the `managerApproval` branch appends `AuditEntry("credit-issued", ticketId)`,
- the `fraudReview` branch returns early after issuing the credit and forgets to append the audit entry,
- the bug is only discovered during a compliance review six weeks later.

Why this is a good optional example:

- it motivates carrying evidence and traceability in constructed program states,
- it supports the later Idris payoff well,
- but it is optional enough to omit if time is tight.

### Story 1: Alice and the stringly-typed boundary

Alice is on call because a value came in from a form field or CSV import as a string and was used as if it were a number. Somewhere a parse step was forgotten, or a string concatenation happened where arithmetic was intended.

Operational consequences:

- totals are wrong,
- thresholds are crossed incorrectly,
- monitoring sees weird downstream values,
- Alice is tracing the bug through innocent-looking application code.

This is the lowest rung. It is not the deepest bug in the talk, but it is the fastest way to establish that even basic interpretation of data is already something we either check rigorously or leave to chance.

### Story 2: Bob and the skipped branch or missing case

Bob is handling an incident where a medium-risk order, onboarding case, or approval workflow ended up on the default fast path because one case was forgotten or weakened in branching logic.

Operational consequences:

- the wrong flow executes,
- customers see inconsistent behavior,
- emergency patch under pressure,
- retrospective full of “how did this even compile?”

This foreshadows product types, sum types, and eventually stronger protocol structure.

### Story 3: Charlie and the invalid state transition

Charlie gets paged because a workflow step happened out of order: a deployment was promoted before review, a document was approved after cancellation, or a payment was captured before authorization/review had completed.

Operational consequences:

- state corruption,
- policy violation,
- rollback or repair work,
- Charlie is trying to reconstruct the intended state machine from logs and comments.

This is the clearest way to motivate typestate.

### Story 4: Danielle and the missing evidence / protocol drift

Danielle is dealing with a system where one side thinks an extra step is required and the other side does not, or where a challenge/approval/evidence artifact should have existed but was never constructed or checked.

Operational consequences:

- protocol mismatch,
- failed integrations,
- inconsistent auditability,
- a lot of “but that should have been impossible.”

This is the bridge to session types, path-dependent evidence, and dependent typing.

### Optional Story 5: Evan and the missing audit evidence

Evan is investigating why one branch of the payment lifecycle has no audit event. The happy path records everything; a rare branch does not.

Operational consequences:

- compliance concern,
- missing traceability,
- incident investigation slows down,
- everyone says “we thought that code path reused the same audit helper.”

Use this only if pacing is comfortably ahead or if the audience is especially interested in compliance and traceability.

## Transition Out Of The Cold Open

The closing line of the opening section should point forward without solving everything immediately.

Recommended move:

- say that each of these failures came from a program being able to express something that the business process should have forbidden,
- say that the rest of the talk is about progressively taking that expressive freedom away from invalid programs,
- mention that one helpful way to understand this is that we are getting the language to check progressively stronger claims for us,
- hint that by the end, these errors are not “well tested”; they are unrepresentable.

The tone here should be calm and slightly provocative, not evangelical.

## Theory Section: What It Must Achieve

This section is not a survey course. Its job is to answer three questions for an audience of practitioners:

1. Why has formalizing reasoning mattered for so long, and why should an engineer care?
2. Why do types exist — not as a Java feature, but as a mathematical necessity?
3. What does it mean to gain expressive power, and where does each stage of this talk sit on that map?

If the audience finishes thinking “I now know proof theory,” it went wrong. If they finish thinking “types have deep roots, those roots explain why stronger types give stronger guarantees, and I have a map for what I’m about to see,” it worked.

## Theory Section: Spine

The entire theory section hangs off a single sentence, stated explicitly at the start:

> Humans have spent 2,500 years trying to formalize the difference between valid and invalid reasoning. Types are the latest — and most practically useful — expression of that project. Your compiler’s type checker is a direct descendent.

Every historical name and every concept introduced should serve this sentence. Nothing else earns its place.

## Theory Section: Three Beats

This section should take `6 minutes` in the default version of the talk. Prepare a `9-10 minute` variant, but only use it if the cold open finished noticeably under 5 minutes and you have confirmed slack. Do not extend the theory section speculatively — the back-loaded stages are where the payoff lives and they have no slack budget. In either version, each beat has a single aha moment — identify it, land it, move on.

The full historical content below is preparation material. The 6-minute delivery is a motion through these ideas at speaking pace, not an enumeration of every name. In the default 6-minute version: Beat 1 names Aristotle, Leibniz, and the convergence into Principia Mathematica (Boole and DeMorgan appear on a slide). Beat 2 lands Russell’s paradox, types as the fix, Hilbert’s desiderata, and Gödel’s incompleteness result. Beat 3 lands Gentzen’s interface model, Curry-Howard, Martin-Löf, and the lambda cube transition.

### Beat 1: The Pre-History of Formal Structure (~90 sec)

**Arc:** Aristotle → DeMorgan → the convergence into Principia Mathematica.

For over two thousand years, every generation asked the same question: how do we make valid reasoning explicit enough that *invalid* reasoning cannot sneak through?

- **Aristotle, 4th century BCE**: establishes that the validity of an argument can be evaluated from its structural form alone, independent of what it is about. Replace the content with variables; the form either holds or it does not.
- **Leibniz, 17th century**: links logic directly to calculation. Truth is consistency — “false” means *leads to a contradiction*. He conceives a universal notation (*characteristica universalis*) and a mechanical calculus (*calculus ratiocinator*) to reduce reasoning to arithmetic. He defines identity: two things are identical if and only if they share every property.
- **Boole, 1847**: realizes the algebraic engine. Propositional logic — including implication — can be modelled completely using only *and*, *or*, and *not*. Logical operations obey strict algebraic laws.
- **DeMorgan, 1847**: exposes the structural dualities within Boolean algebra — the laws bearing his name. He also develops a formal calculus of relations, treating composition of relations as a first-class algebraic operation. Alongside Boole, he lays the algebraic foundations that Frege and Peano will build upon.

At the turn of the 20th century, the algebraic tradition (Boole, DeMorgan, Peirce, Schröder) and the proof-theoretic tradition (Frege) fuse. Giuseppe Peano adopts Frege’s syntactic precision but clothes it in the symbolic clarity of the mathematicians. Bertrand Russell and Alfred North Whitehead scale this synthesis to its absolute limit in *Principia Mathematica*, attempting to map all of mathematical thought within a single unified formal system.

**Aha moment:** Formal structure restricts what can be said, so that what *can* be said can be trusted. This is not a limitation — it is the whole idea. The motion from Aristotle to Principia is not about truth — it is about progressively tightening what a *valid step* looks like.

### Beat 2: The Great Synthesis and the Crisis of Consistency (~90 sec)

**Arc:** Frege → Russell → Constructivists → Hilbert → Gödel → types as the formal response.

- **Cantor**: attempts to ground this newly unified mathematical reasoning in collections. He asserts that for any definable property, there exists a set of objects possessing it — establishing a universe analysed through membership, unions, and intersections.
- **Frege, 1879** (*Begriffsschrift*): permanently decouples Syntax (the mechanical rules for token manipulation) from Semantics (how those tokens map to a model). Introduces formal variable binding and quantification (∀, ∃) within a second-order logic, allowing functions to pass into other functions and abstract over properties. The bedrock of modern mathematical logic — and the system Cantor’s principle would break.
- **Russell, 1901**: exposes a fatal contradiction. “The set of all sets that do not contain themselves” (x ∉ x) is a self-referential loop that destroys logical consistency wherever Cantor’s principle holds without restriction. To restore order, Russell introduces **Types** — a strict hierarchy ensuring a predicate can never operate on objects at its own level. Types were invented to prevent logic from consuming itself.
- **Constructivists (Brouwer, Heyting, Kolmogorov)**: reject classical platonic semantics. Asserting a statement is “true” requires a concrete, step-by-step recipe to construct a witness. They reject the Law of Excluded Middle (A ∨ ¬A) as a universal axiom: a disjunction is only proved if you actively supply either a proof of the left (Left) or a proof of the right (Right) — *at proof-construction time*. This is not a runtime behaviour; it is the structure of the proof itself.
- **Hilbert**: defines the absolute desiderata for any perfect proof system:
  - **Consistent**: it can never derive ⊥ (a structural contradiction).
  - **Sound** (⊢ ⟹ ⊨): if a statement is provable via syntax, it is true via semantics. In programming: type safety, verified via *Progress* (well-typed code never gets stuck) and *Preservation* (evaluation never mutates the underlying type).
  - **Complete** (⊨ ⟹ ⊢): if a statement is semantically true, the syntax is expressive enough to construct a proof for it.
- **Gödel, 1931** (incompleteness theorems): proves that Hilbert’s programme for arithmetic-strength systems is impossible. Any consistent formal system strong enough to encode basic arithmetic is necessarily *incomplete*: it contains statements that are true in the intended model but that the system cannot prove. Moreover, such a system cannot prove its own consistency. The mechanism is *Gödel numbering* — serialising syntax into numbers so the system can write a statement asserting its own unprovability: if the system proves it, it is inconsistent; if it cannot, the statement is true but unprovable.

  *Precision: Gödel had shown in 1929 that first-order predicate logic without arithmetic IS complete — every formula true in all interpretations has a formal proof. The incompleteness results (1931) are specific to systems expressive enough to encode self-reference via arithmetic. Similarly, Gentzen (1936) later proved the consistency of Peano arithmetic — but only by using a stronger assumption (transfinite induction to ordinal ε₀) that arithmetic itself cannot establish. Consistency can be proved; it just requires stepping outside the system.*

  This forces a permanent pivot: we abandon global provable completeness and focus entirely on protecting Soundness and Consistency.

**Aha moment:** Types were invented to stop logic from breaking. The safety boundary your compiler enforces has over a century of mathematical necessity behind it.

### Beat 3: The Computational Convergence (~2 min)

**Arc:** Church/Turing → Gentzen → Howard → Martin-Löf → Coquand → Voevodsky → bridge to the lambda cube.

- **Church and Turing, 1936**: formalise execution by stripping away numbers and sets as primitives. Church’s untyped λ-calculus proves that anonymous functions passing into other functions achieve Turing completeness. This introduces the Halting Problem and exposes a fundamental structural conflict:
  - *Logical consistency requires strong normalization*: every evaluation path must terminate. If a type system allows infinite, unchecked recursion, a loop can act as a fake witness for ⊥, allowing you to prove a lie and crashing consistency.
  - *Computation requires Turing completeness*: industrial languages drop guaranteed termination to allow infinite loops and arbitrary recursion.
  Church isolates this safely with the **Simply Typed Lambda Calculus** — types restrict inputs and guarantee termination where logical safety is mandatory.

- **Gentzen, 1935**: shifts logic away from global axioms, framing it as a local structural architecture. Every logical connective is defined purely by its interface: how you build it (**Introduction Rules** / Constructors) and how you use it (**Elimination Rules** / Destructors). He proves that introducing a connective and immediately eliminating it is a redundant step that can be optimised away via **cut elimination** — a logical analogue of compiler dead-code removal. *(See formal slide: Gentzen OR rules.)*

- **Howard, 1969** (Curry-Howard Isomorphism): uncovers a profound structural identity between Gentzen’s natural deduction and Church’s typed functions. A logical proposition (A ∧ B) is identical to a data type (a Tuple). An implication (A → B) is a function type. A formal proof is an executing program, and running a program is simply simplifying a proof. Writing code that compiles is structurally identical to constructing a proof.

- **Martin-Löf, 1972**: elevates the expressivity of this isomorphism by introducing **Dependent Types** — types that depend directly on runtime values. A universal statement (∀) becomes a **Π-type** (dependent function type): the return type is computed from the argument value, allowing full predicate logic to be expressed purely as types. An existential statement (∃) becomes a **Σ-type** (dependent pair): a value together with a proof that it satisfies the required predicate. *(See formal slide: MLTT Π and Σ types.)*

- **Coquand, 1988**: compresses this entire lineage into the **Calculus of Constructions (CoC)** — dependent types unified with polymorphism in a minimal, auditable core. The engine behind Coq (verified CompCert C compiler, Paris metro signalling) and Lean (Mathlib). A tiny, highly auditable type-checker kernel provides a mathematical guarantee of absolute safety.

- **Voevodsky**: treats equality not as a static true/false flag but as a continuous path of transformations borrowed from topology, establishing the **Univalence Axiom**: isomorphic types are literally equal. This formally grounds the intuition that two types or libraries that behave identically are interchangeable — not by convention, but provably.

**Scientific importance:** the Curry-Howard correspondence drives Coq, Lean, Agda, Idris, and in more applied form, Rust’s borrow checker and Scala 3’s capture checking. One of the most productive ideas in the history of computer science.

**Aha moment:** When you write a type, you are stating a proposition. When the compiler accepts your program, it has checked your proof. Every stage of this talk is a system that can check a stronger class of propositions.

**Transition:** “So when I show you, in a moment, that `Approval[LowRisk]` cannot satisfy `Approval[MediumRisk]`, that is not a Scala trick. It is the same tradition — making the invalid program unable to be expressed — that Russell started when he tried to stop logic from consuming itself.”

## Theory Section: The Lambda Cube Slide

Use one slide for the lambda cube — a diagram, three axes, plain English labels, and the stages of this talk placed on it. Not as rigour, but as a map the audience can orient from for the next 30 minutes.

- **Bottom-left corner (λ→, STLC)**: simply typed lambda calculus — Stage 1. Type safety, but no abstraction over types.
- **Terms depending on types** (polymorphism axis, λ2 = System F): `Validator<T>`, `AuditTrail<E>`, `Channel[P]` — Stages 2, 5, 6. Write once, correct for any type parameter. *Java generics give you the engineering benefit of System F polymorphism — write once, the compiler proves correctness for every instantiation. The runtime encoding differs (type erasure); Scala's generics are a closer structural match. But the polymorphism benefit is real in both.*
- **Types depending on types** (type operators axis, λω = System Fω): `Dual[P]`, `Approval[R <: Risk]`, match types — Stages 5 and 6. Types computed from types at compile time. *Type constructors: `Payment<S>` maps a state-type to a lifecycle-type.*
- **Types depending on terms** (dependent types axis, λC = Calculus of Constructions): `protocolDerivedFrom : Order → SessionType` — Stage 7 only. The return *type* is computed from the runtime *value*.

Label each axis with one word: *generics*, *type operators*, *dependent types*. The key observation: Stages 1–6 move along the first two axes. Stage 7 crosses into the third. That third axis is what makes the Idris 2 demo qualitatively different — not more expressive by degree, but expressing something Scala cannot state at all.

## Theory Section: Formal Slide — Gentzen OR Rules

This slide appears in Beat 3 when introducing Gentzen. Keep it visually minimal: the rules in standard notation with English labels. Use it again as a callback when Stage 4's exhaustive match is introduced.

**Introduction rules** (constructing a disjunction — OR-introduction):

```
   A              B
───── (∨I₁)    ───── (∨I₂)
A ∨ B          A ∨ B

Left(proofA) : A ∨ B       Right(proofB) : A ∨ B
```

**Elimination rule** (using a disjunction — the exhaustive match):

```
        [A]    [B]
         ⋮      ⋮
A ∨ B   C      C
───────────────────── (∨E)
          C

match x { case Left(a)  => C
          case Right(b) => C }
```

Missing the `Right` branch = you have not supplied the [B] → C proof. The compiler cannot apply ∨E. Compile error.

**Speaker note for Stage 4 callback:** "Gentzen defined every connective by its interface: how you build it and how you use it. A sealed type is a disjunction. To draw any conclusion from a value of that disjunction, you must have handled every variant — every branch is a proof obligation. Missing the `Medium` case is not a style issue. It is an incomplete proof. The compiler enforces ∨E."

## Theory Section: Formal Slide — MLTT Π and Σ Types

This slide appears in Beat 3 when introducing Martin-Löf. Use it as a bridge to Stage 7. Keep it brief on screen — the audience needs to see the structure, not read every symbol. Speak through it rather than letting them read it silently.

**Π-types (∀ as dependent function type):**

```
Formation:    Γ ⊢ A : 𝒰    Γ, x:A ⊢ B(x) : 𝒰
              ────────────────────────────────── (Π-Form)
                    Γ ⊢ (Πx:A). B(x) : 𝒰

Introduction: Γ, x:A ⊢ b(x) : B(x)
              ──────────────────────────────── (Π-Intro / λ)
              Γ ⊢ λx. b(x) : (Πx:A). B(x)

Elimination:  Γ ⊢ f : (Πx:A). B(x)    Γ ⊢ a : A
              ──────────────────────────────────── (Π-Elim)
                        Γ ⊢ f(a) : B(a)

Computation:  (λx. b)(a) ≡ b[a/x]    (running the proof = β-reduction)
```

**Σ-types (∃ as dependent pair type):**

```
Formation:    Γ ⊢ A : 𝒰    Γ, x:A ⊢ B(x) : 𝒰
              ────────────────────────────────── (Σ-Form)
                    Γ ⊢ (Σx:A). B(x) : 𝒰

Introduction: Γ ⊢ a : A    Γ ⊢ b : B(a)
              ────────────────────────────── (Σ-Intro / pair)
              Γ ⊢ (a, b) : (Σx:A). B(x)

Elimination:  Γ ⊢ p : (Σx:A). B(x)          Γ ⊢ p : (Σx:A). B(x)
              ────────────────────── (fst)    ──────────────────────────── (snd)
              Γ ⊢ fst(p) : A                  Γ ⊢ snd(p) : B(fst(p))

Computation:  fst(a, b) ≡ a      snd(a, b) ≡ b
```

**Connection to Stage 7:**
- `protocolDerivedFrom : Order → SessionType` is a Π-type: the *shape* of the return type is computed from the argument value. Π-elimination fires at every call site — the compiler propagates the type. Scala's ProtocolVariant ADT papers over the same idea with a closed runtime selection.
- `assessOrder : Order → (lvl ** Assessment lvl n c)` is a Σ-type: a dependent pair where the risk level `lvl` is both a returned value and an index into the type of the second component. "There exists a level `lvl` such that this order's assessment has type `Assessment lvl n c` — and here is both the level and the proof."

**Speaker note:** "These are the rules Idris 2 runs. When you call `protocolDerivedFrom order`, Π-elimination fires: you apply a function to a value, and the compiler computes the output type from that value. The bridge between runtime values and compile-time types — the thing Scala's ProtocolVariant ADT papers over — is this rule. Stage 7 is these rules running as programs."

## Theory Section: What To Avoid

- Lecturing as if the audience signed up for a logic seminar.
- Proving theorems on slides or introducing symbolic notation beyond what the IDE will show.
- Treating Gödel, Church, or Turing as trivia to name-drop rather than ideas to land.
- Using category theory as a prestige signal — it is not needed for this talk.
- Assuming prior knowledge of ADTs, variance, proofs-as-programs, or theorem provers.

Do not treat “proof” as something that only happens in a separate verification assistant. The key educational move of the talk is that proof is already happening — at degrees of strength — in every stage:

- a smart constructor is already packaging evidence,
- an exhaustive match is already discharging a branch obligation,
- a typestate transition signature is already a claim about legal next steps,
- a duality check is already a protocol compatibility proof,
- dependent types let you state and check the strongest such claims directly.

## Practical Section: Governing Principle

After the theory section, the talk should become relentlessly concrete.

Each stage follows the same rhythm. Apply it consistently:

1. show what the current rung makes possible,
2. show a realistic bug it eliminates — in code, not in the abstract,
3. say explicitly which tests are now deletable,
4. say explicitly what code is no longer written because of genericity or structural enforcement,
5. show the bug that still compiles — the reason to climb one rung further.

The recurring phrases that make this work:

- "At this rung, the invariant is **documented**."
- "At this rung, the invariant is **tested**."
- "At this rung, the invariant is **encoded** — the invalid program cannot be constructed."
- "What can we now state and check that we could not one rung ago?"
- "What invalid programs are still expressible here?"

This repeated structure is what makes the progression intelligible rather than just impressive. The audience should be able to predict the pattern by Stage 3 — and then feel the payoff when it keeps delivering stronger guarantees.

## Practical Section: Suggested Stage Narrative

This section tracks the stage directories. The talk does not need equal time for each stage.

### Stage 0: JavaScript — the untyped baseline

**What this rung has:** dynamic dispatch, runtime freedom, no structural constraints.

**In the demo, show:** two bad demos only — capture-before-authorize (returns `capturedAmount: undefined`) and skip-3DS (returns `approvalNote: 'auto-approved-wrong'`). Both compile, both run silently.

**Say explicitly:**

- Every one of these failure modes requires a test. The test suite is the only thing standing between this code and production.
- What you do not test, you do not catch.

**Tests required at this rung (name these out loud):**

- Test that capture is never called before authorize.
- Test that medium-risk orders actually go through 3DS.
- Test that invoice orders cannot be refunded.
- Test that the captured amount matches the authorized amount.
- Test every boundary that the business cares about — none are enforced structurally.

**Tests still required** (ordered by when each will be eliminated — the first is what the next stage closes):

1. *(Stage 1 closes)* Test that a value of the wrong type cannot be passed to a lifecycle function — e.g. `capture(order)` when `Authorization` is expected.
2. *(Stage 2 closes)* Test that all error and null paths from constructors are handled by callers.
3. *(Stage 4 closes)* Test that all risk branches are handled — that the medium-risk case is never silently skipped.
4. *(Stage 5 closes)* Test lifecycle ordering — that capture is never called before authorize.
5. *(Stage 6 closes)* Test that the right authorization method is used for the risk level (no auto-approval for medium-risk orders).
6. *(Stage 6 closes)* Test boundary constraints — that negative or zero quantities are rejected.
7. *(Stage 7 closes)* Test that the correct protocol variant is selected for a given runtime risk assessment.

This is the full list of things the type system at this rung cannot check. Every subsequent stage removes items from this list.

---

### Stage 1: Simple Types — nominal structure and smart constructors

**Type-theoretic position:** λ→ (simply typed lambda calculus). Values as proof terms; smart constructors as introduction rules. Hilbert's Soundness in practice: Progress (a well-typed call never gets stuck passing the wrong object) and Preservation (evaluation does not change the underlying type). Note: Stage 1 already enforces a *primitive form of typestate* — you cannot call `capture()` without holding a real `Authorization`, and you cannot fabricate an `Authorization` because the constructor is private. Stage 5 makes this lifecycle grammar visible as an indexed type family; it does not introduce typestate for the first time.

**What this rung adds:** nominal types and the smart-constructor pattern. A function that expects `Authorization` cannot receive an `Order` — shape errors are compile errors. `Authorization`, `Capture`, and `Refund` have private constructors — `new Authorization(...)` is a compile error; the only path in is `Authorization.from(Order, ...)`. This is the smart-constructor / opaque-type pattern: fabrication is blocked and each value's fields are guaranteed consistent with the prior step. As a consequence, `capture()` requires a real prior `authorize()` call — you cannot skip steps because you cannot fabricate the required input. This is the same idea that refined types and opaque types make first-class at stage 06; here it is done manually with Java's access modifiers.

**In the demo, show:** the `processOrder` and `capture` signatures; show that `capture(order)` does not compile — shape error from nominal typing. Then show `gainDemo_SmartConstructors()`: show that `new Authorization(...)` is a compile error — private constructor blocks fabrication. Name the pattern explicitly: smart constructor, same idea as opaque types in Scala. Show the bad demo that skips 3DS — it still compiles.

**Structural enforcement — code not written:**
Defensive “is this the right type of object?” guards at every call site. No test needed for fabricated-authorization or skip-capture — the compiler blocks those paths.

**Genericity — code not written:**
Not much yet. This rung is about naming and construction discipline, not abstracting.

**Tests deleted:**
Tests for shape confusion — compile error. Tests for fabricated lifecycle values (“fabricated authorization should be rejected”) — private constructor makes construction a compile error.

**Tests still required** (first item is what the next stage closes):

1. *(Stage 2 closes)* Tests for wrong element type in typed collections. Tests for whether `Validator<T>` composition is correct across domain types — parametricity makes these generically correct.
2. *(Stage 4 closes)* Test that all risk branches are handled — the medium-risk case can be forgotten silently. Test that the error path from constructor validation is enforced — callers can currently catch or ignore thrown exceptions.
3. *(Stage 5 closes)* Test that the lifecycle state is tracked in the type — `Authorization`, `Capture`, `Refund` are separate class names, not a unified class with the state as a type parameter. Stage 5 makes the state machine a single class with the state in the type parameter, enabling risk-level indexing at Stage 6.
4. *(Stage 6 closes)* Test that the right authorization method is used for the risk level.
5. *(Stage 6 closes)* Test boundary constraints — negative or zero quantities reach the service.
6. *(Stage 7 closes)* Test that the correct protocol variant is selected for a runtime risk assessment.

**Per-flow binding remains open throughout all Java stages.** Any valid `Authorization` is accepted by any `capture` call; two concurrent flows can exchange lifecycle values without a type error. Java's type system has no mechanism to express flow identity.

---

### Stage 2: Parametric Polymorphism — reusable typed abstractions

**Type-theoretic position:** λ2 (System F) — the first axis of the lambda cube: terms depending on types. ∀-quantification over type parameters. Write a definition once; the compiler proves it correct for every type it is instantiated with. *Generics are Girard's second-order quantification as engineering practice.*

**Live talk treatment:** present Stage 2 and Stage 3 together as one beat (~1.5 min total: Stage 2 gets ~1 min, Stage 3 gets ~20 sec). The message is: “generics and function values give us architectural wins — reusable abstractions, composable rules, explicit control flow. Both matter. Neither changes what states are constructible. The bug still compiles.” Then transition directly into Stage 4 where structural enforcement begins.

**What this rung adds:** parametric polymorphism — `Validator<T>`, `AuditTrail<E>`, typed collections (`List<OrderLine>`). Write validation and audit logic once; reuse across every domain type. Private constructors on `Authorization` are maintained: the buggy demo shows the actual remaining gap — cross-flow identity binding — rather than fabrication (which is already blocked).

**In the demo, show:** `Validator<T>` composed from smaller validators (`OrderLineValidator andThen OrderValidator`). Show `AuditTrail<E>` typed — inserting a `Capture` into an `AuditTrail<String>` is a compile error. Show the bad demo: a legitimate `Authorization` from order A is passed to the `capture()` call for order B. Both orders exist, the Authorization is valid, but the lifecycle values are from different flows — the captured amount is wrong. The compiler accepts this because `capture(Authorization)` accepts any `Authorization`; it carries no identity binding to a specific order lifecycle.

**Structural enforcement — code not written:**
Type-safe collections: inserting the wrong element type is a compile error — no runtime `ClassCastException` or element-type guard needed. `Validator<T>` composition: once defined for type T, the composition rule is provably correct for all T — no per-type composition tests.

**Genericity — code not written:**
Without `Validator<T>`, you write `OrderLineValidator`, `OrderValidator`, `AuthorizationValidator` as separate classes with duplicated composition logic. With `Validator<T>`: write `andThen` once for any T. Same for `AuditTrail<E>`. Test the composition rule once; parametricity makes it correct for all instantiations.

**Tests deleted:**
Tests for wrong element type in typed collections — compile error. Tests for “does this validator work for type X?” — the generic definition proves it for all types simultaneously.

**Tests still required** (first item is what the next stage closes):

1. *(Stage 4 closes)* Test all risk branches are handled — the medium-risk case is still silently forgettable. Test that error paths from constructor validation are enforced — callers can currently catch or ignore thrown exceptions; the error path is not yet in the return type.
2. *(Stage 5 closes)* Test lifecycle ordering — any `Authorization` is accepted by `capture`, regardless of which order's lifecycle produced it.
3. *(Stage 6 closes)* Test the right authorization method is used for the risk level.
4. *(Stage 6 closes)* Test boundary constraints — zero-quantity lines are rejected.
5. *(Stage 7 closes)* Test that the correct protocol variant is selected for a runtime risk assessment.

---
### Stage 3: Function Pipelines — explicit rules as values (reference only, no live demo)

**Live talk treatment:** acknowledge in Stage 4's opening paragraph only. Do not run a demo. Say:

> "Java 8 also gave us function values — business rules as explicit, composable, unit-testable typed objects. `PaymentStep<A,B>` and `RiskRule` are rules written down, not scattered through service methods. But neither generics nor function values change what states are *constructible*. The bug still compiles. Records and sealed types fix that."

The code is in the repository and available for Q&A. In the live talk it is absorbed into Stage 4's opening; it does not get a separate demo slot. The time saved goes to Stage 4.

**What this rung adds:** business rules become first-class values (`RiskRule`, `PaymentStep<A,B>`). Higher-order composition (`andThen`, `maxWith`) replaces scattered logic with explicit, testable structure.

**In the demo, show (repository / Q&A only):** the `riskEngine` as a composed `RiskRule`. `PaymentStep` composition as a pipeline. Each step unit-testable in isolation. Then show the bad demo: the engine returns the right risk, but the developer selects the wrong pipeline — no error.

**Structural enforcement — code not written:**
Nothing new at the structural level — the pipeline does not yet enforce that the risk result drives the step selection.

**Genericity — code not written:**
`PaymentStep<A, B>` defines `andThen` once for any A→B. Without this abstraction, every composed flow duplicates the wiring logic. One `RiskRule.maxWith` serves all threshold combinations. Rules are defined in one place; calling sites compose, they do not copy.

Silent duplication that drifts is eliminated: two separate copies of the threshold logic that get out of sync are replaced by one value, shared everywhere.

**Tests deleted:**
Tests for combined risk rule behaviour can be replaced by independent tests of each rule and one test of the composition rule. The surface shrinks.

**Tests still required** (first item is what the next stage closes):

1. *(Stage 4 closes)* Test that the right pipeline is selected for every risk level — Bob’s bug still compiles: `lowRiskPipeline` can be chosen for a medium-risk order.
2. *(Stage 5 closes)* Test lifecycle ordering.
3. *(Stage 6 closes)* Test the right authorization method for the risk level.
4. *(Stage 6 closes)* Test boundary constraints.
5. *(Stage 7 closes)* Test correct protocol variant selection.

---

### Stage 4: Records, Sealed Unions, and Sum Types — honest domain modelling

**Type-theoretic position:** λ2 (System F) + product and sum types — Curry-Howard made explicit. Records are product types (∧-introduction): every field must be present. Sealed unions are sum types (∨-introduction): only one variant can hold. Exhaustive match is ∨-elimination: to draw any conclusion from a disjunction you must discharge every branch. ADTs are sums of products — a precise, closed representation of valid inhabitants: products encode required fields, sums encode alternatives. This is also the stage where this callback to the Gentzen OR-rules slide earns its place.

**Stage 3 acknowledgement (30 sec before entering ADT content):** “Java 8 also gave us function values — `PaymentStep<A,B>` and `RiskRule` make business rules explicit, composable, testable in isolation. That code is in the repo. But neither generics nor function values change what states are *constructible*. Records and sealed types do. Let's see how.”

**What this rung adds:** product types (records) and sum types (sealed interfaces) — and `Result<T>` as the canonical sum type for error handling. `RiskDecision` is `Low | Medium | High` — a sealed hierarchy. Forgetting a variant is a compile error. `PaymentMethod` is `Card | Wallet | Invoice` — unknown variants cannot be constructed. `Result<T>` is `Ok<T> | Err` — a sealed type with two variants and no unsafe extractor: callers must handle both branches via exhaustive match or `flatMap`.

**Refund domain note:** `PaymentMethod` no longer carries a `supportsRefund: Boolean` flag. Instead it carries a `RefundMechanism`: `Card` and `Wallet` use `InstantReversal`; `Invoice` uses `CreditNoteRequired`. Refund availability is about settlement process, not risk level. The `refund()` function returns `Result.err(“invoice: credit note required — use issueCredit()”)` for Invoice payments. This is more accurate to the domain and still demonstrates the sealed-type exhaustiveness story.

**In the demo, show:**
1. The exhaustive switch on `RiskDecision`. Delete the `Medium` case live — the compiler reports a missing branch. Reference the Gentzen OR-rules slide: “That compile error IS ∨E: you cannot draw a conclusion from a disjunction without discharging every variant.”
2. `Result<T>` with `flatMap` only — no `getValue()`. “To get the value out, you must supply a handler for both `Ok` and `Err`. There is no escape hatch. This is OR-elimination applied to error handling: the compiler requires both branches.”
3. The bad demo — constructing a `Capture` without an `Authorization` still compiles (closed at Stage 5).

**Structural enforcement — code not written:**
`default:` branches that silently swallow forgotten cases. Guard clauses that check “is this variant handled?” — the compiler now requires it. Defensive null-checks at every constructor call site — `Result<T>` makes the error path part of the return type; there is no program that silently ignores it.

**Genericity — code not written:**
Java records generate `equals`, `hashCode`, and `toString` for every product type — no hand-written implementations, no drift. Sealed interfaces enforce variant exhaustiveness for any discriminated union — one language mechanism, infinite domains. `Result<T>` is written once; `flatMap` works for any domain type.

**Tests deleted:**
Tests that check “did we handle all risk levels?” Gone — the compiler enforces it at every switch site. Tests that check “can we construct an invalid PaymentMethod?” Gone — the sealed type has no invalid constructor. Tests that check “did we handle the error path from this constructor?” Gone — `Result<T>` makes ignoring it a compile error.

**Close the loop on Bob's branch story — partially:** “Bob can no longer forget the Medium case. The compiler requires it. But the root cause is still present — the risk level doesn't flow into the authorization step's type, so the wrong approval method can still be chosen. That closes two stages from now.”

**Tests still required** (first item is what the next stage closes):

1. *(Stage 5 closes)* Test lifecycle ordering — `new Capture(...)` without a prior `Authorization` still compiles.
2. *(Stage 6 closes)* Test the right authorization method for the risk level.
3. *(Stage 6 closes)* Test boundary constraints.
4. *(Stage 7 closes)* Test correct protocol variant selection.

---

### Stage 5: Phantom-Type Typestate — lifecycle state in the type parameter

**Type-theoretic position:** λω (System Fω — second axis of the lambda cube: type constructors, types parameterized over types). `Payment<S>` is a type constructor: a type-level function from state-type to lifecycle-type. The phantom type parameter is a proof term in the type — `Payment<Authorized>` IS the evidence that authorization occurred, not just a name that happens to be used after authorization. Stage 1 already enforced a primitive lifecycle sequence via smart constructors. Stage 5 makes the lifecycle grammar visible as an indexed type family — and sets up the risk-level indexing that Stage 6 requires.

**What this rung adds:** the lifecycle state is now a type parameter on a single unified class. `Payment<Initiated>`, `Payment<Authorized>`, `Payment<Captured>` are the same class with different phantom type arguments. The factory method signatures form a type-level grammar of legal transitions: `authorizeAuto(Payment<Initiated>) → Payment<Authorized>`, `capture(Payment<Authorized>) → Payment<Captured>`. The state is in the type — not in the class name, not in a runtime flag. Stage 4 (records) had public constructors, reopening the fabrication gap from stage 1; `Payment<S>` closes it again with private constructors on the unified class. What stage 5 does NOT close: per-flow binding. `capture(Payment<Authorized>)` accepts any `Payment<Authorized>` regardless of which concurrent flow produced it — Java's phantom generics carry no flow identity.

**In the demo, show:** the `Payment<S>` signature family. Show `demo4_TypestateCompileErrors()`. Then show the bad demo: `authorizeAuto` called on a medium-risk initiated payment — it compiles, audit trail has no 3DS entry.

**Structural enforcement — code not written:**
Runtime state guards (“has this payment been authorized?”), defensive assertions in lifecycle methods, error handling for impossible state violations. There is no program that captures before authorizing — so there is no error path to guard.

**Genericity — code not written:**
`Payment<S>` is one class that covers all lifecycle stages — without phantom generics you would write `InitiatedPayment`, `AuthorizedPayment`, `CapturedPayment`, `RefundedPayment` as four separate classes, each duplicating the order and audit-trail fields, each needing its own conversion logic. The phantom parameter collapses all of that into one generic type with one definition of every shared field.

**Tests deleted:**
Tests for capture-before-authorize, refund-before-capture, double-authorization — all gone. These transitions are no longer expressible programs.

**Name the encoding friction honestly:** the concept is right and the pattern is portable. The verbosity of static factory methods and noisy phantom-parameter error messages is the cost of encoding this at the available expressivity level.

**But be precise about why the next rung is different.** What changes at Stage 6 is not merely that the same ideas are more concise. Some guarantees at Stage 6 are not expressible in Java at all — not verbosely, not at all. Java has no match types, no refined types, and no path-dependent types. The risk level flowing into the authorization approval type (`Approval[R <: Risk]`) is a guarantee Java's type system cannot state. This is a genuine increase in what the compiler can check, not a syntactic convenience.

**Close the loop on Charlie's story here — for the Java stages.** Stage 1 used smart constructors to enforce the lifecycle sequence: no real path to `Capture` without a real `Authorization`. Stage 5 makes that guarantee visible in the type: `Payment<Authorized>` IS the proof that authorization happened. Say explicitly: "The type parameter is the state. There is no program at this rung that holds a `Payment<Captured>` without passing through `Payment<Authorized>` first. You can delete those lifecycle-ordering tests." Note honestly that per-flow binding remains open — `capture` accepts any `Payment<Authorized>` — and that this requires path-dependent types to close.

**Tests still required** (first item is what the next stage closes):

1. *(Stage 6 closes)* Test that the right authorization method is called for the risk level — `authorizeAuto` on a medium-risk `Payment<Initiated>` compiles; the risk level is not in the type.
2. *(Stage 6 closes)* Test boundary constraints — negative quantities still reach the service.
3. *(Stage 7 closes)* Test correct protocol variant selection for a runtime risk assessment — the protocol type cannot be computed from a runtime risk value; a closed ADT is used to select among pre-declared variants at runtime.
4. *(Not closed within Java)* Test per-flow binding — a `Payment<Authorized>` from flow A can be passed to flow B's `capture` call without a type error.

---

### Stage 6: Match Types, Refined Types, and Session Types

**Type-theoretic position:** bounded λω / System Fω + type families — significant movement on two axes, but not yet the third. Match types are type-level functions: types computed from types at compile time. Refined types approach types-from-values but only for compile-time-known literals and type-level predicates — not full runtime-value-to-type computation. Scala 3 uses both the polymorphism axis (λ2 / System F) and the type-operator axis (λω / System Fω) with considerably more power than Stage 5, but the third axis — types whose shape is computed from arbitrary runtime values — remains Stage 7’s exclusive contribution. Session types are fragments of Girard’s linear logic encoded via match types and path-dependent evidence.

**Covariance footnote:** `Approval[+R <: Risk]` carries a `+` because `Approval` only appears in output position — it produces evidence but never consumes R. Covariance is sound but is not load-bearing for the safety guarantee. The guarantee comes from `authorize[R <: Risk]` pinning R through inference: passing `AutoApproved : Approval[LowRisk]` to a context requiring `Approval[MediumRisk]` infers `R = LowRisk` and fails the type-check. The `+` just allows `Approval[LowRisk]` to be stored in an `Approval[Risk]` collection.

**Narrative role:** this stage crosses a threshold, not just a boundary. Java’s type system has a ceiling — and we have shown it honestly. Some guarantees we care about are not expressible in Java at all: not verbosely, not with enough boilerplate, simply not. Match types, refined types, and path-dependent types require a type system that can compute types from other types at compile time and can carry value predicates as part of the type itself. Scala 3 has that power. This stage demonstrates it, culminating in session types where duality makes client/server protocol drift a compile error.

**Earn the transition.** Before the first line of Scala, say:

> "We have pushed Java as far as it goes. That is further than most people expect — sealed types, phantom generics, explicit lifecycles. But there are guarantees we still need tests for that Java cannot encode. Not because Java is wordy — because its type system cannot state them. Approval indexed by risk level, so the wrong authorization method is a compile error. A type that carries the predicate ‘this integer is positive’ rather than just checking it. Types computed from other types at compile time. These require more expressive power. This is what that looks like."

**Main message:** at this expressivity level, phantom indexing, refined types, match types, path-dependent types, and compiler-derived evidence are all first-class. Each removes a class of bug that Java could not encode structurally. Session types and duality are the culmination: an entire protocol’s correctness is a compile-time proof, for both sides simultaneously.

Recommended structure for the eight-minute live slot:

#### Part 1: The toolkit (2–3 min, with IDE)

For each feature: show the mechanism, show the code that fails to compile, name the bug it eliminates. Use the IDE to reveal the red squiggle; say the bug class out loud; say “you can delete that test.”

- **Phantom type indexing (`Approval[R <: Risk]`)**: `authorize(mediumOrder, AutoApproved)` produces `AuthorizedPayment[LowRisk]`; sending it through the medium-risk channel gives `Found: AuthorizedPayment[LowRisk], Required: AuthorizedPayment[MediumRisk]`. Bob’s skip-3DS bug is unrepresentable. Test deleted.

  **Live script for this moment:** Navigate to `demos/PaymentDemo.scala`, `serverMediumRisk`, line 115. Change `ThreeDSApproved(proof)` to `AutoApproved`. The error appears on `ch4.send(authorized)` on the next line — hover and read it aloud: "Found: `AuthorizedPayment[LowRisk]`, Required: `AuthorizedPayment[MediumRisk]`." Say: "AutoApproved carries LowRisk evidence only. The medium-risk channel requires a payment authorized at MediumRisk. The compiler refuses. Bob cannot skip 3DS." Revert with ⌘Z before continuing.
- **Refined types (`PositiveInt = Int :| Positive`)**: `0.refineUnsafe[Positive]` fails at compile time for literals; `OrderLine(sku, price, rawInt)` fails because plain `Int ≠ PositiveInt`. Boundary validation test deleted.
- **Path-dependent types (`CanSend[P]#Msg`)**: `ch.send(“wrong type”)` fails — message type is an associated type on the evidence, not a free parameter. Wrong-payload and wrong-direction tests deleted.
- **Compiler-derived evidence (`=:=`, `finish()`)**: `ch.finish()` before `End` fails — compiler cannot prove `P =:= End`. The `summon[Dual[...] =:= ...]` calls in Derivation.scala *are* compile-time tests: if they type-check, the contract is proven at every build. Protocol-ordering test deleted.
- **Opaque types (`AuthCode`, `CaptureId`, `RefundId`)**: `val id: CaptureId = someAuthCode` is a type error. Lifecycle-identifier-confusion test deleted.

**The positive affordance — types as scaffolding for change (~20 sec):**
At this expressivity level the type system becomes a collaborator, not just a gatekeeper. Once scaffolding is in place, adding a new state or protocol step is compiler-guided work: a `???` placeholder in Scala 3 carries the expected type, and the compiler tells you exactly what you still need to provide. Idris 2 has typed holes as a first-class development workflow. Rust's `todo!()` carries the same guarantee. Add a new payment lifecycle stage and the type system propagates the obligation to every handling site. The compiler does not just reject the invalid program — it tells you what to write next. This is why refactoring into an expressive type system gets easier as the scaffolding grows, not harder.

**Structural enforcement — code not written:**
Runtime state guards in the channel API. Runtime checks for message ordering. Runtime assertions that a channel is closed correctly. All replaced by compile-time proof obligations.

**Genericity — code not written:**
`Channel[P]` works for *any* protocol `P` — one channel implementation instead of one per protocol variant. `Dual[P]` is computed for any `P` by the match type — the inverse protocol is not hand-coded per variant. `interpret[F[_]: Functor, A]` is one catamorphism for any functor algebra — write `describe` and `analyze` as plain `F[A] => A` functions; the recursive traversal is written once. `CanSend[P]` evidence derives the message type for any send step — the channel API is defined once, not per protocol.

#### Part 2: Session types and duality (3 min, with IDE)

This is where the toolkit features combine — and where duality earns its place as a correctness mechanism.

Show `LowRiskProtocol`, `MediumRiskProtocol`, `HighRiskProtocol` as precise descriptions of legal conversations. Explain `Channel[P]`: `send` requires `CanSend[P]` (path-dependent), `finish` requires `P =:= End` (compiler proof). Wrong order or wrong direction: compile error.

**Honest linear-types limitation:** Server handlers return `Channel[End]` rather than `Unit` — this signals intent and centralises `.finish()` naturally at the end of each handler. However, Scala 3 lacks linear types: the type system does not enforce that a channel must be used exactly once. You *can* drop a channel without calling `.finish()`, and the compiler will not complain. Calling `.finish()` on a mid-protocol channel IS rejected (no proof that `P =:= End`). But not calling it at all is not prevented. Full enforcement — making a dropped channel a compile error — requires linear types: Idris 2's `UniqueType` or Haskell's `%1 ->`. Name this honestly: "The type system catches wrong-order sends and wrong message types. It does not yet enforce that the protocol is completed. That remaining gap is what linear types are for — and it is part of why Idris 2 and future type-system extensions matter."

Then introduce duality as a specific and important application of match types:

- Server gets `Channel[Dual[P]]` — the compiler computes the dual automatically from the client’s protocol.
- A server that sends when it should receive, or skips a message, does not compile.
- `summon[Dual[LowRiskProtocol] =:= ...]` is a compile-time assertion — if it type-checks, the contract is verified at every build, not just on the specific examples tested.

This is the point where Danielle’s incident becomes structurally unrepresentable for both sides simultaneously.

Duality is important here: it is what makes the client/server contract a compile-time proof rather than a documentation agreement. It is one application of a general mechanism (match types + type equality) that was already doing work in the toolkit section.

**Close the loop on multiple stories here — say each one explicitly:**

- "Bob’s story is done. `Approval[LowRisk]` cannot satisfy `Approval[MediumRisk]`. The wrong authorization method for the risk level is a compile error. Delete that test."
- "Alice’s class of boundary confusion is done. An `OrderLine` with zero quantity cannot be constructed — `PositiveInt` is uninhabited for zero. The predicate lives in the type; no runtime boundary test is needed for this invariant."
- "Danielle’s story is done. Server and client hold `Channel[Dual[P]]` and `Channel[P]` — computed from the same protocol definition. They cannot drift independently."

#### Part 3: Inductive types and catamorphisms (60–75 sec)

Start from what the audience already knows:

> "You already know `List.foldRight`. One traversal; multiple different summaries. Sum the elements as integers one way, stringify them another. Same list structure, two algebras, traversal defined once. That IS a catamorphism — fold generalized to an inductive type. `List` has two constructors — `Nil` and `Cons` — so `foldRight` has two cases. That is the entire pattern."

**On a slide (or spoken aloud, 15 sec):**

```
List(1, 2, 3).foldRight(0)(_ + _)              // Int algebra
List(1, 2, 3).foldRight("")(_.toString ++ _)   // String algebra
```

Two algebras, one traversal, impossible to diverge on the structure.

**Now connect to `PolicyF` (20 sec):**

> "`PolicyF` is that same pattern for a tree. Each variant of `PolicyF` is one constructor of the inductive type — the shape of one policy node. `interpret[F[_]: Functor, A]` is `foldRight` for `PolicyF` instead of `List`: one traversal, defined once. `describe` and `analyze` are two algebras — each says what to produce at one node. Adding a new `PolicyF` variant forces both algebras to handle it; the compiler reports both missing cases simultaneously."

**In the IDE (20 sec):** Navigate to `Rules.scala`. Show `interpret(Interpretations.describe)(policy)` and `interpret(Interpretations.analyze)(policy)` — two calls to one catamorphism. If time permits: add `PolicyF.RequireKYC(next: A)` to the enum and show both `describe` and `analyze` immediately report a missing case.

**Engineering payoff, name it explicitly (15 sec):** "Without `interpret`, you write `describePolicy` and `analyzePolicy` as two separate recursive functions — each containing the full structural switch, both needing to stay in sync forever. A missed case silently diverges. With `interpret`: one structure, one traversal, two algebras. The compiler enforces completeness of every algebra simultaneously."

**If behind schedule — cut to 30 sec:** Say: "You know `List.fold` — one traversal, multiple algebras. `interpret` is that pattern for trees. Add a node type, both algebras must handle it. Divergence test deleted." Skip the IDE entirely.

#### Part 4: The ceiling (30 sec)

The protocol variants are pre-declared at compile time; selection happens at runtime via a closed ADT. The protocol *type* cannot be computed from a runtime value — that requires dependent types. One item remains on the test list.

**Tests still required** (first and only remaining item — what Stage 7 closes):

1. *(Stage 7 closes)* Test that the correct protocol variant is selected for a given runtime risk assessment. The closed ADT selection is correct — but it is runtime logic, not a type-level computation.

---

### Stage 7: Full Dependent Types (Idris 2) — the runtime-to-type bridge

**Type-theoretic position:** λC — the Calculus of Constructions, all three lambda-cube axes simultaneously. This is where the MLTT Π and Σ rules from the theory section run as programs. `protocolDerivedFrom : Order → SessionType` is a Π-type: Π-elimination fires at every call site, propagating the computed type. `assessOrder : Order → (lvl ** Assessment lvl n c)` is a Σ-type: a dependent pair where `lvl` is both a returned value and an index into the type of the second component. Reference the formal slides explicitly: "This is not a metaphor for those rules — these ARE those rules, running."

**What this rung adds:** types that depend on runtime values. In the current payment example that shows up in two linked places:

- `protocolDerivedFrom : Order n c -> SessionType`
- `assessOrder : Order n c -> (lvl ** Assessment lvl n c)`

The protocol shape is computed from runtime order facts, and the approval witness required for authorization is computed from the same runtime classification.

**In the demo, show:** `protocolDerivedFrom order : SessionType`, then `authorize : Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c`. That pairing is the payoff: the communication procedure and the required evidence are both derived from runtime values.

**Reference the MLTT Σ-type slide explicitly at this moment:** "Earlier I showed you the Σ-formation rule: a type that bundles a value together with a proof that depends on that value. The `(lvl ** assessment) = assessOrder order` dependent pair in `runOrderScenario` is that rule running. `lvl` is the risk level — a value returned at runtime. `Assessment lvl n c` is its type, computed from `lvl`. This is not a metaphor for the Σ rule. These are the Σ-introduction and Σ-elimination rules, executing as a program." Navigate to `Main.idr` line 274 to show `let (lvl ** assessment) = assessOrder order`.

**Structural enforcement — code not written:**
The `ProtocolVariant` ADT and its `fromSnapshot` selection function. The runtime dispatch that picks a channel type from a fixed menu. The bridging code that translates a runtime classification into “now use this pre-declared protocol type” disappears.

**Genericity — code not written:**
The current Idris demo still case-splits by risk level and refundability to keep the runnable example easy to read, but it no longer needs a bridge ADT between runtime analysis and type-level protocol selection. `protocolDerivedFrom` and `assessOrder` are ordinary total functions over runtime orders, and the compiler tracks the resulting protocol shape and approval witness requirements.

**Tests deleted:**
Tests for “did we select the correct protocol variant for this risk level?” — there is no selection. The type is computed. The last item on the test list is gone.

**Say explicitly that this is the end of the climb:**

The later stages are not just “using types to catch bugs at compile time” — they are using types to *state and check properties of interacting programs*.

**Return to the opening stories — closing the loop:**

- Alice’s boundary class: an `OrderLine` with zero quantity cannot be constructed — `PositiveInt` is uninhabited for zero. The invalid state has no valid program; the boundary test is gone.
- Bob’s skipped-3DS medium-risk path: impossible — the protocol type for a medium-risk order requires the 3DS step structurally.
- Charlie’s out-of-order capture: impossible — the state transition is not an expressible program.
- Danielle’s protocol drift: impossible — server and client types are computed from the same function; they cannot drift independently.

Not “types are cool.” “These specific on-call incidents have no valid program at this rung.”

## Timing Guidance For The Practical Section

Rough pacing for the `28-30 minute` practical block:

- `2.5 min` JavaScript + simple Java
- `1.5 min` generics (~20 sec mention of function pipelines — no live demo)
- `5.5 min` records/sealed unions
- `6 min` advanced Java typestate
- `8 min` Scala 3
- `6 min` Idris 2

This is intentionally back-loaded. Records/sealed and typestate are the Java payoff; Scala 3 is the expressiveness threshold; Idris 2 is the intellectual close.

Stage 0+1 is the most compressed practical slot: one JS bad demo is enough (not both), and the test list should be named by category rather than enumerated in full. The point is that every boundary requires a test — not an exhaustive inventory.

Stage 3 (function pipelines) is in the repository and available for questions but does not get a live demo slot. Stage 2 makes the architectural point; Stage 3's 20-second mention is enough to acknowledge it exists.

## Slide And Demo Strategy

The talk should alternate between three kinds of slides:

- incident/problem slides,
- structure/map slides,
- code/demo slides.

Do not show too much code at once. The audience should always know what they are supposed to look at.

Recommended rule:

- one slide or terminal view should make one point.

For a mixed-experience Java audience, prefer:

- code snippets with short signatures over long files,
- side-by-side “before / after” comparisons,
- one highlighted illegal move per stage,
- one sentence of theoretical framing attached to each step.

Examples:

- a slide with only the four incident summaries,
- a slide with only the lambda cube and the few labels you need,
- a terminal view showing only the function signature that encodes the typestate transition,
- a terminal view showing only the protocol derivation point in Idris.
- an IDE hover showing the exact inferred or path-dependent type that carries the guarantee,
- a short log trace showing the runtime behavior that the static structure permits.

## Tone Management

This talk can easily go wrong in either of two directions:

- sounding like “your language is bad and you are foolish,”
- sounding like “look at my exotic theorem prover.”

Avoid both.

Preferred tone:

- these bugs happen to competent teams,
- richer type systems are engineering tools, not moral badges,
- each language level has a sensible domain of use,
- the question is not purity, it is whether the invariant matters enough to encode.

For Java meetup participants from different industries, repeatedly translate abstract claims into ordinary engineering value:

- fewer invalid states crossing boundaries,
- fewer “just be careful” comments,
- fewer branch-specific regressions,
- fewer tests whose sole purpose is catching nonsense states,
- better sleep for people on call.

## Suggested Recurring Phrase

It may help to repeat a stable contrast:

- “At this stage, the invariant is documented.”
- “At this stage, the invariant is tested.”
- “At this stage, the invariant is encoded.”

That gives the audience a memorable ladder.

Another useful repeated phrase:

- “What invalid programs are still expressible here?”

And one more:

- “What can we now state and check that we could not one rung ago?”

That keeps the focus on engineering value rather than syntactic cleverness.

## Closing Section

The close should do three things:

1. return to the opening incidents,
2. summarize the climb,
3. gesture beyond the current horizon without diluting the practical win.

## Closing Script Shape

Recommended flow:

- remind the audience of the on-call stories,
- say that none of those failures required bad people or bad intentions,
- say they came from a mismatch between business invariants and what the language/design level could express,
- summarize the progression as a steady removal of invalid expressible programs,
- summarize it also as a steady increase in what the compiler can be made to check for us,
- end on the Idris payment example as the strongest current expression of that idea in this repo.

Before the “further horizon” glimpse, name one more step that is still within Scala 3:

**Scala 3 Capture Checking (Caprese — experimental)**

Capture checking makes capabilities — file handles, database connections, async boundaries, mutable references, IO effects — trackable in the type of every value that uses them. A function that closes over a file handle carries that capability in its type; the compiler verifies it cannot outlive the handle's scope.

Classes of errors made impossible:
- **Use-after-close**: a `FileHandle` or `Connection` closed in one branch cannot be accessed after release — the capability is gone from the type.
- **Resource leaks**: a managed resource cannot silently outlive its scope; the compiler proves every acquisition is paired with a release.
- **Effect leaks**: an IO or mutation capability cannot escape the controlled scope that owns it; effectful closures cannot masquerade as pure values.
- **Capability escapes across async boundaries**: a capability acquired on one execution context cannot be stored in a structure that outlives the context.
- **Effect-unsafe code typed as pure**: a function that closes over an IO capability cannot be typed as `() -> A`; the capability appears in the signature.

The payoff for the audience: **direct, imperative-style code — no monadic wrappers, no `IO[A]` threading — and the compiler still proves effect safety**. The same ideas that required a monad stack in Haskell or `cats-effect` in Scala 2 become structurally enforced by the type system without changing the code's shape.

This sits one step beyond what the session-types demo shows, and it is still within Scala 3. It is the right “next thing to explore” pointer for a Java meetup audience.

**AI-assisted development — a contemporary dimension (30–45 sec):**
Before the “further horizon” glimpse, name this once. As AI coding assistants accelerate code generation, the volume produced often outpaces careful human review. At a language whose type system checks what the Scala 3 and Idris 2 examples show, that speed asymmetry matters less: an incomplete protocol step, a skipped lifecycle transition, or a boundary violation cannot compile — regardless of whether the author was human or a language model. Early comparisons suggest AI agents perform similarly across typed and untyped codebases on standard benchmarks, and at somewhat higher cost in the typed case — but those benchmarks rarely exercise the invariants where expressive types earn their keep, and they do not measure the asymmetry between generation speed and review capacity. The practical point is modest but real: the type checker applies the same standard to every line of code, at every generation speed. Proof assistants such as Lean go one step further still — the machine not only generates code but discharges the proof obligations itself. That is part of why the “further horizon” matters.

Then give a short “further horizon” glimpse — two to three sentences only:

- Lean for proof-heavy verification and theorem proving,
- Cubical Agda for richer equality and constructive reasoning,
- perhaps a brief nod to homotopy type theory and topos-theoretic perspectives as examples of how far the landscape extends.

That ending should be aspirational, not obligatory. The audience should leave with a practical win, not a feeling that everything short of full theorem proving is worthless.

In the 45-minute version, the Capture Checking note should be thirty seconds; the AI coding aside should be thirty to forty-five seconds; the “further horizon” glimpse should be thirty seconds. Together: under ninety seconds.

## What The Audience Should Remember

If the talk works, a week later the audience should remember roughly this:

- some production pain is caused by invalid states being representable,
- stronger types are a practical way to remove those states,
- the history of logic and type theory explains why these tools exist,
- stronger type systems are also understandable as stronger checking disciplines,
- at the level of match types, refined types, phantom indexing, and session types — as in Scala 3 — nearly all the invariants we care about in practice become enforceable,
- Scala 3 Capture Checking goes one step further: capabilities (IO, mutation, handles) are tracked in the type, so resource leaks, effect leaks, and use-after-close become type errors — without monadic wrappers,
- full dependent types — as in Idris 2 — express the final step: the protocol's type is computed from the runtime risk value, not selected from a pre-declared menu,
- at higher expressivity levels the type system becomes a collaborator: `???` and typed holes guide you toward correct implementations, and changing a type cascades obligations to every site the compiler now requires to handle it — refactoring becomes conversation rather than grep,
- in the age of AI-assisted development, expressive types are not just a benefit for human reviewers — the type checker applies the same structural constraints to every line of code regardless of generation speed or origin, and proof assistants like Lean can discharge proof obligations automatically,
- the right question is not “is this fancy?” but “is this invariant expensive enough to encode?”

## Speaker Preparation Notes

Before giving the talk, prepare these transitions explicitly:

- from incidents to theory,
- from theory to the first code example,
- from Java typestate to Scala 3 — this is the critical transition: not "same ideas, cleaner syntax" but "a genuinely higher rung; some guarantees here are not expressible in Java at all." Earn it by naming what Java cannot do, then showing it done.
- from Scala 3’s ceiling to Capture Checking as the accessible next step,
- from Capture Checking to Idris 2’s payoff (dependent types, not just tracked capabilities),
- from the final demo to the closing horizon.

Those transitions are where talks like this usually either come alive or lose the room.

Also prepare a short version and a long version of the theory section:

- default version: `6 minutes` (required to stay on schedule)
- extended version: `9-10 minutes` (only if cold open came in under 4.5 minutes — do not extend otherwise)

**Rehearsal is not optional for this schedule.** The 45-minute target is achievable but leaves almost no per-section slack. Plan at least two full dry runs with a timer before the live talk. First delivery without a rehearsal should be budgeted at 50 minutes; second delivery (after timing the first) should land near 45. Know your hard-cut version of every section before you walk in.

Also prepare a hard-cut version of each practical stage:

- one sentence,
- one code signature,
- one surviving bug,
- one new guarantee.

If you start slipping on time, cut detail rather than cutting the final Scala/Idris payoff.

## Coordination With The Implementation Plan

As you implement each example stage, verify two things:

- the code actually supports the bug/story claimed here,
- the next stage actually removes that bug in a visible way.

If either is false, fix the implementation before refining the slides.
