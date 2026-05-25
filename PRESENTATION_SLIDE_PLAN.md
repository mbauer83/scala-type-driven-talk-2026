# Presentation Slide Plan: Making Invalid Programs Impossible
## A Type-Driven Journey from Russell to Production Engineering

---

## Deck Overview

- **Total slides:** 36
- **IDE/terminal segments:** 8
- **Hard runtime:** 45 minutes (Q&A is separate)
- **Format:** 16:9, dark background, white text, monospace code font
- **IDE setup:** dark theme, syntax highlighting on, Scala/Java language servers running, all files pre-opened in tabs

### Colour Conventions

| Element | Colour |
|---------|--------|
| Normal text | White on dark |
| Code | Monospace, syntax-highlighted |
| "Bug still compiles" line | Red highlight / red underline |
| "Test deleted" annotation | Green strikethrough or ✓ |
| Incident callbacks (named chips) | Alice = blue, Bob = orange, Charlie = green, Danielle = purple |
| Lambda-cube stage labels | Yellow/gold |
| Quote blocks | Italic, slightly indented, lighter grey |

### Timing Reference

| Section | Clock | Duration |
|---------|-------|----------|
| Personal intro | 0:00–0:30 | 0:30 |
| Cold open | 0:30–5:30 | 5:00 |
| Theory | 5:30–11:30 | 6:00 |
| Stages 0 + 1 | 11:30–14:00 | 2:30 |
| Stages 2 + 3 | 14:00–15:30 | 1:30 |
| Stage 4 | 15:30–21:00 | 5:30 |
| Stage 5 | 21:00–27:00 | 6:00 |
| Stage 6 | 27:00–35:00 | 8:00 |
| Stage 7 | 35:00–41:00 | 6:00 |
| Conclusion | 41:00–45:00 | 4:00 |

### Hard-Cut Rules (if running behind)

Apply these in order — never cut Stage 7:

1. **Theory overran by >1 min:** Cut the MLTT slide (S12) entirely. Say once: "Π and Σ types are how Idris 2 expresses these ideas — I'll show them running in Stage 7."
2. **Stage 5 overran:** Cut the "what's still open at this rung" bullets in S22; just say "Charlie's bug is closed; risk-level-in-the-type and boundary refinement come at Stage 6."
3. **Stage 6 overran by >1 min:** Cut Feature 6 (catamorphisms) entirely from IDE Segment 6a. Keep session types and duality. Say: "The repo has a policy DSL using the same catamorphism pattern — `List.fold` for trees instead of lists."
4. **Never cut Stage 7.** If you are 2 min behind at 35:00, cut 1 min from the Stage 6 ceiling discussion (S28) and shorten the conclusion.

---

## Section 1 — Personal Introduction

### Slide 1 — Title
**Clock target:** 0:00–0:30
**Type:** Title

**Visual content:**
```
Making Invalid Programs Impossible

A type-driven journey from Russell to production engineering

[Your name]
[Event / date]
```

**Speaker notes:**
Personal introduction (handled separately from this guide — 30 seconds). Establish who you are and why you care about this. Close with: "This talk is about a question I think about every time I'm on call."

**IDE / terminal:** None.

---

## Section 2 — Cold Open: Four On-Call Stories

### Slide 2 — Alice: The Stringly-Typed Boundary
**Clock target:** 0:30–1:45
**Type:** Incident

**Visual content:**
```
Alice walks into a question from accounting.

  An internal admin tool exports a CSV with a lineTotal column.
  A Node.js import job aggregates those rows to build draft invoices.

  total = row1.lineTotal + row2.lineTotal
         "4500"          "1500"
       = "45001500"               ← string concatenation, not addition

  Staged invoice total:  ₤45,001.50
  Actual invoice total:  ₤60.00
```

Small footnote: `*` would not have caught this — JS coerces strings for `*`, `/`, `-`. Only `+` silently concatenates.

**Speaker notes (75 sec):**
"Alice's morning starts with a Slack message from accounting. An invoice in the overnight staging batch has a total that's wrong by a factor of nearly a thousand. The CSV parser had handed the code values as strings. The aggregation used `+` to sum them, and JavaScript's `+` on two strings is defined — it just concatenates. The job ran clean. The invoice was caught in staging because someone in accounting noticed before the batch was released. The bug isn't stupidity. It's a type system that has no way to express the difference between a string that looks like a number and an actual number."

**IDE / terminal:** None.

---

### Slide 3 — Bob: The Forgotten Branch
**Clock target:** 1:45–3:00
**Type:** Incident

**Visual content:**
```
Bob is handling an incident.

  Checkout service classifies orders: Low / Medium / High risk.
  Medium-risk card orders must complete 3DS before authorization.

  Original code (two risk levels):
    if (risk != HIGH) fastPath()
    else              manualReview()

  Risk engine gains a MEDIUM level.
  Medium-risk orders silently fall through to fastPath().
  3DS skipped. Liability shift lost.
```

**Speaker notes (75 sec):**
"Bob's team added a medium-risk tier to their fraud engine. The original branching was written when there were only two outcomes — low and high. `if risk != HIGH, take the fast path` was reasonable code at the time. When medium was added, the condition still held for medium orders. They hit the fast path. No 3DS. The liability shift went to the merchant. The code compiled — it had always compiled, and there was no obvious reason it should have stopped. That's the real problem: there's nothing in the language that requires anyone to revisit existing branching when a third risk tier appears. The compiler had no opinion."

**IDE / terminal:** None.

---
### Slide 4 — Charlie: The Illegal State Transition
**Clock target:** 3:00–4:15
**Type:** Incident

**Visual content:**
```
Charlie's team owns the internal refund-approval workflow.

  Refund request lifecycle:
    Requested → UnderReview → Approved → Executed

  Only UnderReview refunds may be Approved.
  Only Approved refunds may be Executed.

  An operator-tooling shortcut — "force execute" —
  fetches a refund by id and calls executeRefund(refund)
  without checking the refund's current state.

  A Requested refund (never reviewed) reaches the payment
  rail and posts back to the customer's card.
```

**Speaker notes (75 sec):**
"Charlie's team handles the internal refund-approval workflow. Refunds run through Requested, UnderReview, Approved, Executed — only an Approved refund is supposed to reach the payment rail. There's an operator-tooling shortcut for emergencies, and that shortcut fetches a refund by id and calls executeRefund without re-checking the state. A refund still in Requested goes out anyway. Three hours of log archaeology to figure out what happened. The state machine existed in the comments and the wiki and in three developers' heads. It did not exist in the type system. Charlie wasn't reconstructing a bug — he was reconstructing a contract that the language had never enforced."

**IDE / terminal:** None.

---

### Slide 5 — Danielle: The Protocol Drift
**Clock target:** 4:15–5:15
**Type:** Incident

**Visual content:**
```
Danielle is debugging.

  KYC onboarding service: client uploads documents for compliance review.
  For large payout limits, compliance now requires an extra evidence step.

  Client assumes:   Upload → Evidence → FinalConfirmation
  Server now needs: Upload → Evidence → EvidenceAccepted → FinalConfirmation

  Integration tests miss the exact branch.
  Large uploads timeout in production.
  Small uploads succeed. The bug is invisible in CI.
```

**Speaker notes (60 sec):**
"Danielle's bug was the hardest to see. The client and server were both correct according to their own contracts. The contracts had drifted apart. The server added a step; the client didn't know. Integration tests covered the common path. The new path only triggered for large payout limits. This ran fine for three weeks before someone tried a large upload."

**IDE / terminal:** None.

---

### Slide 6 — The Pattern
**Clock target:** 5:15–5:30
**Type:** Transition

**Visual content:**
```
In each case, a program was able to express something
the business rules forbade.

In this talk we look at how types let us shrink
that gap — one class of error at a time.

By the end, these scenarios aren't "well tested" —
the illegal states can't be written down.
```

**Speaker notes (15 sec):**
"None of these came from incompetence. They came from a mismatch between what the business required and what the language could enforce. For closing that gap, we have a toolkit — built up over roughly two and a half thousand years. We'll spend a few minutes on history and motivation, and then for the rest of the talk we'll look at how to cash that out in actual code."

**IDE / terminal:** None.

---

## Section 3 — Theory: Six Minutes of Necessary History

### Slide 7 — A Toolkit Built Over Two and a Half Thousand Years
**Clock target:** 5:30–7:00
**Type:** History (Beat 1)

**Visual content:**
Timeline or stacked list. Each name gets one short label:

```
Aristotle (4th c. BCE)
  — Valid inference from structural form alone.
    Replace content with variables; the form holds or it doesn't.

Leibniz (17th c.)
  — Pushes the idea further: if valid inference is purely
    structural, in principle it could be performed by a machine.
    Sketches a universal formal notation and a "calculus of
    reasoning" — mechanised inference, two centuries early.

Boole / DeMorgan (1847)
  — Logic as algebra: AND, OR, NOT with strict laws.
    Relations composed as first-class objects.

Frege (1879), Peano, Russell + Whitehead
  — Principia Mathematica: an attempt to ground all of
    mathematics in a single formal system.
    Syntax (token manipulation) clearly separated from
    semantics (meaning).
```

Bottom line (large, bold):
> "Formal structure restricts what can be said — so that what *can* be said can be trusted."

**Speaker notes (90 sec):**
"The thread we'll follow is one specific question: what does it take to make *valid inference* explicit — the question of whether a conclusion really does follow from its premises? Aristotle gave the first clean answer: validity comes from the structural form of an argument, not its content. Replace the words with variables; the form holds or it doesn't. Leibniz, two thousand years later, pushed this further — if valid inference is purely structural, then in principle it could be reduced to calculation, performed by a machine. He sketched both the notation and the calculus he thought would do it. The programme failed in his lifetime, but the idea is the line we're still walking. Boole and DeMorgan turned propositional logic into algebra. And at the turn of the 20th century, Frege, Peano, Russell and Whitehead tried to put all of mathematics inside a single formal system. At every step, the move is the same: tighten what counts as a valid step, so the invalid steps have nowhere to hide."

**IDE / terminal:** None.

---
### Slide 8 — The Crisis and the Fix
**Clock target:** 7:00–8:30
**Type:** History (Beat 2)

**Visual content:**
```
Russell (1901)
  "The set of all sets that do not contain themselves."
  Self-reference destroys logical consistency.
  Cantor's principle — proven inconsistent.

The fix: Types
  A strict hierarchy. A predicate (a property of values)
  cannot operate on objects at its own level. Self-reference
  is blocked structurally.
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Hilbert's requirements for a perfect proof system
(stated in parallel with this debate, not after it):
  Consistent  — never derives ⊥
  Sound       — ⊢  ⟹  ⊨   (provable ⟹ true)
  Complete    — ⊨  ⟹  ⊢   (true ⟹ provable)

Gödel (1931): For any consistent system strong enough
  to encode arithmetic — Completeness is impossible.
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pivot: drop global completeness.
       protect Soundness and Consistency.
```

Bottom line:
> "Types were invented to stop logic from consuming itself. The safety boundary your compiler enforces has a century of mathematical necessity behind it."

**Speaker notes (90 sec):**
"Russell found a fatal flaw in the attempt to unify mathematics. The set of all sets that do not contain themselves — does it contain itself? If yes, it shouldn't. If no, it should. The contradiction lives inside any system that allows unrestricted self-reference. Types were invented as the fix: a strict hierarchy that makes this self-reference structurally impossible. By a proposition I mean a statement that's either true or false; by a predicate, a property of values — the building blocks Frege made precise. Working in parallel with Russell, Hilbert wrote down three requirements he wanted of any formal system: consistent, sound, and complete. Gödel proved in 1931 that for anything strong enough to express arithmetic, completeness is impossible — there will always be true statements the system cannot prove. So the field stopped chasing completeness, and focused entirely on soundness and consistency. That is exactly what your type-checker was built to guarantee."

**IDE / terminal:** None.

---

### Slide 9 — The Computational Convergence
**Clock target:** 8:30–10:00
**Type:** History (Beat 3)

**Visual content:**
```
Church / Turing (1936)
  — Formalise execution as reduction.
    Simply Typed Lambda Calculus: types restrict inputs,
    guarantee termination where logical safety is required.

Gentzen (1935)
  — Logic as local interface.
    Every connective defined by: how you BUILD it (introduction)
    and how you USE it (elimination).
    Cut elimination = compiler dead-code removal.

Curry-Howard (1969)
  — Proposition  =  Type
    Proof         =  Program
    Running       =  Simplifying a proof
    Writing code that compiles  =  Constructing a proof.

Martin-Löf (1972)
  — Dependent types: return type computed from argument value.
    ∀  →  Π-type (dependent function)
    ∃  →  Σ-type (dependent pair: value + proof)

Coquand (1988): Calculus of Constructions — the engine
  behind Coq, Lean, Agda, Idris.
```

Bottom line:
> "When you write a type, you state a proposition. When the compiler accepts your program, it has checked your proof."

**Speaker notes (90 sec):**
"Church and Turing formalised computation in 1936. Church's typed lambda calculus made it safe — types restrict what you can pass to a function and guarantee it terminates. Gentzen two years earlier had reframed logic itself: every logical connective is defined by how you build it and how you use it — introduction rules and elimination rules. Howard later showed these two worlds are the same world. A proposition IS a type. A proof IS a program. Running a program IS simplifying a proof. Martin-Löf took this further: types can now depend on runtime values — the return type is computed from the argument. Coquand compressed this into the Calculus of Constructions, the engine behind every modern proof assistant. The punchline: writing code that compiles is structurally identical to constructing a proof. Every stage of this talk is a system that can check a stronger class of proofs."

**IDE / terminal:** None.

---
### Slide 10 — Gentzen: Logic as Interface
**Clock target:** 10:00–10:30
**Type:** Formal

**Visual content:**
Top of slide, the motivating idea, large:
> "Every logical connective is defined entirely by its interface:
>  how you BUILD it (introduction), and how you USE it (elimination).
>  Nothing else."

Then the rules for OR (disjunction), as the worked example:
```
Introduction rules (building a disjunction):

  A                    B
──────  (∨I₁)       ──────  (∨I₂)
A ∨ B               A ∨ B

Left(proofA) : A∨B      Right(proofB) : A∨B


Elimination rule (using a disjunction — the exhaustive match):

          [A]   [B]
           ⋮     ⋮
  A ∨ B   C     C
  ─────────────────  (∨E)
          C

  match x { case Left(a)  => C
             case Right(b) => C }


Missing the Right branch = you have not supplied [B]→C.
The compiler cannot apply ∨E.  Compile error.
```

Bottom (smaller text):
> "Two structural primitives carry most domain data in this talk:
>  records (products — all fields at once) and sealed types (sums —
>  exactly one variant). Stages 4 onwards add the rules and protocols
>  layered on top."

**Speaker notes (35 sec):**
"Gentzen's insight: a logical connective isn't a primitive thing with semantics attached — it's *defined* by how you build it and how you use it. Two rule sets, one connective. For OR: you build it by supplying a proof of either side; you use it by handling every case. That use-rule is what we'll keep meeting — first as exhaustive pattern matching in Stage 4. Two primitives are going to do most of the heavy lifting for the domain data in this talk: records, which are products — all fields present at once — and sealed types, which are sums — exactly one variant. The rules and protocols that go on top of that data come later."

**IDE / terminal:** None.

---

### Slide 11 — The Lambda Cube
**Clock target:** 10:30–11:15
**Type:** Map/Diagram

**Visual content:**
A cube diagram with three labelled axes. Stage labels placed on the cube edges/corners:

```
                        λC (Calculus of Constructions)
                       ╱  Stage 7: Idris 2
                      ╱
   System Fω ────────╯  ← Stage 6: Scala 3
   (type operators)    │
         ↑             │
    Stage 5: Java      │
    phantom generics   │
         │             │
   System F ───────────╯
   (generics)
         ↑
   Stage 2: Java generics

   ←────────────────────
   λ→  STLC
   Stage 1: Simple Java
   Origin
```

Three axes labelled:
- **Generics** (terms depending on types) → Stages 2–5
- **Type operators** (types depending on types) → Stages 5–6
- **Dependent types** (types depending on runtime values) → Stage 7 only

Bottom:
> "Stages 1–6 move along the first two axes. Stage 7 crosses into the third. That third axis is not more of the same thing — it is something Scala cannot say at all."

**Speaker notes (45 sec):**
"This is your map for the next 30 minutes. At the bottom-left corner: simply typed lambda calculus, Stage 1 — nominal types, no abstraction over types. Moving right along the generics axis: Java generics and Scala's polymorphism, Stages 2 through 5. Moving up along the type-operators axis: match types, type families, phantom indexing — Scala 3, Stage 6. The top-right corner, the third axis: types whose shape is computed from runtime values. That's Stage 7, Idris 2. That third axis is what makes Stage 7 qualitatively different — not more expressive by degree, but expressing something the other axes cannot."

**IDE / terminal:** None.

---

### Slide 12 — MLTT: Π and Σ Types (Plant the Seed)
**Clock target:** 11:15–11:30
**Type:** Formal (brief)

**Visual content:**
Two compact rule blocks. Keep it visually minimal — speak through it, don't let the audience read it:

```
Π-type (∀ as dependent function):
  Formation:    Γ ⊢ A : 𝒰    Γ, x:A ⊢ B(x) : 𝒰
                ────────────────────────────────
                      Γ ⊢ (Πx:A). B(x) : 𝒰
  Elimination:  f : (Πx:A).B(x)    a : A
                ──────────────────────────
                        f(a) : B(a)          ← return type depends on value

Σ-type (∃ as dependent pair):
  Introduction: a : A     b : B(a)
                ─────────────────
                (a, b) : (Σx:A). B(x)       ← value bundled with its proof
```

Bottom:
> "Idris 2 runs these rules at every call site. I'll show them in action in Stage 7."

**Speaker notes (15 sec):**
"Two rules: Π-elimination — the return type is computed from the argument value. Σ-introduction — a value bundled with a proof that depends on that value. I'll show you exactly what this looks like running in 30 minutes."

**IDE / terminal:** None.

---
## Section 4 — Practical Progression

---

### Slide 13 — The Payment Domain and the Test Spine
**Clock target:** 11:30–12:00
**Type:** Orientation (30 sec; sits between theory section and Stage 0)

**Visual content:**

Top half — payment lifecycle diagram (one line):
```
                                                ┌─ refund (where supported)
   Order → assess → authorize → capture ────────┤
   ───────────────────────────────────────────  │
   (Bob)    (risk)    (3DS if needed)  (charged)└─ no refund (invoice)

   Same scenario used in every stage; comparisons are like-for-like.
```

Bottom half — the test inventory each stage will tick off:
```
At Stage 0, every one of these is a runtime test someone has to remember to write:

  [ ] 1. Shape confusion — passing an Order where an Authorization belongs
  [ ] 2. Wrong element type in typed collections
  [ ] 3. All risk branches handled exhaustively
  [ ] 4. Lifecycle ordering — capture only after authorize
  [ ] 5. Right authorization method for the assessed risk level
  [ ] 6. Boundary constraints — non-empty identifiers
  [ ] 7. Client/server agree on the protocol shape
  [ ] 8. Channel is consumed completely (never dropped mid-protocol)
  [ ] 9. Protocol shape matches the runtime risk classification

Each subsequent stage ticks one or more of these off.
```

**Speaker notes (30 sec):**
"One scenario carries the rest of the talk: an order, an assessment, an authorization, a capture, sometimes a refund. Same domain at every stage; what changes is how much of it the type system enforces. Below is the inventory of test obligations the audience is paying for in Stage 0 — every line is a runtime check or a test you have to remember. Each stage we visit ticks one or more of them off, and the test for that class goes away along with the bug."

**IDE / terminal:** None.

---

### Slide 14 — Stage 0: JavaScript, The Untyped Baseline
**Clock target:** 12:00–12:30
**Type:** Stage intro

**Visual content:**
Two bad-demo output excerpts, shown as terminal output:

```
BAD DEMO — Capture Before Authorize
  capture(order) returned: { captureId: "cap-...", capturedAmount: undefined }
  No error thrown.

BAD DEMO — Medium-Risk Order Skips 3DS
  Medium-risk order authorized without 3DS.
  approvalNote: 'auto-approved-wrong'
```

Bottom:
> "Every one of these failures requires a test. What you do not test, you do not catch."

**Speaker notes (30 sec):**
"Stage 0 is what the baseline gives us: runtime freedom, no structural constraints, every invariant is a test someone has to remember to write. Let's see what that looks like in code, then watch the bugs run silently."

**IDE / terminal transition — IDE Segment 1 (30 sec):**
→ Open `00-js-untyped-payment/demo.js` in the IDE. Show the payment business logic at the top: `assessRisk`, `authorize`, `capture` — no type annotations anywhere.
→ Run the two bad demos in the terminal first. The output shows: capture returning `capturedAmount: undefined`; medium-risk getting `approvalNote: 'auto-approved-wrong'`. No errors thrown.
→ Back in the IDE, navigate to `buggyDemo_CaptureBeforeAuthorize()`: point at `capture(lowRiskCardOrder)` — an Order passed where something else is expected. The interpreter has no complaint.
→ Then `buggyDemo_Skip3DS()`: point at the `if/else` over risk — medium-risk falls through to auto-approve.
→ Say: "Both runs succeeded. Both programs are valid. Every business invariant we want to hold is a test we have to remember to write."
→ Close or minimize `demo.js`.

---

### Slide 15 — Stage 1: Simple Types and Smart Constructors
**Clock target:** 13:00–13:30
**Type:** Stage intro

**Visual content:**
Two side-by-side snippets:

```
// compile error: Order ≠ Authorization
capture(order)

// compile error: private constructor
new Authorization("auth-001", "ord-low", 4500)
```

Label below each:
- Left: "Shape confusion — eliminated."
- Right: "Fabricated lifecycle values — eliminated."

Bottom:
> "Smart constructor = Introduction Rule. The only path to Authorization runs through Authorization.from(Order, …). You cannot fabricate one."

**Speaker notes (30 sec):**
"Stage 1 adds nominal types and the smart-constructor pattern. The compiler now knows the difference between an Order and an Authorization. You cannot pass one where the other is expected. And because the constructor is private, you cannot fabricate an Authorization — you have to call the factory method, which validates and records the prior step."

**IDE / terminal transition — IDE Segment 2 (30 sec):**
→ Open `01-java-simple-types/Demo.java`.
→ Navigate to any lifecycle call (e.g. `gainDemo_SmartConstructors()` or similar).
→ Try typing `new Authorization(...)` in the IDE — show private constructor error in red.
→ Show the bad demo that skips 3DS — it still compiles. Point at it: "But the risk level doesn't flow into the type. Bob's branch can still be forgotten."
→ Return to slide.

---

### Slide 16 — Stage 2: Generics — Write Once, Prove for All
**Clock target:** 14:00–14:30
**Type:** Stage intro

**Visual content:**
```
Validator<T>   — compose validation rules for any domain type
AuditTrail<E>  — type-safe event log

AuditTrail<String> log = AuditTrail.stringLog();
log.append(new Capture(...));  // ← compile error: Capture ≠ String

Bob's branching gap — still open:
  if (risk == LOW)  return fastPath();
  if (risk == HIGH) return manualReview();
  // MEDIUM falls through to ... whatever the developer wrote last.
  // No compile error. RiskDecision is an enum, but the
  // if/else over it is not exhaustivity-checked.
```

Bottom:
> "Write once, provably correct for all types. But what states are constructible — and what branches must be handled — hasn't changed."

**Speaker notes (30 sec):**
"Generics are System F polymorphism: write `Validator` once, the compiler proves it correct for every type it's instantiated with. Same for `AuditTrail` — inserting a Capture into a String-typed log is a compile error, not a runtime surprise. Real architectural wins. But notice the bug class neither stage has touched: branching. The risk decision is a proper enum since Stage 1 — but neither stage 1 nor stage 2 force an `if/else` over that enum to be exhaustive. Bob's incident from the cold open is still a valid program here. Stage 4 closes it."

**IDE / terminal transition — IDE Segment 3 (30 sec):**
→ Open `02-java5-generics/` — show `Validator<T>` with `andThen` composition in 10 sec.
→ Navigate to `AuditTrail<E>` — show the type-safe append in 10 sec.
→ Navigate to `buggyDemo_ForgottenBranch()` — show the if/else chain over `RiskDecision`, with MEDIUM silently falling to the fast path. Compiles. Runs. Output: "Authorized (no 3DS)" on a medium-risk order.
→ Say: "Architectural wins. Bug still compiles."

---

### Slide 17 — Stage 3: Function Pipelines (Acknowledged, Not Demoed)
**Clock target:** 14:30–15:30
**Type:** Bridge

**Visual content:**
Quote block only:

> "Java 8 also gave us function values. Stage 3 makes our business rules first-class — pipeline stages typed as functions from one lifecycle stage to the next, composed with `andThen`; risk rules as explicit, testable values rather than scattered conditions in service code. That code is in the repository. But neither generics nor function values change what states are *constructible* or what branches must be handled. Records and sealed types do. Let's see how."

**Speaker notes (60 sec):**
Deliver the quote above almost verbatim. Then add: "Stage 3's engineering value is real — rules written down in one place, composable, testable in isolation. But the inventory of remaining tests doesn't move. The medium-risk branch can still be forgotten. A Capture can still be constructed without an Authorization. The structural gap is still open. Stage 4 starts closing it."

**IDE / terminal:** None.

---

### Slide 18 — Stage 4: Records, Sealed Types, and Sum Types
**Clock target:** 15:30–16:00
**Type:** Stage intro with Gentzen callback

**Visual content:**
Two columns. Left: the Gentzen ∨E rule (recall from Slide 10, compressed):

```
  A ∨ B   [A]→C   [B]→C
  ─────────────────────
           C
```

Right: the Java sealed switch:

```java
String path = switch (risk) {
    case Low    l -> "fast path";
    case Medium m -> "3DS path";    // COMPILER WON'T LET YOU FORGET THIS BRANCH
    case High   h -> "review path";
};
```

Bottom: "Sealed type = disjunction. Exhaustive switch = ∨-elimination. Missing branch = incomplete proof. Compile error."

**Speaker notes (30 sec):**
"Records are product types — all fields required, no silent nulls. Sealed interfaces are sum types — only one variant at a time, and the compiler knows all of them. Exhaustive switch is Gentzen's ∨E: to draw any conclusion from a disjunction, you must have handled every variant. Bob can no longer forget the Medium case. The compiler requires it."

**IDE / terminal transition — IDE Segment 4 (3:00):**

→ **Step 1 (20 sec):** Open `04-java17-records-sealed/PaymentMethod.java`. Show the sealed interface: three record variants, no default path in.

→ **Step 2 (20 sec):** Open `Demo.java`, navigate to `demo4()`. Show the exhaustive switch on `RiskDecision` — all three cases present.

→ **Step 3 — LIVE DELETE MOMENT (60 sec):** Delete the `case Medium m -> "3DS path"` line live. Watch the compiler report the error: *"switch covers only 2 of 3 permitted subclasses"* (or equivalent). Read it aloud. Say: "That compile error IS Gentzen's ∨E. You have not supplied the `[Medium]→C` branch. The compiler cannot apply the elimination rule." Restore with ⌘Z.

→ **Step 4 (30 sec):** Navigate to the `Result<T>` refund switch. Say: "Same pattern applied to error handling. To use a `Result<T>`, you must handle both `Ok` and `Err`. There is no `getValue()` escape hatch. OR-elimination applied to error handling."

→ **Step 5 (30 sec):** Navigate to `buggyDemo_LifecycleStillUnchecked()`. Show `new PaymentService.Capture(...)` constructed directly without an Authorization. Say: "This still compiles. `Capture` is a plain record with a public constructor. Nothing in the type system prevents this. Stage 5 fixes it."

→ Return to slides.

---

### Slide 19 — Stage 4 Payoff
**Clock target:** 19:00–19:30
**Type:** Payoff

**Visual content:**
```
✓ Bob can no longer forget the Medium case.
  The compiler requires every variant to be handled.
  Test deleted.

⚠  The root cause is still present.
  The risk level doesn't flow into the authorization
  step's type. The wrong approval method can still be
  chosen inside the Medium branch.

  → Closed at Stage 6.
```

**Speaker notes (30 sec):**
"Bob's immediate incident is closed — the branch can no longer be forgotten. But the deeper cause is still present. The type of the risk decision doesn't flow into the authorization step. A developer can still write the Medium case, then call the wrong authorization method inside it. That's Stage 6's job."

**IDE / terminal:** None.

---

### Slide 20 — Bridge: From Records to Typestate
**Clock target:** 19:30–21:00
**Type:** Bridge

**Visual content:**
```
Records brought us sum types. But the lifecycle state
still lives in the CLASS NAME, not the TYPE PARAMETER.

  Authorization auth = new Authorization(...)  // public record constructor
  Capture cap        = new Capture(...)        // constructible independently

The lifecycle grammar is implicit — comments and convention.
Not the type system.

Next rung: make the state the parameter.
```

**Speaker notes (90 sec):**
"Stage 4 gave us honest domain modelling. Risk goes from a plain enum (Java's enum since Stage 1) to a sealed hierarchy that the compiler checks exhaustively. Payment method is a sealed hierarchy of card / wallet / invoice variants. `Result` is a sum type for error handling. All real gains. But look at how lifecycle is modelled: `Authorization` and `Capture` are separate record classes. A developer can still construct a `Capture` without first constructing an `Authorization` — the type system has no opinion on ordering. The lifecycle grammar lives in documentation and developer memory. Stage 5 changes that — the state moves into the type parameter."

**IDE / terminal:** None.

---

### Slide 21 — Stage 5: Phantom Typestate
**Clock target:** 21:00–21:30
**Type:** Stage intro

**Visual content:**
```
Payment<S extends PaymentState>

  Payment<Initiated>   →   Payment<Authorized>   →   Payment<Captured>
                                                            ↓
                                                   Payment<Refunded>

Factory method signatures = a type-level grammar:

  authorizeAuto(Payment<Initiated>)              → Payment<Authorized>
  authorize3DS(Payment<Initiated>, ThreeDSProof) → Payment<Authorized>
  capture(Payment<Authorized>)                   → Payment<Captured>
  refund(Payment<Captured>, RefundMechanism)     → Result<Payment<Refunded>>

  capture(initiated)   ← compile error
  refund(authorized)   ← compile error
```

Bottom:
> "`Payment<Authorized>` IS the proof that authorization happened. The state is not a flag — it is a type."

**Speaker notes (30 sec):**
"One class, one type parameter. The parameter is a phantom — it carries no runtime data. What it does is restrict which factory methods can accept which payments. You cannot pass a `Payment<Initiated>` to `capture` — the types don't match. There is no program at this rung that holds a `Payment<Captured>` without having passed through `Payment<Authorized>` first."

**IDE / terminal transition — IDE Segment 5 (3:30):**

→ **Step 1 (30 sec):** Open `05-java-advanced-generics-typestate/Payment.java`. Show the class declaration: `public final class Payment<S extends PaymentState>` with private constructor. Navigate to `initiate()` — public static, the only entry point.

→ **Step 2 (30 sec):** Show the `authorizeAuto`, `authorize3DS`, and `capture` signatures side by side. Say: "The method signature family IS the state machine. Each transition is a function that requires the right phantom type on input and produces the next phantom type on output."

→ **Step 3 (60 sec):** Navigate to `demo4_TypestateCompileErrors()` in `Demo.java`. Read the inline comments aloud: "capture(initiated) — cannot apply to Payment<Initiated>. That compile error is the lifecycle ordering guarantee." Show or describe what would happen if you tried to call capture on an Initiated payment.

→ **Step 4 (60 sec):** Navigate to `buggyDemo_WrongApprovalMethodStillPossible()`. Show a medium-risk order being authorized via `authorizeAuto`. Say: "This compiles. The type of `Payment<Initiated>` does not know which risk level it represents. The risk assessment is a runtime value. Java's phantom generics can carry the lifecycle state — but not the runtime risk classification. That gap is what Scala 3 closes."

→ Return to slides.

---

### Slide 22 — Stage 5 Payoff: Charlie Closed
**Clock target:** 24:30–25:00
**Type:** Payoff

**Visual content:**
```
✓ Charlie's story is done.

  Payment<Authorized> IS the proof that authorization happened.
  There is no expressible program that holds a Payment<Captured>
  without having passed through Payment<Authorized> first.
  Capture-before-authorize, refund-before-capture, double-authorize
  — all unrepresentable. Lifecycle-ordering tests deleted.

Open at this rung:
  • The risk level is not in the type of the assessed payment.
    The wrong authorization method (auto-approve on a medium-risk
    order) still compiles. Stage 6 closes this.
  • Refined boundary predicates (non-empty IDs, etc.) are still
    runtime checks. Stage 6 closes this.
```

**Speaker notes (30 sec):**
"Charlie's story is done. The lifecycle ordering is structural now, not a runtime check — and not just a class-name convention as it was at Stage 4. Two things remain expressible here, both closed by Stage 6: the risk level isn't yet in the type, so a medium-risk order can still be sent through `authorizeAuto`; and boundary predicates like 'this identifier is non-empty' are still runtime checks. Those are the next rung."

**IDE / terminal:** None.

---
### Slide 23 — The Java Ceiling
**Clock target:** 25:00–26:00
**Type:** Threshold

**Visual content:**
Two columns:

```
What Java can encode                  What Java cannot state
──────────────────────────────────    ──────────────────────────────────
Nominal types              ✓          Approval indexed by risk level   ✗
Parametric polymorphism    ✓          Predicate carried in the type    ✗
Sum types + exhaustive match ✓        Types computed from types        ✗
Phantom lifecycle state    ✓          Path-dependent message types     ✗
```

Bottom:
> "The issue isn't that Java is wordy. Its type system cannot state these claims at all."

**Speaker notes (60 sec):**
"By Stage 5 we've used most of what modern Java's type system offers in this domain: sealed types, records, phantom generics, explicit lifecycles. These are all real, all worth using in production. But there's a ceiling — and the things on the other side of it are not just verbose to encode in Java, they are not expressible. Take one example: the risk level. It's a runtime value — the output of `assessRisk(order)`. Java's type system has no mechanism to carry that runtime information into the *shape* of the next method call's signature. Once we classify an order as medium-risk, the developer can still call `authorizeAuto`; the connection between the risk classification and the required authorization method lives in convention and documentation, not in the type-checker. Same story for refined types — a predicate like 'this string is non-empty' is a runtime check in Java, not part of the type. Same story for types computed from other types. Different point on the lambda cube; different expressive power."

**IDE / terminal:** None.

---

### Slide 24 — Transition to Scala 3
**Clock target:** 26:00–27:00
**Type:** Transition

**Visual content:**
Single quote, large and centered:

> "By Stage 5 we've used most of what modern Java's type system can do for us in this domain — sealed types, phantom generics, explicit lifecycles, all real wins. But there are guarantees we still need tests for that Java's type system cannot encode at all — not because the syntax is bulky, but because the system doesn't have the machinery.
>
> An approval indexed by the risk level, so the wrong authorization method is a compile error. A type that carries a value-level predicate like 'this string is non-empty.' Types computed from other types at compile time.
>
> These need a more expressive type system. Let's see what that looks like."

**Speaker notes (60 sec):**
Deliver the quote above as the spoken transition. This is the most important single transition in the talk — earn it. Then: "What I'm about to show you is not the same ideas with cleaner syntax. Scala 3 has a higher rung because some of what you're about to see is not expressible in Java at all — not verbosely, not at all."

**IDE / terminal:** None.

---
### Slide 25 — Stage 6: What Scala 3 Adds
**Clock target:** 27:00–27:30
**Type:** Stage intro

**Visual content:**
```
Stage 6: Scala 3                        Lambda-cube: bounded λω / System Fω
                                         + type families

New mechanisms:
  ┌──────────────────────────────────────────────────────────────┐
  │  Phantom type indexing     Approval[R <: Risk]               │
  │  Refined types             NonEmptyString = String :| MinLength[1] │
  │  Opaque + refined IDs      OrderId, CustomerId               │
  │  Path-dependent types      CanSend[P]#Msg                    │
  │  Compiler-derived evidence P =:= End                         │
  │  Match types + duality     Dual[P] computed by compiler      │
  │  Higher-kinded types       interpret[F[_]: Functor, A]       │
  └──────────────────────────────────────────────────────────────┘
Each one removes a class of invalid construction.
Each one deletes a test.
```

**Speaker notes (30 sec):**
"Seven mechanisms. I'll show each one producing a compile error for a concrete bug, and name the test that's no longer needed. Then I'll show them combine into session types, where the client/server protocol contract is a compile-time proof."

**IDE / terminal transition — IDE Segment 6a: The Toolkit (3:00):**

→ **Feature 1 — Phantom indexing with sealed-subtype inference (45 sec):**
Open `06-scala3-payment/src/main/scala/demos/PaymentDemo.scala`, navigate to `serverMediumRisk`. Change the relevant `authorize(order, ThreeDSApproved(proof))` line to `authorize(order, AutoApproved)`. The IDE shows an error on the next `ch.send(authorized)`. Hover: read "Found: `AuthorizedPayment[LowRisk]`, Required: `AuthorizedPayment[MediumRisk]`." Say: "AutoApproved is evidence for LowRisk only. The channel expects MediumRisk. Bob cannot skip 3DS. The test is gone." Revert with ⌘Z.
Speaker note (don't say onstage unless asked): phantom indexing isn't new — we've been using it since Stage 5 (`Payment<S>`). The Scala-specific win here is *inference from sealed subtypes*: passing `AutoApproved` infers `R = LowRisk` without explicit type annotations. Java would require explicit type parameters per call site or separate methods per risk level — same mechanism, different boilerplate.

→ **Feature 2 — Refined types: NonEmptyString-refined identifiers (30 sec):**
Open `Domain.scala`, navigate to `type NonEmptyString = String :| MinLength[1]` (and the OrderId/CustomerId opaque types layered on top of it). Frame as a domain rule first: "order and customer identifiers must be non-empty — that's a business invariant, not a runtime check to remember at every consumer." Then show `OrderId.of("")` in demo4: returns `Left(...)`. Then show `"".refineUnsafe[MinLength[1]]` — DOES NOT COMPILE for a literal empty string. Say: "The non-empty predicate lives in the type. An empty `OrderId` cannot exist at runtime, so downstream code never has to defend against it. Same mechanism handles non-empty IDs, amounts within policy bounds, timestamps before a deadline — anywhere a value-level predicate is a domain rule."

→ **Feature 3 — Path-dependent types (30 sec):**
Briefly show `CanSend[P]#Msg` in `Chan.scala` or `protocol/` package. Point at `ch.send(...)` — say: "The message type is derived from the protocol position. Sending the wrong type or sending on a receive step is a compile error. Wrong-payload test gone."

→ **Feature 4 — =:= and finish() (30 sec):**
Navigate to `Chan.scala`, show `finish()` requiring `implicit p: P =:= End`. Say: "Calling `finish()` before the protocol is complete is a compile error — the compiler has to prove `P =:= End` to call it. Protocol-truncation test gone."
Then navigate to `Derivation.scala` lines 83–108 (the DualityChecks object). Show one `summon[Dual[LowRiskProtocol] =:= ...]` assertion. Say: "This is a compile-time test. If the server protocol doesn't match the client's dual, this file doesn't compile. No test runner needed — it's verified at every build."

→ **Feature 5 — Opaque types (30 sec):**
Navigate to `Domain.scala` opaque type block. Show `opaque type AuthCode = String` and `opaque type CaptureId = String`. Say: "Both are Strings underneath. The compiler treats them as different types. `val id: CaptureId = someAuthCode` is a type error. Lifecycle identifier confusion test gone."

→ **Feature 6 — Catamorphisms over inductive types (30 sec):**
Anchor on what the audience already knows: `List(1,2,3).foldRight(0)(_ + _)` vs `List(1,2,3).foldRight("")(_.toString ++ _)` — one traversal, two algebras, impossible to diverge on the shape. Open `Rules.scala`: show `enum PolicyF[+A]` and `interpret[F[_]: Functor, A]`. Say: "Same idea, applied to a policy tree. `describe` and `analyze` are two algebras over one fold. Add a new node and the compiler reports the missing case in every algebra simultaneously — two recursive functions that would otherwise drift become one structure with plug-in summaries."

→ Return to slide briefly.

---

### Slide 26 — Types as Scaffolding (The Positive Affordance)
**Clock target:** 30:00–30:20
**Type:** Insight (brief)

**Visual content:**
```
At this expressivity level, the type system becomes
a collaborator, not just a gatekeeper.

  def processOrder(order: Order): ???

The compiler knows the expected type of ???
It tells you what to fill in.

Add a new lifecycle stage:
  The type propagates the obligation to every
  call site. The compiler guides the fix.

Refactoring into an expressive type system
gets easier as the scaffolding grows — not harder.
```

**Speaker notes (20 sec):**
"One more benefit worth naming. When you add a new payment state or protocol step, the type system cascades the obligation to every site that depends on it. The `???` placeholder in Scala 3 carries the expected type; the compiler tells you what you still need to provide. Idris 2 has typed holes as a first-class development workflow. The type system doesn't just reject the invalid program — it tells you what to write next."

---

### Slide 27 — Session Types: What They Are
**Clock target:** 30:20–31:00
**Type:** Concept (before IDE Segment 6b)

**Visual content:**
```
A session type is a type-level description of a whole
conversation — not just one message.

  At each step, the type tells you what the next
  legal move is. The type advances as the conversation
  progresses.

  Two parties hold complementary types — sending where you
  should receive, or skipping a step, is a compile error.

Low-risk protocol (client's view):

  Client → send Order →            (Send Order ...)
  Client ← receive RiskSnapshot ←  (Send Order (Receive RiskSnapshot ...))
  Client ← receive Authorized   ←  ...
  Client ← receive Captured     ←  ...
  Client → choose refund?       →  (Choose (...) End)
  Client → ... → End

The server holds the DUAL of this type — every Send
becomes a Receive and vice versa. Computed automatically.
```

**Speaker notes (40 sec):**
"Before we open the file: a session type is a type-level description of a conversation. Not one message — the whole exchange. At each step, the type says what the next legal operation is, and the channel value carries that current step around with it. Two parties hold complementary types — if one sends where it should receive, or skips a step, that's a compile error. The 'complementary' part is where duality comes in: the server's type is computed by the compiler as the dual of the client's. Both come from one definition. They cannot drift independently."

**IDE / terminal transition — IDE Segment 6b: Session Types and Duality (3:00):**

→ **Session types in code (45 sec):**
Open `Derivation.scala`. Show `LowRiskProtocol`, `MediumRiskProtocol`, `HighRiskProtocol` — the type-level conversation descriptions. Say: "These aren't interfaces. They are types that describe the entire conversation: order of messages, message types, choices. Client gets `Channel[P]`, server gets `Channel[Dual[P]]`."

→ **Channel API (30 sec):**
Open `Chan.scala` (or the `protocol/` package). Show `send` requiring `CanSend[P]`, `receive` requiring `CanReceive[P]`, `finish` requiring `P =:= End`. Say: "Every operation is constrained by the current protocol position. Wrong order or wrong direction is a compile error."

→ **Duality computation (45 sec):**
Return to `Derivation.scala`, `DualityChecks` object. Show one `summon[Dual[MediumRiskProtocol] =:= Receive[Order, Send[RiskSnapshot, ...]]]` assertion. Say: "The server's protocol is computed by the compiler from the client's protocol. They are derived from the same definition. If the server tries to send when it should receive, it doesn't compile. Danielle's incident is now structurally impossible."

→ **Honest gap — channel completion (30 sec):**
Say: "One thing Scala 3 doesn't enforce: calling `finish()` at the end. Wrong-order sends and wrong message types are rejected. Calling `finish()` mid-conversation is also rejected — the compiler can't prove the protocol equals `End`. But *not* calling `finish()` at all — just dropping the channel — is not caught. The mechanism that closes this is *linear types*: bind the channel at multiplicity 1, and the compiler refuses to accept a program that doesn't consume it. Idris 2 has this via Quantitative Type Theory. We'll see it firing in Stage 7."

→ **Run demo (20 sec):**
Run `sbt run` in the terminal (pre-compiled). Show the output of `demo2()` — medium-risk payment with the 3DS challenge and proof visible in the log. Say: "Client and server, running in parallel, protocol enforced at both ends."

→ Return to slides.

---

### Slide 28 — Stage 6 Payoff: Three Stories Closed, Two Gaps Remain
**Clock target:** 33:45–34:30
**Type:** Payoff

**Visual content:**

```
✓ BOB       — Approval[LowRisk] cannot satisfy Approval[MediumRisk].
              Wrong authorization method for risk level: compile error.
              Test deleted.

✓ ALICE     — Boundary refinement: identifiers are NonEmptyString.
              An empty orderId / customerId is rejected at the
              entry boundary; downstream code never has to defend.
              Boundary-validation tests for this class deleted.

✓ DANIELLE  — Server holds Channel[Dual[P]], client holds Channel[P].
              Computed from the same protocol definition.
              They cannot drift independently.
              Protocol-consistency test deleted.

Two structural gaps still expressible:

→ Protocol shape is selected at runtime from a fixed menu
  (a closed ProtocolVariant ADT). The protocol TYPE itself
  cannot be computed from a runtime Order value.

→ Channel completion is convention, not enforcement.
  Calling finish() mid-protocol is a compile error, but
  dropping the channel without finish() is not caught.

  → Both close at Stage 7 — runtime-to-type via dependent
    types, channel completion via QTT multiplicity 1.
```

**Speaker notes (45 sec):**
"Bob's story is done — wrong authorization method for the assessed risk level is a type error. Alice's boundary class is done — an empty `OrderId` cannot exist at runtime, so consumers don't have to defend. Danielle's story is done — server and client hold types derived from the same protocol definition; they cannot drift. Two structural gaps still expressible at this rung: the protocol type is still selected at runtime from a fixed menu rather than computed from the runtime order; and the channel can be dropped without `finish()` being called, even though calling it mid-protocol is already a compile error. Stage 7 closes both."

**IDE / terminal:** None.

---
## Stage 7 — Idris 2: The Final Bridge

### Slide 29 — Stage 7: The Last Bridge
**Clock target:** 35:00–35:30
**Type:** Stage intro

**Visual content:**
```
Scala's ceiling:

  ProtocolVariant is a CLOSED ADT — the set of possible
  protocols is fixed at compile time, and selection between
  them happens at runtime through handwritten dispatch code.

The third lambda-cube axis (Idris 2):

  protocolDerivedFrom : Order → SessionType

  The function takes a runtime order and returns a value of
  type SessionType whose structure is computed from the order.
  In our scenario runner that value flows directly into
  openSession — its return type is indexed by that protocol
  shape. The Π-elimination rule is running at every call site.

  + Linearity (Quantitative Type Theory):

      send : (1 _ : Session (Send a rest)) -> a -> ...
              ↑
              "consume exactly once"

    Multiplicity annotations on bindings:
      0  =  erased at runtime (compile-time evidence only)
      1  =  linear — must be used exactly once
      ω  =  unrestricted (the default in most languages)

    Mark Session parameters as 1, and the linearity checker
    rejects programs that drop the channel without finish.
```

**Speaker notes (45 sec):**
"In Stages 1 through 6 we moved along the generics axis and the type-operators axis. Stage 7 adds the third: types whose shape depends on runtime values. The protocol type for an order isn't selected from a pre-declared menu — it's computed by `protocolDerivedFrom order`, and the result flows straight into `openSession`. The whole right-hand side of that call has its type set by the runtime order. And on top of that, Stage 7 closes the linearity gap I named in Stage 6. The mechanism is Idris 2's Quantitative Type Theory: every binding has a multiplicity. The default — what every Java and Scala parameter is — is `ω`: use it as many times as you want, including zero. Idris 2 also lets you mark a parameter `1` for *use exactly once*, or `0` for *exists only at compile time*. When the session is bound at `1`, the linearity checker refuses to accept a program that drops it. There is no path through any handler that doesn't end in `finish`."

**IDE / terminal:** None.

---

### Slide 30 — MLTT Rules Running as Programs
**Clock target:** 35:30–36:00
**Type:** Theory callback

**Visual content:**
Recall the Π and Σ rules from Slide 12, but now annotated with the Idris code:

```
Π-elimination:  f : (Πx:A). B(x)    a : A
                ──────────────────────────
                        f(a) : B(a)

→ protocolDerivedFrom order : SessionType
  The protocol SHAPE is B(order) — computed from the order value.


Σ-introduction: a : A     b : B(a)
                ─────────────────
                (a, b) : (Σx:A). B(x)

→ assessOrder : Order n c -> (lvl ** Assessment lvl n c)
  lvl is the returned value.
  Assessment lvl n c is its type, computed from lvl.
  Value and proof, bundled.
```
Bottom:
> "The formal rules from the theory section are what Idris 2's type checker runs at every call site. The slide earlier was the specification; this code is its implementation."

**Speaker notes (30 sec):**
"I showed you these rules 25 minutes ago. Here they are, running. `protocolDerivedFrom order` is Π-elimination: the return type is computed from the argument value. `assessOrder order` is Σ-introduction: a dependent pair where the risk level is both the returned value and the index into the type of the assessment. Same rules, executing as the program."

**IDE / terminal transition — IDE Segment 7: Idris 2 Demo (4:00):**

→ **Navigate to key signatures (60 sec):**
Open `07-idris2-payment/src/PaymentRules.idr` and navigate to `protocolDerivedFrom` (around line 220). Show its signature: `(order : Order n c) -> SessionType`. Say: "SessionType is a first-class type in Idris — this function returns one, computed from a runtime order." Then `protocolFromSnapshot` (which `protocolDerivedFrom` calls): the case-split on `snap.level` that selects the protocol shape. Say: "That case-split is what makes the return type dependent on the runtime value."

Then `assessOrder` in `PaymentDomain.idr`: show `(lvl : RiskLevel ** Assessment lvl n c)` — say: "That `**` is Idris's Σ-type syntax. `lvl` is both the returned value and the index into the type of the second component."

`authorize`: show `Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c` — say: "The assessment carries the risk level as a type parameter; the required approval is indexed by the same level. `AutoApproved` cannot satisfy `Approval MediumRisk`."

Finally, `Main.idr` `runOrderScenario`: show the `openSession (protocolFromSnapshot snapshot n c)` line — say: "One call. The Π-elimination fires; the protocol type for this session is computed from the snapshot. The same expression in Scala would have to be selected from a pre-declared ADT."

→ **Show linearity in action (45 sec):**
Open `PaymentChannel.idr` and point at the `(1 _ : Session ...)` annotations on `send`, `receive`, `finish`. Say: "Read that `1` as 'consume exactly once' — the multiplicity annotation from Idris 2's Quantitative Type Theory. The function body must use this argument once. Not zero times. Not twice. Once. The default in every other language we've looked at is `ω` — unrestricted." Then demonstrate the bug class: open `Main.idr`, comment out a `finish done` line in one handler, save, run `idris2 --build payment.ipkg`. Show the error live: *"There are 0 uses of linear name done. Suggestion: linearly bounded variables must be used exactly once."* Say: "Forgetting to close the channel is no longer a code-review issue. It's a compile error." Restore the file.

→ **Run the demo (90 sec):**
Run `./build/exec/paymentdemo` in the terminal (pre-built). Show demo1 (low-risk), demo2 (medium-risk with 3DS), demo3 (high-risk with manual review). Point out the line in the output: "Protocol derived from runtime order value: ..." and the parenthetical "(= protocolDerivedFrom order : SessionType)". Say: "No bridge ADT. The protocol is the value passed to `openSession`. The compiler tracks the result."

→ **Show the duality involution proof (30 sec):**
Navigate to `dualInvolution : (p : SessionType) -> dual (dual p) = p` in `PaymentSessionTypes.idr`. Say: "Scala's `summon[Dual[P] =:= ...]` checks one concrete protocol. This proves the same property for *every* protocol by structural induction. A proof rather than a test."

→ **Show what's still open (30 sec):**
Briefly show the `believe_me` casts in `PaymentChannel.idr`. Say: "Honest gap: serialisation relies on unsafe casts. A type mismatch in the transport layer is still a runtime error. The remaining frontier."

→ Return to slides.

---

### Slide 31 — Stage 7 Payoff: All Stories Closed
**Clock target:** 40:00–40:30
**Type:** Payoff

**Visual content:**
All four stories, all checked:

```
✓ ALICE    — Boundary refinement: an empty OrderId / CustomerId
             cannot be lifted into the type. Non-empty predicates
             live in the types of the identifiers themselves.

✓ BOB      — The protocol type for a medium-risk order structurally
             requires the 3DS step. AutoApproved cannot produce
             Approval MediumRisk. The skip-3DS path cannot be
             expressed in this type system.

✓ CHARLIE  — The lifecycle state is in the type. No expressible
             program captures before authorizing. And the channel
             carrying the session is consumed at multiplicity 1 —
             dropping it without finish is a compile error.

✓ DANIELLE — Server and client types are computed from the same
             function. They cannot drift independently.
             dualInvolution is proved for ALL protocols by
             structural induction, not tested for one.

By the end of this rung, the four on-call incidents from the
cold open have become programs the type system will not accept.
The set of expressible errors has shrunk, step by step, until
the ones we started with no longer fit through.
```

**Speaker notes (30 sec):**
"Each of these four on-call incidents — Alice's boundary, Bob's branch, Charlie's lifecycle, Danielle's protocol — has, at this point, become a program that cannot be expressed in the type system. That is a stronger guarantee than 'we wrote a test that catches it.' We removed the program, not just the path to it."

**IDE / terminal:** None.

---

## Section 5 — Conclusion

### Slide 32 — The Climb: What Was Removed at Each Stage
**Clock target:** 41:00–42:00
**Type:** Summary

**Visual content:**
Table of what each stage eliminates:

```
Stage 0  JavaScript        Every invariant requires a test.

Stage 1  Simple types      Shape confusion. Fabricated lifecycle values.

Stage 2  Generics          Wrong element types. Composition proven for all T.

Stage 4  Sum types         Forgotten branches. Unhandled error paths.

Stage 5  Phantom typestate Lifecycle ordering. Fabricated state objects.

Stage 6  Scala 3           Wrong approval for risk level. Empty identifiers
                           at the boundary. Protocol drift. Channel-truncation.

Stage 7  Idris 2           Runtime-to-type bridge (Π-elimination at every
                           openSession call). Channel-must-be-completed
                           (linearity / multiplicity 1).
```

Bottom:
> "Each rung is not just a syntactic improvement. It removes a class of expressible invalid program — and the tests that existed only to catch that class."

**Speaker notes (60 sec):**
"Let me trace what we removed. JavaScript: every invariant is a test. Stage 1: shape confusion and fabricated lifecycle values are type errors. Stage 2: element-type bugs and parametricity failures are type errors. Stage 4: forgotten branches and unhandled error paths are compile errors — via OR-elimination, the same rule Gentzen formalised. Stage 5: lifecycle ordering is no longer a runtime check, it is a structural impossibility. Stage 6: the approval method for the assessed risk level, non-empty boundary predicates, protocol drift — all become type errors. Stage 7: the bridge from runtime classification to compile-time protocol type goes away — `protocolDerivedFrom order` computes it directly — and the channel becomes a linear resource the program is required to consume."

**IDE / terminal:** None.

---

### Slide 33 — What's Next in Scala 3: Capture Checking
**Clock target:** 42:00–42:30
**Type:** Horizon

**Visual content:**
```
Scala 3 Capture Checking (experimental — "Caprese")

  Capabilities — file handles, DB connections, IO effects,
  mutable references — tracked in the TYPE of every value
  that uses them.

  Prevents: use-after-close, resource leaks, effect leaks,
  capability escape across async boundaries.

  Cost: direct imperative code, no monadic wrappers.
  The same guarantees `IO[A]` provides in Haskell, structurally
  enforced by the type system without changing program shape.
```

**Speaker notes (30 sec):**
"One more step within Scala 3 worth naming: Capture Checking. Capabilities — file handles, database connections, IO effects — become trackable in the type of any value that closes over them. A function holding a file handle carries that capability in its type; use-after-close, resource leaks, effect escapes across async boundaries — all become type errors. Without monadic wrappers; the code keeps its imperative shape. That's the next thing to follow within the Scala 3 ecosystem if this story is interesting to you."

**IDE / terminal:** None.

---

### Slide 34 — Expressive Types in the Age of Agentic Development
**Clock target:** 42:30–43:00
**Type:** Horizon

**Visual content:**
```
Code is now being generated faster than humans can review it.
Agents propose changes; teams ship them.

When the type system can carry the invariants we care about:

  Every generated line passes the same structural checks
  every hand-written line does. The compiler does not care
  who wrote it.

      Incomplete protocol step          → does not compile.
      Skipped lifecycle transition      → does not compile.
      Empty identifier at the boundary  → does not compile.
      Dropped channel without finish    → does not compile.

  Correctness moves from "a reviewer noticed" to
  "the system rejected it before merge".

For agentic workflows specifically:

  The compiler is a deterministic oracle the agent can iterate
  against. Compile errors are mechanical signals — actionable
  without a human in the loop on every step.

  Proof assistants (Lean, Coq) push this further: the machine
  generates code AND discharges its proof obligations.

The asymmetry between generation speed and review capacity makes
expressive type systems more valuable, not less.
```

**Speaker notes (30 sec):**
"One concrete reason this story matters more in 2026, not less. Models can produce a working PR faster than a human can read it carefully. An expressive type system shifts the floor: every line — human or generated — passes the same structural checks. An incomplete protocol step, a skipped lifecycle transition, an empty identifier, a dropped channel — none compile, regardless of where the code came from. For agentic workflows specifically, this matters even more: the compiler becomes a deterministic oracle the agent iterates against, and compile errors are mechanical signals the agent can act on without a human in the loop. Proof assistants like Lean push this further — the machine doesn't just generate code, it discharges the proof obligations. The asymmetry between generation speed and review capacity makes expressive types more valuable, not less."

**IDE / terminal:** None.

---

### Slide 35 — Further Horizon
**Clock target:** 43:00–43:30
**Type:** Horizon

**Visual content:**
```
Beyond what we have shown today:

  Lean 4       — proof-heavy verification; the machine
                 discharges proof obligations automatically

  Cubical Agda — richer equality and constructive reasoning;
                 homotopy type theory in a programming language

  HoTT / ∞-categories — the landscape of types as spaces,
                 isomorphism as equality, topology meeting
                 proof theory
```

Bottom:
> "The right question is not 'is this fancy?' It is: 'is this invariant expensive enough to encode?'"

**Speaker notes (30 sec):**
"Lean, Agda, homotopy type theory — these are where the frontier is. The reason to know they exist is not to use them next sprint. It is to understand that the expressive power we showed today is not near the top. There is considerably more headroom. And the tools are maturing."

**IDE / terminal:** None.

---

### Slide 36 — Return to the Promise
**Clock target:** 43:30–45:00
**Type:** Close

**Visual content:**
Bring back the four incident chips (Alice blue, Bob orange, Charlie green, Danielle purple) — but now with large check marks. Then the opening promise, quoted:

```
"Some classes of production incidents are not
'just part of engineering life.'

They are artifacts of using a language and design level
that cannot express the invariants we actually care about."



"We can build systems where whole families of operational
pain never make it to staging or production, because the
invalid program cannot be constructed."
```

Below: "Thank you. Questions?"

**Speaker notes (90 sec):**
"Alice spent her morning chasing an invoice that was wrong by a factor of a thousand because a type system couldn't tell a string from a number at a boundary. Bob lost a weekend to an incident because a type system couldn't require every branch to be handled. Charlie spent three hours rebuilding a state machine from logs because the type system had no opinion on the order of transitions. Danielle spent three weeks chasing a protocol drift between two services that had no mechanism to agree at the type level.

None of these required bad people or bad intentions. They came from a mismatch between what the business required and what the design level could enforce.

We showed today that the gap can be closed — incrementally, with existing tools, without discarding what works. Modern Java goes a fair distance on its own; Scala 3 goes considerably further; Idris 2 shows the horizon.

The question is not: 'should I use dependent types for my CRUD endpoints?' The question is: 'is this invariant expensive enough to encode?' For Alice's boundary, probably yes at Stage 1. For Bob's branching, probably yes at Stage 4. For Charlie's lifecycle, probably yes at Stage 5. For Danielle's protocol, probably yes at Stage 6. For the runtime-to-type bridge and channel completion, the answer is increasingly yes as the tools mature.

Thank you."

**IDE / terminal:** None.

---

## Appendix: Pre-Talk Checklist

### IDE Setup
- [ ] All demo directories open in IDE tabs: `00`, `01`, `02`, `04`, `05`, `06`, `07`
- [ ] Within `04`: `PaymentMethod.java`, `Demo.java` open, `Demo.java:demo4()` visible
- [ ] Within `05`: `Payment.java` open, `Demo.java:buggyDemo_WrongApprovalMethodStillPossible()` visible
- [ ] Within `06`: `PaymentDemo.scala:serverMediumRisk` visible, `Derivation.scala:DualityChecks` visible, `Rules.scala:PolicyF` visible
- [ ] Within `07`: `Main.idr:runOrderScenario` visible, `PaymentSessionTypes.idr:dualInvolution` visible
- [ ] Language server running for all languages (red squiggles appear on hover within 1 sec)
- [ ] Dark theme, font size readable at back of room (≥18pt code font)

### Terminal Setup
- [ ] `06-scala3-payment/` has been `sbt compile`d — no build step on stage
- [ ] `07-idris2-payment/` has been built — `./build/exec/paymentdemo` runs without compilation
- [ ] `00-js-untyped-payment/` — `node demo.js` ready to run
- [ ] Terminal font size readable at back of room

### Live Edit Preparation
- [ ] Know `⌘Z` (or `Ctrl+Z`) to revert the live delete of Medium case in Stage 4
- [ ] Know `⌘Z` to revert the `AutoApproved` change in `serverMediumRisk` in Stage 6
- [ ] Practise both edits + reverts until they take under 20 seconds total

### Timing Rehearsal Targets
- [ ] Cold open (stories only, no slides): 4:30–5:00
- [ ] Theory section: 5:30–6:00 (never less; never more than 6:30)
- [ ] Stage 4 IDE segment including live delete: 2:45–3:15
- [ ] Stage 6 IDE segment 6a (toolkit, 6 features): 3:00–3:30
- [ ] Stage 6 IDE segment 6b (session types + duality + linearity-gap note): 2:30–3:00
- [ ] Total talk: 43:00–45:00

### Hard-Cut Cheat Sheet (tape to lectern or keep as phone note)
```
Behind by 1 min at 11:30  → cut MLTT slide (S12)
Behind by 1 min at 21:00  → trim S22 'open at this rung' bullets to a one-liner
Behind by 1 min at 30:00  → cut Feature 6 (catamorphism) from IDE Segment 6a
Never cut Stage 7
```
