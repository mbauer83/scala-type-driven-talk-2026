# Presentation Slide Plan: Type-Driven Programming
## Correctness by Construction from the Basics to the Cutting Edge — Java Meetup Cologne, 28 May 2026

---

## Deck Overview

- **Total slides:** 34 main deck, plus 9 optional appendix slides (A1–A9, shown only if Q&A goes there)
- **IDE/terminal segments:** 7
- **Hard runtime:** 45 minutes (Q&A is separate)
- **Format:** 16:9 at 1920×1080, projector-sized typography
- **IDE setup:** dark theme, syntax highlighting on, Scala/Java language servers running, all files pre-opened in tabs

### Visual Design — Adopted from `style_other_presentation.css`

The presentation uses a **light primary palette** with strategic **dark contrast slides** for transitions and emphasis. Each beat type has a dedicated slide class with its own layout.

#### Palette (OKLCH-based)

| Token | Use | Value |
|-------|-----|-------|
| `--bg` | Body slides | `#f4f1ea` (warm cream) |
| `--bg-warm` | Subtle panels on body slides | `#ebe6d8` |
| `--bg-dark` | Title / section openers / stage openers / Q&A | `#11131a` |
| `--bg-dark-2` | Code-pane body | `#1a1d26` |
| `--bg-dark-3` | Code-pane diagnostic strip | `#232634` |
| `--fg` | Primary text on light | `#14161d` |
| `--fg-dim` | Secondary text on light | `#5a5d68` |
| `--fg-faint` | Tertiary text on light | `#8a8c93` |
| `--fg-dark` | Primary text on dark | `#e8e2d2` |
| `--fg-dark-dim` | Secondary text on dark | `#9b988a` |
| `--accent` | Headlines, eyebrows, highlights | `oklch(0.62 0.14 55)` (warm gold-orange) |
| `--accent-soft` | Mid-emphasis accent | `oklch(0.78 0.08 60)` |
| `--bad` | Compile-error red, "bug still compiles" | `oklch(0.58 0.17 28)` |
| `--good` | "Test deleted", closed-story checkmark | `oklch(0.55 0.10 145)` |

#### Typography

- **`IBM Plex Sans`** for body and headings (300 / 400 / 500 / 600 / 700)
- **`JetBrains Mono`** for code, eyebrows, mono-tagged labels (400 / 500 / 600 / 700)
- **Scale:** `--type-jumbo` 220 / `--type-display` 124 / `--type-title` 68 / `--type-subtitle` 46 / `--type-body` 32 / `--type-small` 26 / `--type-code` 28 / `--type-code-sm` 24

#### Slide classes (per beat type)

| Class | Used for | Background | Distinct features |
|-------|----------|------------|-------------------|
| `.s-title` | Slide 1 | dark | jumbo h1, lede, meta row at the bottom |
| `.s-section` | Section-opener slides between major arcs | dark | mono numeric `.num`, large h2, blurb |
| `.s-incident` | Cold-open slides (Alice, Bob, Charlie, Danielle) | light | two-column grid: person-block (role / name / verdict) + story (heading / paragraph / `.bug-line` mono callout) |
| `.s-theory` | Theory slides (S7–S15) | light | h2 with em-accent, `.big-quote` for punchlines, `.beat-grid` for timeline, `.lcube` for the cube |
| `.s-stage-opener` | Stage intros (S17–S18, S19, S20, S23, S26, S31) | dark | huge mono `.big-num` in accent, h2 description, one-liner with rule above |
| `.s-light` | Generic body slide for payoffs, bridges, gaps | light | h2 with em-accent, body paragraphs, room for code panes and callouts |
| `.s-bignum` | Big-number anchors (e.g. "1 of 4 closed") | dark | 360px mono number in accent, 44px label |
| `.s-close` | Final close (S38) | light | 92px big statement, em-accent on key phrase |
| `.s-qa` | Q&A title card | dark | 280px Q&A in accent, centered, blurb below |

#### Reusable patterns

| Pattern | What it is | Where it lands in this talk |
|---------|-----------|----------------------------|
| `.eyebrow` | Mono uppercase label in accent / dim / bad — sits at the top of every body slide | Every non-section-opener slide gets an eyebrow naming its stage or beat |
| `.code-pane` | Code block with a tab bar (filename + accent dot) and gutter; minimal syntax-coloring. *No diagnostic strip and no hover-pop in the deck* — the speaker switches to the real IDE for live edits, so slides only need to show the code snippet itself, not simulate compiler output | Every static code snippet on a slide; the IDE Segments themselves are delivered in the actual IDE |
| `.eyebrow.--accent` reading "→ DEMO" | Marker that the next moment is an IDE handoff — speaker switches windows | Every IDE Segment hand-off |
| `.callout` | Left-bar callout box (accent or `.--bad`) with a mono eyebrow label | Stage-payoff takeaways |
| `.test-list` | Grid of 9 test rows, each with `.idx` / `.desc` / `.closes`; rows take `.--just-gone` (highlighted in `--good-bg` when crossed off this stage) or `.--gone` (line-through, faded) for already-closed | S16 spine slide; re-displayed on every stage payoff with one or more rows transitioning to `.--just-gone` |
| `.story-strip` | Four-column strip showing Alice / Bob / Charlie / Danielle as chips; `.who.--closed` flips border to accent and state to "CLOSED ✓" | Every stage payoff slide |
| `.ladder` | Three columns labelled DOCUMENTED / TESTED / ENCODED, with `.rung.--encoded` highlighted | S16 (introducing the framing) and S34 (the climb summary) |
| `.lcube` | Grid: SVG cube on the left, axis legend on the right (mono `.tag` + label + `.sub`) | S15 |
| `.beat-grid` | Two-column grid with mono `.when` in accent + body `.what` (optionally with `.sub` subtitle) | S7–S9, S11, S14 history beats |
| `.signature-card` | White card with mono content, used for IDE method signatures pulled out of code panes | Stage 4 / 6 signature highlights |

#### Layout grid

All slides use the same outer chrome:
- 1920×1080 stage
- Padding: 100px top · 112px sides · 88px bottom (`--pad-top` / `--pad-x` / `--pad-bottom`)
- Section gap: 48px between title and content (`--gap-title`), 28px between body items (`--gap-item`)
- Optional 1-px `.rule` divider (`.--accent` for 2-px accent variant)

#### Code-pane conventions

```
┌──────────────────────────────────────────────────────┐
│ ● Domain.scala                          [tab bar]    │  ← bg-dark-3
├──────────────────────────────────────────────────────┤
│  1   opaque type AuthCode  = String                  │
│  2   opaque type CaptureId = String                  │  ← bg-dark-2, JetBrains Mono
│  3   ⋮                                                │
└──────────────────────────────────────────────────────┘

→ DEMO 4 in Demo.java         ← eyebrow + arrow signalling IDE handoff
```

Code panes on slides are static snippets — *enough to anchor what we'll look at
next in the IDE*. Compile errors, hover tooltips, and red squiggles all happen
live in the actual IDE during the IDE Segment. The slide's job is to set up
what the speaker is about to show, not to replicate it.

### Legacy colour-coded chips (preserved for cross-slide recognition)

| Element | Visual treatment |
|---------|-----------------|
| Alice chip | role-label in `--accent`, name in display weight |
| Bob chip | same; the four colours are deprecated — distinguish by *name* in the `.story-strip`, not by hue |
| "Bug still compiles" annotation | `--bad` text in mono, often inside a `.callout.--bad` |
| "Test deleted" annotation | `.test-list .--just-gone` row (line-through with `--good`) |
| Lambda-cube stage labels | `--accent` mono in the `.lcube-legend .tag` slot |
| Quote blocks | `.big-quote` inside `.s-theory` — 76px light weight, em-accent on the load-bearing phrase |

### Timing Reference

| Section | Clock | Duration |
|---------|-------|----------|
| Personal intro | 0:00–0:30 | 0:30 |
| Cold open | 0:30–5:30 | 5:00 |
| Theory | 5:30–11:30 | 6:00 |
| Stages 0 + 1 | 11:30–14:00 | 2:30 |
| Stages 2 + 3 | 14:00–15:30 | 1:30 |
| Stage 3 | 15:30–21:00 | 5:30 |
| Stage 4 | 21:00–27:00 | 6:00 |
| Stage 5 | 27:00–35:00 | 8:00 |
| Stage 6 | 35:00–41:00 | 6:00 |
| Conclusion | 41:00–45:00 | 4:00 |

### Hard-Cut Rules (if running behind)

Apply these in order — never cut Stage 6:

1. **Theory overran by >1 min:** Cut the MLTT slide (S13) entirely. Say once: "Π and Σ types are how Idris 2 expresses these ideas — I'll show them running in Stage 6."
2. **Stage 4 overran:** Cut the "what's still open here" bullets in S24; just say "Charlie's bug is closed; risk-level-in-the-type and boundary refinement come at Stage 5."
3. **Stage 5 overran by >1 min:** Drop the walk-through of Features 4–6 entirely; the three live demos (Features 1–3) are already the heart of the segment. Move straight to session types.
4. **Never cut Stage 6.** If you are 2 min behind at 35:00, cut 1 min from the Stage 5 ceiling discussion (S29) and shorten the conclusion.

---

## Section 1 — Personal Introduction

### Slide 1 — Title
**Clock target:** 0:00–0:30
**Type:** Title

**Visual content:**
```
Type-Driven Programming
═══════════════════════════════════════════════════════
       (large, primary; full-weight)

Correctness by Construction from the Basics to the Cutting Edge
       (subtitle: smaller, normal weight)

       JS  →  Java  →  Scala  →  Idris
       (chip: smaller still, lighter colour / lower contrast)


Michael Bauer
Java Meetup Cologne · Thursday, 28 May 2026
```

**Speaker notes:**
Personal introduction — 30 seconds. Suggested delivery:

"My name is Michael Bauer. I've been working as a software and solution architect for the last ten years, and I want to show you something that kept coming back to me in that work: specific kinds of production incidents where more expressive types would have made the bug structurally impossible to write in the first place — not just easier to test for. We'll look at four examples, then trace what it takes to get there, step by step, with tools that already exist. Thanks to Ari and the organisers for the invitation."

**IDE / terminal:** None.

---

## Section 2 — Cold Open: Four Production Incidents

### Slide 2 — Alice: The Stringly-Typed Boundary
**Clock target:** 0:30–1:45
**Type:** Incident

**Visual content:**
```
Alice's team owns a checkout invoicing and reconciliation pipeline.
Alice walks into a question from accounting.

  An internal admin tool exports a CSV with a lineTotal column
  (amounts stored in cents).
  A Node.js import job aggregates those rows to build draft invoices.

  const amounts = csvRows.map(row => row.lineTotal)
  const total   = amounts.reduce((a, b) => a + b)

  // row.lineTotal = "4500"  (String, not Number)
  // "4500" + "1500" = "45001500"  ← concat, not addition
  Staged: €450,015.00  ·  Actual: €60.00
```

Small footnote: `*` would not have caught this — JS coerces strings for `*`, `/`, `-`. Only `+` silently concatenates.

**Speaker notes (75 sec):**
"Alice's morning starts with a Slack message from accounting. An invoice in the overnight staging batch has a total of €450,015 — about seven and a half thousand times the €60 it should have been. The CSV parser had handed the code values as strings. The aggregation used `+` to sum them, and JavaScript's `+` on two strings is defined — it just concatenates. The job ran clean. The invoice was caught in staging because someone in accounting noticed before the batch went out. The bug isn't stupidity. It's a type system that has no way to express the difference between a string that looks like a number and an actual number."

**IDE / terminal:** None.

---

### Slide 3 — Bob: The Forgotten Branch
**Clock target:** 1:45–3:00
**Type:** Incident

**Visual content:**
```
Bob's team runs the checkout fraud and risk engine.
Bob is handling an incident.

  Checkout service classifies orders: Low / Medium / High risk.
  Medium-risk card orders must complete 3DS before authorization.

  if (risk != HIGH) {
      return fastPath(order);
  }
  return manualReview(order);

  // MEDIUM added later — still hits fastPath()
  // 3DS skipped. Liability shift lost.
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

  void processUrgentRefund(String id) {
      var ref = repo.findById(id);
      paymentRail.execute(ref);
  }

  // ref.state never checked
  // Requested → Executed, skipping review

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
Danielle's team owns a KYC onboarding service.
Danielle is debugging.

  KYC onboarding service: client uploads documents for compliance review.
  For large payout limits, compliance now requires an extra evidence step.

  // client:
  client.send(evidenceDocs)
  val result = client.receive()  // FinalConfirmation

  // server:
  val ev = server.receive()
  server.send(EvidenceAccepted)  // ← client never reads this
  server.receive()               // FinalConfirmation — client hangs

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
the business rules said was illegal.

In this talk we'll look at how using increasingly expressive types
let us shrink that gap — excluding increasingly larger classes of errors.

By the end, following these business rules won't be "well tested" —
the illegal scenarios simply won't compile anymore.
```

**Speaker notes (30 sec):**
"In each case, a program was able to express something the business rules said was illegal. For the rest of the talk we'll walk through seven increasingly expressive type systems — from untyped JavaScript through Java and Scala 3 to Idris 2 — and at each stage we'll see one or more of these four incidents become impossible to express. For closing that gap, we have a toolkit built up over roughly two and a half thousand years. We'll spend a few minutes on that history and motivation, and then for the rest of the talk we'll look at how to cash it out in actual code."

**IDE / terminal:** None.

---

## Section 3 — Theory: Six Minutes of Necessary History

### Slide 7 — A Toolkit Built Over Two and a Half Thousand Years
**Clock target:** 5:30–7:00
**Type:** History (Beat 1)

**Visual content:**
Eyebrow: `LOGIC & PROOF · 4TH C. BCE → TODAY`
Headline: *A Toolkit Built Over Two and a Half Thousand Years*

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
    Also develops binary encoding.

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
"The thread we'll follow is one specific question: what does it take to make *valid inference* explicit — the question of whether a conclusion really does follow from its premises? Aristotle gave the first clean answer: validity comes from the structural form of an argument, not its content. Replace the words with variables; the form holds or it doesn't. Leibniz, two thousand years later, pushed this further — if valid inference is purely structural, then in principle it could be reduced to calculation, performed by a machine. He sketched both the notation and the calculus he thought would do it. The programme failed in his lifetime, but the idea is the line we're still walking. Boole and DeMorgan turned propositional logic into algebra. And at the turn of the 20th century, Frege, Peano, Russell and Whitehead tried to put all of mathematics inside a single formal system. At every step, the move is the same: tighten what counts as a valid step, so more kinds of invalid judgements can be identified and excluded."

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
> "Types were invented to stop logic from consuming itself. Modern type checkers are descendants of that project: within a chosen calculus, they enforce specific structural guarantees."

**Speaker notes (90 sec):**
"Russell found a fatal flaw in the attempts to unify formal reasoning in mathematics and logic. The set of all sets that do not contain themselves — does it contain itself? If yes, it shouldn't. If no, it should. The contradiction lives inside any system that permits unrestricted self-reference. Types were invented as the fix: a strict hierarchy that makes this self-reference structurally impossible. Working in parallel with Russell, Hilbert wrote down three requirements he wanted of any formal system: consistent, sound, and complete. The slide defines them — 'sound' means you can only prove what's actually true; 'complete' means everything true is provable. Gödel proved in 1931 that for any system strong enough to express arithmetic, completeness in that strong sense is impossible — there will always be true arithmetic statements the system cannot prove. The response was to drop the universal-completeness target and concentrate effort on soundness and consistency within specific calculi. That is the family your compiler's type-checker belongs to: it verifies specific structural guarantees within the calculus the language defines."

**IDE / terminal:** None.

---
### Slide 9 — The Computational Convergence (Part 1)
**Clock target:** 8:30–9:05
**Type:** History (Beat 3, Part 1)

**Visual content:** (bullets revealed one beat at a time; advance to Slide 10 after BUILD 2)
```
Church / Turing (1936)                                          [BUILD 1]
  — Formalise execution as reduction.
    Simply Typed Lambda Calculus (pure STLC): types restrict
    inputs, and — IN THE PURE CALCULUS — guarantee that every
    evaluation terminates. Real-world languages relax this so
    they can express general recursion.

Gentzen (1935)                                                  [BUILD 2]
  — Logic as local interface.
    Every connective defined by: how you BUILD it (introduction)
    and how you USE it (elimination).
    Cut elimination = compiler dead-code removal.

           ▼  [advance to Slide 10 for ~30 sec, then advance to Slide 11]
```

**Speaker notes (~45 sec):**

*Beat 1 (Church/Turing, 20 sec):* "Church and Turing formalised computation in 1936. Later, Church's typed lambda calculus made it safe — types restrict what a function can be applied to, and in the pure simply-typed calculus guarantee that every evaluation terminates. Industrial languages relax this to admit general recursion; what carries over is the technique of restricting inputs by types."

*Beat 2 (Gentzen, 25 sec):* "Gentzen, a year earlier, reframed logic itself: every logical connective — AND, OR, IF-THEN — every connective is defined entirely by how you BUILD it and how you USE it. Introduction rules and elimination rules."

→ *Advance to Slide 10 (~30 sec dwell on Gentzen's OR rules — the worked example), then advance to Slide 11.*

**IDE / terminal:** None.

---
### Slide 10 — Gentzen: Logic as Interface
**Clock target:** ~9:05–9:35 (advance from S9 after the Gentzen bullet; advance to S11 after)
**Type:** Formal (interleaved between S9 and S11)

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

**Speaker notes (50 sec):**
"So Gentzen's insight was that a logical connective is *defined* by how you build it and how you use it. For OR: you build it by supplying a proof of one of the two sides; you use it by providing handling for both cases. Worth noticing: these rules represent the *constructive* or *intuitionistic* reading of disjunction. In classical logic, which assumes a fixed "universe of truths", the Law of the Excluded Middle lets you assert 'A or not A' without having evidence of either either. Constructive logic, and Gentzen's natural deduction require you to provide actual constructions of witnesses: to assert A∨B you must supply a proof of A *or* a proof of B. That's what missing the Right-branch means — you haven't provided the handling for all sides, so you can't handle the variant-type (or "sum" type). The compiler enforcing exhaustive matching is enforcing exactly this. Two primitives are going to do most of the heavy lifting for the domain data in this talk: records, which are products — all fields present at once — and sealed types, which are sums — where any value is exactly one variant. The rules and protocols that go on top of that data come later."

**IDE / terminal:** None.

---
### Slide 11 — The Computational Convergence (Part 2)
**Clock target:** 9:35–10:05
**Type:** History (Beat 3, Part 2)

**Visual content:** (previous builds visible; new builds revealed; advance to Slide 13 after BUILD 4)
```
Church / Turing (1936)    [visible]
Gentzen (1935)            [visible]

Curry-Howard (1969)                                             [BUILD 3]
  — Proposition  =  Type
    Proof         =  Program
    Running       =  Simplifying a proof
    Writing code that compiles  =  Constructing a proof.

Martin-Löf (1972)                                               [BUILD 4]
  — Dependent types: return _type_ computed from argument _value_.
    ∀  →  Π-type (dependent function: "For every x:A,
            I can give you a y whose type is specific to that x.")
    ∃  →  Σ-type (dependent pair: "Here's an x:A and a proof
            that this x has a certain property.")

```

**Speaker notes (~50 sec):**

*Beat 3 (Curry-Howard, 20 sec):* "Howard, in 1969, showed these two worlds are the same world. A logical proposition corresponds to a type. A proof corresponds to a program. Running a program is simplifying a proof. Writing code that compiles is, structurally, constructing a proof."

*Beat 4 (Martin-Löf, 30 sec):* "Martin-Löf went further: In his theory - types can depend on values. The Π-type or dependent product says 'for every x of type A, I can produce a y whose type is specific to that x'. The Σ-type or dependent sum says 'here's a value, paired with a proof of some property that's specific to that value'. These are the building blocks of dependent types."

→ *Advance to Slide 13 (~15 sec dwell on Π and Σ formation rules), then advance to Slide 14.*

**IDE / terminal:** None.

---
### Slide 15 — The Lambda Cube
**Clock target:** 10:45–11:30 (closing map of Section 3, after the full history sequence)
**Type:** Map/Diagram

**Visual content:**

A program is built from two kinds of thing: *terms* (values, expressions — the things that exist at runtime) and *types* (the descriptions of those values — the things the compiler reasons about). Construction can mix the two in four ways:

```
                            depends on:
                    ┌──────────────────────────────┐
                    │     terms          types     │
   ┌────────────────┼──────────────────┬───────────┤
   │  the term      │ ordinary code    │ generics  │
   │   uses ...     │ (everywhere)     │ (∀ types) │
   ├────────────────┼──────────────────┼───────────┤
   │  the type      │ dependent types  │ type      │
   │   uses ...     │ (Π, Σ types)     │ operators │
   └────────────────┴──────────────────┴───────────┘

  Examples in our payment domain:

  term on term         capture(auth)                — function application
  term on type         polymorphic functions, e.g. — generics (∀)
                       authorize[R <: Risk](...)
                       — the FUNCTION is parameterised
                         by the type R
  type on type         List[A], Validator[T]        — type constructors
                       (a type takes a type and       (the simplest type-on-
                       returns a type);              type dependency),
                       Dual[P], match types         — type-level computation
                                                       ("logic in types")
  type on term         protocolFromSnapshot(snap)   — runtime snapshot shapes
                                                       the resulting type
```

The lambda cube places systems on these axes. Stages of this talk sit on it:

```
                        λC (Calculus of Constructions)
                       ╱  Stage 6: Idris 2
                      ╱
   System Fω ────────╯  ← Stage 5: Scala 3
   (type operators)    │
         ↑             │
    Stage 4: Java      │
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

Bottom:
> "Stages 1–6 move along the first two axes (terms-on-types, types-on-types). Stage 6 crosses into the third (types-on-terms). That third axis is what makes Stage 6 qualitatively different from the others."

**Speaker notes (60 sec):**
"Construction in any language can mix terms and types in four ways. Term-on-term — your everyday function application, every language has this. Term-on-type — a *function* whose definition is parameterised by a type, that's a polymorphic function, generics, Stage 2 onward. Type-on-type — already starts simply with type constructors like `List[A]` (a type that takes a type and returns a type), and gets more sophisticated with type-level computation: match types, type families, even *logic* expressed at the type level. That's Stage 4 to 6. Type-on-term — a type whose shape is computed from a runtime value — is the third axis and the unique contribution of Stage 6. The lambda cube positions formal type systems by which of these directions they support. We start at simply typed lambda calculus, Stage 1: nominal types, no abstraction over types. We move along the generics axis through Stages 2 to 5. We move along the type-operators axis through Stages 5 to 6. Stage 6 lifts us into the third axis — types depending on values — which Scala and Java cannot reach."

**IDE / terminal:** None.

---


### Slide 12 — Curry-Howard Correspondence

**Clock target:** ~9:35–10:05
**Slide class:** `.s-theory` (light, `theory-slide`)
**File:** `slides/curry-howard.typ`

**Visual content:**
- Left column: three equations (Proposition = Type, Proof = Program, Simplification = Evaluation) with separator line and explanatory text
- Right column: ∨E rule ≅ exhaustive match (the first appearance of ≅ in the deck)

**Speaker note summary:** Howard's 1969 result unifies formal logic and programming. The compiler, within the calculus it defines, acts as a theorem prover. Every stage from 3 onwards is this idea made practical.

---
### Slide 13 — MLTT: Π and Σ Types (Plant the Seed)
**Clock target:** ~10:05–10:20 (advance from S11 after the Martin-Löf bullet; advance to S14 after)
**Type:** Formal (brief, interleaved between S11 and S14)

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
> "Idris 2 runs these rules at every call site. I'll show them in action in Stage 6."

**Speaker notes (25 sec):**
"We'll have a brief look at two relevant rules which are actually simpler in principle than they look here: Π-elimination — the return type is computed from the argument value. And Σ-introduction — bundling a value with a proof that depends on that value. Both are rules of predicate logic — where ∀ and ∃ quantify over values, not just propositions. A *proposition* is a statement that's either true or false; a *predicate* is a property that a value may or may not have. Dependent types add that distinction to the type system."

**IDE / terminal:** None.

---
### Slide 14 — The Computational Convergence (Part 3)
**Clock target:** 10:20–10:45
**Type:** History (Beat 3, Part 3)

**Visual content:** (all previous builds visible; final build revealed)
```
Church / Turing (1936)    [visible]
Gentzen (1935)            [visible]
Curry-Howard (1969)       [visible]
Martin-Löf (1972)         [visible]

Coquand (1988)                                                  [BUILD 5]
  — Calculus of Constructions: dependent types unified with
    polymorphism in a small, auditable kernel — the engine
    behind Rocq, Lean, Agda, and Idris.
```

Bottom line:
> "Under the Curry-Howard correspondence, well-typed code in a sufficiently expressive calculus IS a proof of the proposition its type expresses. Mainstream type checkers verify weaker, calculus-specific structural guarantees built on the same foundations."

**Speaker notes (~25 sec):**

*Beat 5 (Coquand, 20 sec):* "Coquand, in 1988, unified Martin-Löf's dependent types with polymorphism in a small, auditable type-theory kernel — the Calculus of Constructions, extended to the Calculus of Inductive Constructions. That kernel is what powers proof-assistants Rocq, Lean, Agda, and Idris today."

*Closing line, before advancing to S15:* "In a calculus expressive enough to host the propositions you care about, well-typed code IS a proof of the corresponding statement. Each stage of this talk moves to a calculus that can host more interesting propositions about your code."

**IDE / terminal:** None.

---
## Section 4 — Practical Progression

---
### Slide 16 — The Payment Domain, the Test Spine, and What "Test Deleted" Really Means
**Clock target:** 11:30–12:00
**Type:** Orientation (30 sec; sits between theory section and Stage 0)

**Visual content:**

Top — payment lifecycle diagram (one line):
```
                                                ┌─ refund (where supported)
   Order → assess → authorize → capture ────────┤
   ───────────────────────────────────────────  │
   (Bob)    (risk)    (3DS if needed)  (charged)└─ no refund (invoice)

   Same scenario used in every stage; comparisons are like-for-like.
```

Middle — the test inventory each stage will tick off:
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

Bottom — what "test deleted" actually means:
```
  Defensive tests — "did the developer remember X" — shrink in
  proportion to what you encode in types.

  Behavioural tests — "does the system actually charge the right
  amount" — stay. You want these anyway.

  Type-definition review — "does this type actually encode the
  rule" — replaces the per-call-site test, paid once at the
  definition.
```

**Speaker notes (30 sec):**
"One scenario carries the rest of the talk: an e-commerce payment — assess, authorize, capture, sometimes refund. What changes at each stage is how much of it the type system enforces. Don't try to read all nine items now — they'll reappear on every payoff slide as we tick them off. The bottom section is the honest part: defensive tests — 'did the developer remember X' — shrink in proportion to what we encode. Behavioural tests stay; you want those anyway. Verifying that the type definition correctly encodes the rule replaces per-call-site checks — paid once, in code review, at the definition."

**IDE / terminal:** None.

---

### Slide 17 — Stage 0: JavaScript, The Untyped Baseline
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

**IDE transition convention (applies to all IDE segments):** Deliver the speaker notes for the current slide in full, then say the handoff line and switch to the IDE. The IDE segment runs between the stage-intro slide and the payoff slide. "Return to slides" always means advancing to the next payoff.

**IDE / terminal transition — IDE Segment 1 (30 sec):**
→ Open `00-js-untyped-payment/demo.js` in the IDE. Show the top section: the shared fixture orders (plain JS objects, no types), then the business functions `assessRisk`, `authorize`, `capture` — no type annotations anywhere.
→ Run the two bad demos in the terminal: `node demo.js` prints all demos. Point at the bad-demo output: capture returning `capturedAmount: undefined`; medium-risk getting `approvalNote: 'auto-approved-wrong'`. No errors thrown.
→ Back in the IDE, navigate to `buggyDemo_CaptureBeforeAuthorize()`: point at `capture(lowRiskCardOrder)` — an Order passed where something post-authorization is expected. The interpreter has no complaint.
→ Then `buggyDemo_Skip3DS()`: point at the `if/else` — only LOW and else; medium-risk falls through to auto-approve with no 3DS.
→ Say: "Both runs succeeded. Both programs are valid. Every business invariant we want to hold is a test we have to remember to write."
→ Close or minimize `demo.js`.

---

### Slide 18 — Stage 1: Simple Types and Smart Constructors
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
"Stage 1 adds nominal types and the smart-constructor pattern. The compiler now knows the difference between an Order and an Authorization. You cannot pass one where the other is expected. And because the constructor is private, you cannot fabricate an Authorization — you have to call the factory method, which validates and records the prior step. That closes the shape-confusion class and fabricated lifecycle values. The risk level still isn't in the type, so Bob's branching gap remains — Stage 3 closes that. Stage 2 generalises today's gains across every domain type at once."

**IDE / terminal transition — IDE Segment 2 (30 sec):**
*Switch to IDE after delivering the speaker notes above.*
→ Open `01-java-simple-types/Demo.java`, navigate to `gainDemo_SmartConstructors()`.
→ In the IDE, type `new Authorization(...)` next to the existing `Authorization.from(...)` call — the compiler shows a red squiggle: *"Authorization() has private access"*. Read it aloud: "The constructor is private; the only path in is the smart constructor, which validates and records the prior step."
→ Then navigate to `buggyDemo_Skip3DS()` — it still compiles. Point at it: "The risk level isn't in the type. Bob's branch can still be forgotten — Stage 3 closes that."
→ Return to slide.

---
### Slide 19 — Stage 2: Generics — Write Once, Prove for All
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
"Stage 1 gave us nominal types and smart constructors. Stage 2 adds the second dimension: parametric polymorphism — System F. Write `Validator` once, and the compiler proves it correct for every type it's instantiated with. Same for `AuditTrail` — inserting a Capture into a String-typed log is a compile error, not a runtime surprise. Real architectural wins. But notice the bug class neither stage has touched: branching. The risk decision is a proper enum since Stage 1, but no `if/else` over that enum is forced to be exhaustive. Bob's incident from the opening is still a valid program here. That structural gap is what records and sealed types close, coming up in Stage 3."

**IDE / terminal transition — IDE Segment 3 (30 sec):**
*Switch to IDE after delivering the speaker notes above.*
→ Open `02-java5-generics/` — show `Validator<T>` with `andThen` composition in 10 sec. Demo.java L. 122 (the `Validator` composition demo).
→ Navigate to `AuditTrail<E>` — show the type-safe append at Demo.java L. 76 (declaration) and PaymentService.java L. 51 (append call in processLowRisk) in 10 sec.
→ Navigate to `pickAuthPath()` at Demo.java L. 150 first — show the non-exhaustive if/else over `RiskDecision`: LOW and HIGH handled, MEDIUM falls through to the fast path silently. Then navigate to `buggyDemo_ForgottenBranch()` at L. 158 to show it being called.
→ Run the demo. Output: "Authorized (no 3DS)" on a medium-risk order — no error.
→ Say: "Architectural wins. Bug still compiles."

---
### Slide 20 — Stage 3: Function Types · ADTs · Exhaustive Dispatch
**Clock target:** 14:30–19:00 (slide 15:30–16:30; demo 16:30–19:00)
**Type:** Stage intro (merged: function types + ADTs)

**Visual content:**

*Beat 1 — function types as values, then synthesis with generics:*
```java
// A function type is an ordinary type — the lambda is an ordinary value  (t·t)
Function<String, Integer> idLength = s -> s.length();

// List<T> is a type constructor: takes a type argument, returns a type   (T·T)
// map is a polymorphic function: return type U inferred from the argument (t·T)
List<Integer> lengths = List.of("ord-001", "ord-002")  // List<String>
    .stream().map(idLength)   // Function<String,Integer> → U = Integer, inferred
    .toList();                // List<Integer>  ← compiler computed U, not declared
```

*Beat 2 — ADTs: records (products) + sealed (sums) = sums of products:*

Left column — sealed sum type (OR-introduction):
```java
// Sum type: exactly one of {Low, Medium, High}  (∨)
sealed interface RiskDecision
    permits Low, Medium, High {

  record Low()    implements RiskDecision {}  // product
  record Medium() implements RiskDecision {}  // product
  record High()   implements RiskDecision {}  // product
}
```

Right column — exhaustive switch (∨E, OR-elimination):
```java
String path = switch (risk) {
    case Low    l -> "fast path";
    case Medium m -> "3DS path";
    case High   h -> "review path";
    // omit any case → compile error
};
```

Bottom: `A ∨ B  [A]→C  [B]→C  ⊢  C  (∨E)  — recall S10`

**Speaker notes (2 min):**
"Stage 2 gave us parametric polymorphism — `Validator<T>`, `AuditTrail<E>`. Type constructors: `Validator` takes a type argument and returns a specialised type — that's `T·T`. Powerful. But still limited: the code that operated on those typed containers couldn't itself be parameterised over what it produced. Java 8 changes that by making functions first-class values. A `Function<String,Integer>` is a type like any other; the lambda is a value of that type — `t·t`, ordinary STLC. The interesting case is `map`. `List<String>` is a type constructor applied to `String` — `T·T`. But `map` is a polymorphic method — `t·T`: it takes a function argument `f: T → U` and the compiler infers the return type `U` from `f`'s type. You pass `idLength`, a `Function<String,Integer>`, and the compiler concludes `U = Integer` and produces `List<Integer>` — you never declared that return type. The synthesis: type constructors together with polymorphic functions let the compiler compute what a transformation produces.

Now the second piece. Records are product types — all fields present, no optional parts, equality by value. Sealed interfaces are sum types — a closed list of variants the compiler knows in full. Put them together and you have algebraic data types: sums of products. `RiskDecision` is the sum; `Low()`, `Medium()`, `High()` are the products. To draw any conclusion from a `RiskDecision` you must handle each variant — that's Gentzen's ∨E, the same rule from S10. Bob cannot forget `Medium` anymore. The compiler requires it."

**IDE / terminal transition — IDE Segment 4 (2:30):**

→ **Step 1 (20 sec):** Show the top code pane. "Function<String,Integer> is a type; the lambda is the value — `t·t`. `List<String>` is a type constructor — `T·T`. `.map(idLength)` is a polymorphic method — `t·T`: the return type `List<Integer>` was computed from the argument type, not declared."

→ **Step 2 (20 sec):** Open `03-java-function-types-sealed/PaymentMethod.java`. Show the sealed interface: sum type — three record variants, no default path in, compiler knows all cases.

→ **Step 3 (20 sec):** Open `Demo.java`, navigate to `demo4()`. Show the exhaustive switch on `RiskDecision` — all three cases present. "Each record is a product type; the sealed interface wraps them in a sum. ADTs."

→ **Step 4 — LIVE DELETE MOMENT (60 sec):** Delete the `case RiskDecision.Medium m -> "medium-risk 3DS path"` line live. Watch the compiler report the error: *"switch covers only 2 of 3 permitted subclasses"* (or equivalent). Read it aloud. Say: "That compile error IS Gentzen's ∨E. You have not supplied the `[Medium]→C` branch. The compiler will not apply the elimination rule without it." Restore with ⌘Z.

→ **Step 5 (30 sec):** Navigate to the `Result<T>` refund switch in `demo4()`. "Same pattern on error handling. To use a `Result<T>`, you must handle both `Ok` and `Err`. No `getValue()` escape hatch. OR-elimination applied to error handling."

→ **Step 6 (30 sec):** Navigate to `buggyDemo_LifecycleStillUnchecked()`. Show `new PaymentService.Capture(...)` constructed directly without an Authorization. "This still compiles. `Capture` is a plain record with a public constructor. Nothing in the type system prevents this. Stage 4 closes it."

→ Return to slides.

---

### Slide 21 — Stage 3 Payoff: ADTs — Records + Sealed
**Clock target:** 19:00–19:30
**Type:** Payoff

**Visual content:**
```
✓ Bob can no longer forget the Medium case.
  ADTs: sums of products. Compiler requires every variant handled.
  Defensive per-call-site test deleted; behavioural tests stay.

⚠  The root cause is still present.
  The risk level doesn't flow into the authorization
  step's type. The wrong approval method can still be
  chosen inside the Medium branch.

  → Closed at Stage 5.
```

**Speaker notes (30 sec):**
"Bob's immediate incident is closed — the branch can no longer be forgotten. The defensive 'did we test every branch' suite for that enum becomes unnecessary; we read the sealed-type definition once and confirm it covers the domain, and every consumer is automatically constrained. The deeper cause is still present: the type of the risk decision doesn't flow into the authorization step. A developer can still write the Medium case, then call the wrong authorization method inside it. That's Stage 5's job."

**IDE / terminal:** None.

---

### Slide 22 — Bridge: Stage 3 → Stage 4
**Clock target:** 19:30–21:00
**Type:** Bridge

**Visual content:**
```
ADTs gave us honest domain modelling. But lifecycle state
still lives in the CLASS NAME, not the TYPE PARAMETER.

  Authorization auth = new Authorization(...)  // public record constructor
  Capture cap        = new Capture(...)        // constructible independently

The lifecycle grammar is implicit — comments and convention.
Not the type system.

Next: make the state the parameter.
```

**Speaker notes (90 sec):**
"Stage 3 gave us algebraic data types: records as product types — all fields present, equality by value — and sealed interfaces as sum types — a closed set of variants the compiler knows in full. ADTs are sums of products. Risk goes from a plain enum to a sealed hierarchy that the compiler checks exhaustively. `Result` is a sum type for error handling. All real, structural gains. But look at how lifecycle is modelled: `Authorization` and `Capture` are separate record classes. A developer can still construct a `Capture` without first constructing an `Authorization` — the type system has no opinion on ordering. The lifecycle grammar lives in documentation and developer memory. Stage 4 changes that by moving the state into the type parameter itself."

**IDE / terminal:** None.

---

### Slide 23 — Stage 4: Phantom Typestate
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
"Charlie's incident in the opening was a refund approval workflow with an illegal state transition. The demo here uses the same failure shape on payment capture instead — same structural problem, a little more compact to demonstrate. The parameter is a phantom — it carries no runtime data. What it does is restrict which factory methods can accept which payments. You cannot pass a `Payment<Initiated>` to `capture` — the types don't match. There is no expressible program here that holds a `Payment<Captured>` without having passed through `Payment<Authorized>` first."

**IDE / terminal transition — IDE Segment 5 (3:30):**

→ **Step 1 (30 sec):** Open `04-java-advanced-generics-typestate/Payment.java`. Show the class declaration: `public final class Payment<S extends PaymentState>` with private constructor. Navigate to `initiate()` — public static, the only entry point.

→ **Step 2 (30 sec):** Show the `authorizeAuto`, `authorize3DS`, and `capture` signatures side by side. Say: "The method signature family IS the state machine. Each transition is a function that requires the right phantom type on input and produces the next phantom type on output."

→ **Step 3 — LIVE UNCOMMENT MOMENT (60 sec):** Navigate to `demo4_TypestateCompileErrors()` in `Demo.java`. Show the body: an order is built, `init`/`authorized`/`captured` go through the lifecycle, and three commented-out lines sit below — each marked `← UNCOMMENT`. Uncomment the `Payment.capture(init);` line. The compiler reports: *"Payment<Initiated> cannot be converted to Payment<Authorized>"*. Read it aloud: "The capture function requires Payment<Authorized>. We're passing Payment<Initiated>. The lifecycle ordering is now a type constraint, not a convention." Re-comment with the `// ← UNCOMMENT` line restored. The second demo line uses `new RefundMechanism.InstantReversal()` — uncomment it next to show the refund-on-authorized error if time permits.

→ **Step 4 (60 sec):** Navigate to `buggyDemo_WrongApprovalMethodStillPossible()`. Show a medium-risk order being authorized via `authorizeAuto`. Say: "This compiles. The type of `Payment<Initiated>` does not know which risk level it represents. The risk assessment is a runtime value. Java's phantom generics can carry the lifecycle state — but not the runtime risk classification. That gap is what Scala 3 closes."

→ Return to slides.

---

### Slide 24 — Stage 4 Payoff: Charlie Closed
**Clock target:** 24:30–25:00
**Type:** Payoff

**Visual content:**
```
✓ Charlie's story is done.

  Payment<Authorized> IS the proof that authorization happened.
  There is no expressible program that holds a Payment<Captured>
  without having passed through Payment<Authorized> first.
  Capture-before-authorize, refund-before-capture, double-authorize
  — all unrepresentable. Defensive lifecycle-ordering tests deleted;
  behavioural tests stay.

Still expressible here:
  • The risk level is not in the type of the assessed payment.
    The wrong authorization method (auto-approve on a medium-risk
    order) still compiles. Stage 5 closes this.
  • Refined boundary predicates (non-empty IDs, etc.) are still
    runtime checks. Stage 5 closes this.
```

**Speaker notes (30 sec):**
"Charlie's story is done. The lifecycle ordering has moved into the type itself — from the runtime check it was at Stage 0–3, from the class-name convention it was at Stage 3, into a structural property the compiler enforces. Two things remain expressible here, both closed by Stage 5: the risk level isn't yet in the type, so a medium-risk order can still be sent through `authorizeAuto`; and boundary predicates like 'this identifier is non-empty' are still runtime checks. Those are the next stage's work."

**IDE / terminal:** None.

---
### Slide 25 — The Java Ceiling
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
> "It's not just hard to express these invariants in Java — the type system lacks the machinery to state them at all."

**Speaker notes (60 sec):**
"By Stage 4 we've used most of what modern Java's type system offers in this domain: sealed types, records, phantom generics, explicit lifecycles. These are all real, all worth using in production. But there's a ceiling — and the things on the other side of it are not just verbose to encode in Java, they are not expressible. Take one example: the risk level. It's a runtime value — the output of `assessRisk(order)`. Java's type system has no mechanism to carry that runtime information into the *shape* of the next method call's signature. Once we classify an order as medium-risk, the developer can still call `authorizeAuto`; the connection between the risk classification and the required authorization method lives in convention and documentation, not in the type-checker. Same story for refined types — a predicate like 'this string is non-empty' is a runtime check in Java, not part of the type. Same story for types computed from other types. It's not just hard to express this in Java — we need a more expressive type system. Let's see what that looks like."

**IDE / terminal:** None.

---
### Slide 26 — Stage 5: What Scala 3 Adds
**Clock target:** 27:00–27:30
**Type:** Stage intro

**Visual content:**
```
Stage 5: Scala 3                        Lambda-cube: bounded λω / System Fω
                                         + type families

Mechanisms at work:
  ┌────────────────────────────────────────────────────────────────────┐
  │  Refined types             NonEmptyString = String :| MinLength[1] │
  │  Opaque + refined IDs      OrderId, CustomerId                     │
  │  Path-dependent types      CanSend[P]#Msg                          │
  │  Compiler-derived evidence P =:= End                               │
  │  Match types + duality     Dual[P] computed by compiler            │
  │  Higher-kinded types       interpret[F[_]: Functor, A]             │
  └────────────────────────────────────────────────────────────────────┘
Each one removes a class of invalid construction.
Each one deletes a test.
```
**Speaker notes (30 sec):**
"Scala 3's type system opens up mechanisms that Java simply cannot reach. Let's look at three of them in our code — refined identifiers, path-dependent channels, and match types — those carry most of the structural weight. Four more are in the repository; I'll point at them as we move through the session-types demo, and then show how they combine into something that makes Danielle's protocol-drift incident a compile error."

**IDE / terminal transition — IDE Segment 6a: The Toolkit (2:30):**
→ **Feature 1 — Phantom indexing with sealed-subtype inference (45 sec):**
Open `05-scala3-payment/src/main/scala/demos/PaymentDemo.scala`, navigate to `serverMediumRisk`. Change the relevant `authorize(order, ThreeDSApproved(proof))` line to `authorize(order, AutoApproved)`. The IDE shows an error on the next `ch.send(authorized)`. Hover: read "Found: `AuthorizedPayment[LowRisk]`, Required: `AuthorizedPayment[MediumRisk]`." Say: "Worth being precise here. `authorize(order, AutoApproved)` itself is well-typed — it just produces an `AuthorizedPayment[LowRisk]`. The compile error happens one line later, when we try to send that value through the channel: the medium-risk protocol requires `AuthorizedPayment[MediumRisk]` at this position, and `LowRisk` doesn't satisfy it. The protocol context is what catches Bob's mistake. Revert." (⌘Z)
Speaker note (don't say onstage unless asked): the `Approval[R]` indexed pattern itself is not Scala-exclusive. Java 17 can express `sealed interface Approval<R extends Risk>` with the same sealed-subtype inference — passing `new AutoApproved()` (which implements `Approval<LowRisk>`) infers `R = LowRisk` without explicit annotation. What IS Scala-exclusive is what the indexed type flows into: the session type machinery. The channel at a medium-risk protocol position structurally requires `AuthorizedPayment[MediumRisk]` at that step, derived via match types (`Dual[P]`) and path-dependent associated types (`CanSend[P]#Msg`) — neither of which Java has any equivalent for.

Note on design: `serverMediumRisk` also calls `riskSnapshotFor(order)` and sends the snapshot to the client. This is not re-evaluating which protocol to use — that decision happened at dispatch level before the handler was called. The snapshot is part of the protocol: the client receives it for transparency and logging. Each handler is committed to its typed protocol; what it computes and sends as content is derived from the order.

→ **Feature 2 — Refined types: NonEmptyString-refined identifiers (30 sec):**
Open `Domain.scala`, navigate to `type NonEmptyString = String :| MinLength[1]` (and the OrderId/CustomerId opaque types layered on top of it). Frame as a domain rule first: "order and customer identifiers must be non-empty — that's a business invariant, not a runtime check to remember at every consumer." In demo4, show two complementary uses:
  • `OrderId.of("")` → returns `Left(...)` — this is the smart constructor; it uses `refineEither[MinLength[1]]` internally and is the right tool for *runtime* String values arriving from the outside.
  • `"".refineUnsafe[MinLength[1]]` → DOES NOT COMPILE — `refineUnsafe` is for *compile-time-known literals*; Iron's macros check the predicate at compile time and reject literals that fail.
Say: "Two paths into the type. The smart constructor handles runtime values safely. The macro path proves the predicate at compile time for literals. An empty `OrderId` cannot exist at runtime, so downstream code never has to defend against it. Same mechanism handles non-empty IDs, amounts within policy bounds, timestamps before a deadline — anywhere a value-level predicate is a domain rule."

→ **Feature 3 — Path-dependent types (30 sec, LIVE):**
Briefly show `CanSend[P]#Msg` in `Chan.scala` or `protocol/` package. Point at `ch.send(...)` — say: "The message type is derived from the protocol position. Sending the wrong type or sending on a receive step is a compile error. Defensive per-call-site test gone; behavioural tests stay."

→ **Additional mechanisms (brief verbal mention, ~10 sec — no live edits):**
"One more mechanism worth naming: opaque types — `AuthCode`, `CaptureId`, `RefundId` are all `String` underneath, but the compiler refuses to mix them. I'll show `=:=` evidence and `finish()` in the session-types segment next."

→ Return to slide briefly.

---
### Slide 27 — Session Types: What They Are
**Clock target:** 30:00–30:45
**Type:** Concept (before IDE Segment 6b)

**Visual content:**
```
A session type describes a whole conversation (send, receive, offer choice, select choice) in the type
system — the full sequence of moves, in order, on both sides.

  Each channel's type is the *remainder of the protocol*:
  the moves still to be made. Performing a send or a receive
  consumes one step and produces a channel typed by what's
  left to do.

  Two parties hold complementary types: one's send is the
  other's receive. A mismatch at either end is a compile
  error, not a runtime drift.

Low-risk protocol (client's view):

  Client : Channel[Send Order (Receive RiskSnapshot (Receive Auth ...))]
   send order            →  Channel[Receive RiskSnapshot (Receive Auth ...)]
   receive RiskSnapshot  →  Channel[Receive Auth ...]
   receive AuthorizedPmt →  Channel[Receive Captured ...]
   receive CapturedPmt   →  Channel[Choose (...) End]
   selectLeft / Right    →  Channel[End]
   finish                →  ()

Server holds Channel[Dual[P]] — every Send becomes a Receive
and vice versa. Dual[P] is computed by the compiler.
```

**Speaker notes (45 sec):**
"A session type describes a whole conversation in the type system — the full sequence of moves, in order, on both sides. The channel's type at any point is the remainder of the protocol: the moves still to be made. Each send or receive consumes one step and gives back a channel typed by what's left to do. The two parties hold complementary session types — one side's send is the other side's receive — so a mismatch at either end is a compile error rather than a runtime drift. The 'complementary' relation is what duality formalises: the server holds `Channel[Dual[P]]` where the client holds `Channel[P]`, and the compiler computes `Dual[P]` from the same definition. Both ends are derived from one source. They cannot drift independently."

**IDE / terminal transition — IDE Segment 6b: Session Types and Duality (3:00):**

→ **Session types in code (45 sec):**
Open `Derivation.scala`. Show `LowRiskProtocol`, `MediumRiskProtocol`, `HighRiskProtocol` — the type-level conversation descriptions. Say: "These aren't interfaces. They are types that describe the entire conversation: order of messages, message types, choices. Client gets `Channel[P]`, server gets `Channel[Dual[P]]`."

→ **Channel API (30 sec):**
Open `Chan.scala` (or the `protocol/` package). Show `send` requiring `CanSend[P]`, `receive` requiring `CanReceive[P]`, `finish` requiring `P =:= End`. Say: "Every operation is constrained by the current protocol position. Wrong order or wrong direction is a compile error."

→ **Duality computation (45 sec):**
Return to `Derivation.scala`, `DualityChecks` object. Show one `summon[Dual[MediumRiskProtocol] =:= Receive[Order, Send[RiskSnapshot, ...]]]` assertion. Say: "The server's protocol is computed by the compiler from the client's protocol. They are derived from the same definition. If the server tries to send when it should receive, it doesn't compile. Danielle's incident is now structurally impossible."

→ **Honest gap — channel completion (30 sec):**
Say: "One thing Scala 3 doesn't enforce: calling `finish()` at the end. Wrong-order sends and wrong message types are rejected. Calling `finish()` mid-conversation is also rejected — the compiler can't prove the protocol equals `End`. But *not* calling `finish()` at all — just dropping the channel — is not caught. The mechanism that closes this is *linear types*: bind the channel at multiplicity 1, and the compiler refuses to accept a program that doesn't consume it. Idris 2 has this via Quantitative Type Theory. We'll see it firing in Stage 6."

→ **Run demo (20 sec):**
Run `sbt run` in the terminal (pre-compiled). Show the output of `demo2()` — medium-risk payment with the 3DS challenge and proof visible in the log. Say: "Client and server, running in parallel, protocol enforced at both ends."

→ Return to slides.

---


### Slide 28 — Stage 5: Mechanisms at Work

**Clock target:** ~33:30–34:00
**Slide class:** `.s-light` (light, `light-slide`)
**File:** `slides/stage5-mechanisms.typ`

**Visual content:**
- Reference grid: six Stage 5 type-level mechanisms, each with name, code example, and plain-English description
- Used as a vocabulary anchor after the Stage 5 demo

**Speaker note summary:** Names all six mechanisms observed in the demo — refined types, opaque IDs, path-dependent types, compiler-derived evidence, match types + duality, higher-kinded types.

---
### Slide 29 — Stage 5 Payoff: Three Stories Closed, Two Gaps Remain
**Clock target:** 33:45–34:30
**Type:** Payoff

**Visual content:**

```
✓ BOB       — Once the protocol has selected the medium-risk path,
              AutoApproved (Approval[LowRisk]) cannot satisfy the
              channel's required AuthorizedPayment[MediumRisk].
              The protocol context closes the bug.
              Defensive per-call-site test deleted.

✓ ALICE     — Boundary refinement: identifiers are NonEmptyString.
              An empty orderId / customerId is rejected at the
              entry boundary; downstream code never has to defend.
              Defensive boundary-validation tests deleted;
              behavioural tests stay.

✓ DANIELLE  — Server holds Channel[Dual[P]], client holds Channel[P].
              Computed from the same protocol definition.
              They cannot drift independently.
              Defensive protocol-consistency test deleted;
              behavioural tests stay.

Two structural gaps still expressible:

→ Protocol shape is selected at runtime from a fixed menu
  (a closed ProtocolVariant ADT). The protocol TYPE itself
  cannot be computed from a runtime Order value.

→ Channel completion is convention, not enforcement.
  Calling finish() mid-protocol is a compile error, but
  dropping the channel without finish() is not caught.

  → Both close at Stage 6 — runtime-to-type via dependent
    types, channel completion via QTT multiplicity 1.
```

**Speaker notes (45 sec):**
"Bob's story is done in this combination: once the protocol has selected the medium-risk path, a LowRisk approval cannot satisfy the channel's required MediumRisk evidence. It's the protocol context that catches the mistake, not the authorization function in isolation. Alice's boundary class is done — an empty `OrderId` cannot exist at runtime, so consumers don't have to defend. Danielle's story is done — server and client hold types derived from the same protocol definition; they cannot drift. But - two structural gaps are still expressible at this stage: the protocol type is still selected at runtime from a fixed menu rather than computed from the runtime order; and the channel can be dropped without `finish()` being called, even though calling it mid-protocol is already a compile error. Stage 6 closes both."

*Optional hook (drop in if you sense a "why doesn't Scala just do dependent types?" question forming):* "Scala can actually get closer than the fixed menu — match types are compile-time type-level computation, and singleton types like `1234.type` can feed a runtime literal into them. That combination mimics dependent types without the totality cost Idris pays. I've got a slide on exactly that if anyone wants it in Q&A." (→ Appendix A8)

**IDE / terminal:** None.

---
## Stage 6 — Idris 2: The Final Bridge


### Slide 30 — The Scala 3 Ceiling

**Clock target:** ~34:00–35:00
**Slide class:** `.s-light` (light, `light-slide`)
**File:** `slides/scala3-ceiling.typ`

**Visual content:**
- Two-column table mirroring S25 (Java Ceiling): ✓ what Scala 3 can encode vs ✗ what it cannot state
- Bad callout: "the lambda cube has a third axis it cannot reach"

**Speaker note summary:** Scala 3's ceiling is qualitatively different from Java's — the ✗ items are structurally inexpressible, not just verbose. Motivates Stage 6.

---
### Slide 31 — Stage 6: The Last Bridge
**Clock target:** 35:00–35:30
**Type:** Stage intro

**Visual content:**
```
Scala's ceiling:

  ProtocolVariant is a CLOSED ADT — the set of possible
  protocols is fixed at compile time, and selection between
  them happens at runtime through handwritten dispatch code.

The third lambda-cube axis (Idris 2):

  protocolFromSnapshot : RiskSnapshot → SessionType

  The function takes a runtime risk snapshot — the output of
  assessing an order — and returns a SessionType VALUE computed
  from the snapshot's risk classification. We then call

    openSession  (protocolFromSnapshot snapshot n c)

  and openSession returns a pair of channel endpoints INDEXED
  by that computed value. Subsequent operations (`send`,
  `receive`, `finish`) are then type-checked against the
  specific protocol the runtime computation selected.

  + Linearity (Quantitative Type Theory):

      send : (1 _ : Session (Send a rest)) -> a -> ...
              ↑
              "consume exactly once"

    Multiplicity annotations on bindings:
      0  =  erased at runtime (compile-time evidence only)
      1  =  linear — must be used exactly once
      ω  =  unrestricted (the default in most languages)

    Session parameters bound at 1 — the linearity checker
    rejects programs that drop the channel without finish.
```

**Speaker notes (45 sec):**
"Stage 6 adds the third lambda-cube axis: types whose shape depends on runtime values. The protocol isn't selected from a pre-declared menu — `protocolFromSnapshot` takes a runtime risk snapshot and returns a `SessionType` specific to that risk value. That session-type flows into `openSession`, which returns channel endpoints with the appropriate protocol. Every subsequent `send` and `receive` is type-checked against the protocol. Those are the kind of coherence-guarantees afforded by dependent types. Stage 6 also closes the linearity gap from Stage 5. Idris 2 gives every binding a multiplicity: the default is `ω` — unrestricted use as in every other language we've seen. `1` means use exactly once. `0` means erased at runtime. Since the session channel has multiplicity `1`, the linearity checker refuses any program that drops or re-uses it - or fails to call `finish`."

**IDE / terminal:** None.

---

### Slide 32 — MLTT Rules Running as Programs
**Clock target:** 35:30–36:00
**Type:** Theory callback

**Visual content:**
Recall the Π and Σ rules from Slide 13, but now annotated with the Idris code:

```
Π-elimination:  f : (Πx:A). B(x)    a : A
                ──────────────────────────
                        f(a) : B(a)

→ protocolFromSnapshot : RiskSnapshot -> SessionType
  Apply it to a runtime risk snapshot and you get a SessionType
  value whose shape was determined by the snapshot's risk level.
  openSession then accepts that value and returns channel
  endpoints indexed by it.


Σ-introduction: a : A     b : B(a)
                ─────────────────
                (a, b) : (Σx:A). B(x)

→ assessOrder : Order n c -> (lvl ** Assessment lvl n c)
  Returns a pair: the risk level lvl, AND an assessment whose
  TYPE includes lvl. Value and proof, bundled.
```
Bottom:
> "The formal rules from the theory section are what Idris 2's type checker runs at every call site. The slide earlier was the specification; this code is its implementation."

**Speaker notes (30 sec):**
"The Π and Σ rules from Slide 13 reappear here as ordinary Idris functions in the same payment domain. `protocolFromSnapshot snapshot` is Π-elimination: the return type is a `SessionType` computed from the runtime risk level in the snapshot. `assessOrder order` is Σ-introduction: a dependent pair bundling the risk level with an assessment whose type depends on that level. The rules were the specification; these functions are the implementation."

**IDE / terminal transition — IDE Segment 7: Idris 2 Demo (4:00):**
→ **Navigate to key signatures (60 sec):**
Open `06-idris2-payment/src/PaymentRules.idr` and navigate to `protocolFromSnapshot`. Show its signature: `RiskSnapshot -> SessionType`. Say: "SessionType is a first-class type in Idris — this function returns one, computed from a runtime risk snapshot." Show the case-split on `snap.level` that selects the protocol shape. Say: "That case-split is what makes the return type dependent on the runtime value."

Then `assessOrder` in `PaymentDomain.idr`: show `(lvl : RiskLevel ** Assessment lvl n c)` — say: "That `**` is Idris's Σ-type syntax. `lvl` is both the returned value and the index into the type of the second component."

`authorize` (PaymentDomain.idr L329): show `Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c` — say: "The assessment carries the risk level as a type parameter; the required approval is indexed by the same level. `AutoApproved` cannot satisfy `Approval MediumRisk`."

Finally, `Main.idr` `runOrderScenario`: show the `openSession (protocolFromSnapshot snapshot n c)` line — say: "One call. `protocolFromSnapshot` computes the protocol type from the snapshot; `openSession` indexes the channel endpoints by it. The same result in Scala requires selecting from a pre-declared ADT — here it's derived directly from the runtime value."

→ **Show linearity in action (45 sec):**
Open `PaymentChannel.idr` and point at the `(1 _ : Session ...)` annotations on `send`, `receive`, `finish`. Say: "Read that `1` as 'consume exactly once' — the multiplicity annotation from Idris 2's Quantitative Type Theory. The function body must use this argument once. Not zero times. Not twice. Once. The default in every other language we've looked at is `ω` — unrestricted." Then demonstrate the bug class: open `Main.idr`, comment out a `finish done` line in one handler, save, run `idris2 --build payment.ipkg`. Show the error live: *"There are 0 uses of linear name done. Suggestion: linearly bounded variables must be used exactly once."* Say: "Forgetting to close the channel is no longer a code-review issue. It's a compile error." Restore the file.

→ **Run the demo (60 sec):**
Run `./build/exec/paymentdemo` in the terminal (pre-built). Show demo1 (low-risk), demo2 (medium-risk with 3DS visible in the log), demo3 (high-risk with manual review). The logs are annotated — focus on the outcome lines for demos 1–3, then point at the demo7 summary output: `protocolFromSnapshot snapshot : SessionType`. Say: "No bridge ADT. The protocol is a value computed from the runtime snapshot and passed directly to `openSession`. The compiler tracks the result."

→ **Duality involution (10 sec, no navigation):**
Say: "There's also `dualInvolution` in `PaymentSessionTypes.idr` — it proves `dual (dual p) = p` for every protocol by structural induction. Scala's `summon[Dual[P] =:= ...]` checks one concrete instance; Idris proves the general case."

→ **Still open (10 sec, no navigation):**
Say: "One honest gap: serialisation in `PaymentChannel.idr` relies on `believe_me` casts. A type mismatch in the transport layer is still a runtime error. The remaining frontier."

→ Return to slides.

---

### Slide 33 — Stage 6 Payoff: All Stories Closed
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

By Stage 6, the four production incidents from the cold open
have become programs the type system will not accept.
The set of expressible errors has shrunk, step by step, until
the ones we started with no longer fit through.
```

**Speaker notes (30 sec):**
"Each of these four production incidents — Alice's boundary, Bob's branch, Charlie's lifecycle, Danielle's protocol — has, at this point, become a program that cannot be expressed in the type system - a much stronger guarantee than 'we wrote a test that catches it.'"

**IDE / terminal:** None.

---

## Section 5 — Conclusion

### Slide 34 — The Climb: What Was Removed at Each Stage
**Clock target:** 41:00–42:00
**Type:** Summary

**Visual content:**
Table of what each stage eliminates:

```
Stage 0  JavaScript        Every invariant requires a test.

Stage 1  Simple types      Shape confusion. Fabricated lifecycle values.

Stage 2  Generics          Wrong element types. Composition proven for all T.

Stage 3  Sum types         Forgotten branches. Unhandled error paths.

Stage 4  Phantom typestate Lifecycle ordering. Fabricated state objects.

Stage 5  Scala 3           Wrong approval for risk level. Empty identifiers
                           at the boundary. Protocol drift. Channel-truncation.

Stage 6  Idris 2           Runtime-to-type bridge (Π-elimination at every
                           openSession call). Channel-must-be-completed
                           (linearity / multiplicity 1).
```

Bottom:
> "Each stage is more than a syntactic improvement. It removes a class of expressible invalid program — and the tests that existed only to catch that class."

**Speaker notes (60 sec):**
"Let me trace what we removed. JavaScript: every invariant is a test. Stage 1: shape confusion and fabricated lifecycle values are type errors. Stage 2: element-type bugs and parametricity failures are type errors. Stage 3: forgotten branches and unhandled error paths are compile errors — via OR-elimination, the same rule Gentzen formalised. Stage 4: lifecycle ordering is no longer a runtime check, it is a structural guarantee. Stage 5: the approval method for the assessed risk level, non-empty boundary predicates, protocol drift — all become type errors. In Stage 6, we no longer have a gap between runtime classification and compile-time protocol-shape — `protocolFromSnapshot snapshot` computes it directly — and the channel becomes a linear resource the program is required to consume."

**IDE / terminal:** None.

---

### Slide 35 — Expressive Types in the Age of Agentic Development
**Clock target:** 42:00–43:00
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

  The compiler gives the agent a stable, mechanical signal to
  iterate against. Compile errors are actionable without a
  human in the loop on every step.

  Proof assistants — Lean, Rocq, Agda, Idris itself — go a
  step further: the proof obligation becomes a first-class
  part of the type. The proof still has to be written, but
  the assistant checks it mechanically, and modern tactic
  libraries automate growing fractions of the work.

When generation speed exceeds review capacity, an expressive
type system raises the share of correctness that's enforced
before merge rather than spotted by a reviewer.
```

**Speaker notes (45 sec):**
"There's another concrete reason this story matters now. AI agents can produce a working PR faster than a human can read it carefully. An expressive type system raises the floor of correctness that holds regardless of the author: incomplete protocol steps, skipped lifecycle transitions, empty identifiers, dropped channels — none of those compile, whether a person or a model wrote them. For agentic workflows specifically, the compiler gives the agent a stable, mechanical signal to iterate against; compile errors are actionable without a human in the loop on every step. Proof assistants like Lean, Rocq, Agda, and Idris itself go further: the proof obligation becomes a first-class part of the type. In contrast to what we've seen — where the type checker automatically verifies structural properties and you just declare the type — proof assistants let you encode more complex propositions as types, but to use a function you must also supply an explicit proof that the precondition holds. The machine checks that proof term mechanically, and modern tactic libraries automate increasing fractions of the work."

**IDE / terminal:** None.

---

### Slide 36 — Further Horizon
**Clock target:** 43:00–43:30
**Type:** Horizon

**Visual content:**
```
Beyond what we have shown today:

  Lean 4       — proof-heavy verification used in Mathlib
                 and Mathematics 4; the type checker discharges
                 the proofs you write, with growing tactic
                 automation

  Cubical Agda — richer equality and constructive reasoning;
                 homotopy type theory as a programming language

  HoTT / ∞-categories — the landscape of types as spaces,
                 isomorphism as equality, topology meeting
                 proof theory
```

Bottom:
> "The right question is not 'is this fancy?' It is: 'is this invariant expensive enough to encode?'"

**Speaker notes (30 sec):**
"Lean, Agda, homotopy type theory — that's where the active frontier is. The reason to know they exist isn't to adopt them next sprint. It's to know there's considerably more headroom than what we've shown today, and that the tooling is maturing."

**IDE / terminal:** None.

---


### Slide 37 — Where to Start

**Clock target:** ~43:30–44:00
**Slide class:** `.s-light` (light, `light-slide`)
**File:** `slides/where-to-start.typ`

**Visual content:**
- Four-item beat-grid: NOW / SOON / NEXT / HORIZON investment ladder
- Footer pointer to appendix A7 for the full reading list

**Speaker note summary:** Actionable close — Stage 3 in Java 17 this week, Stage 4 next sprint, Stage 5 in a day, Stage 6 via Brady's Idris book. Closes the talk on a practical note before S38.

---
### Slide 38 — Return to the Promise
**Clock target:** 43:30–45:00
**Type:** Close

**Visual content:**
Bring back the four incident chips (Alice blue, Bob orange, Charlie green, Danielle purple) — but now with large check marks. Then the opening promise, quoted:

```
"Some classes of production incidents are not
'just part of engineering life.'

They are artifacts of using a language and design level
that cannot express the invariants we actually care about."



"With the right type-level encoding, specific bug classes —
forgotten branches, lifecycle violations, protocol drift,
empty boundary values — stop being expressible in our code,
and the runtime incidents that would have followed
disappear with them."
```

Below: "Thank you. Questions?"

**Speaker notes (90 sec):**
"Alice tracked down an invoice that came out wrong because the type system couldn't tell a string from a number at a boundary. Bob's checkout silently took the wrong path because the type system didn't require every branch to be handled when a third was added. Charlie traced an out-of-order state transition through logs because the lifecycle existed in comments, not in the type. Danielle hit a protocol drift because two services had no shared type-level definition of their contract.

These came from a mismatch between what the business required and what the design level could enforce.

We showed today that the gap can be closed — incrementally, with existing tools, without discarding what works. Modern Java goes a fair distance on its own; Scala 3 goes considerably further; Idris 2 shows the horizon.

In aviation, medical devices, and regulated finance, the regulatory threshold has already made the cost-benefit calculation: the cost of encoding the invariant is lower than the cost of a field incident. In commercial software, that threshold is moving too — partly because the tooling is maturing, and partly because generation speed is outpacing the review capacity that used to catch these things.

The question isn't 'should I use dependent types for my CRUD endpoints'. The question is: *is this invariant expensive enough to encode?* The tools are getting cheaper. The set of invariants worth encoding gets bigger every year.

Thank you."

**IDE / terminal:** None.

---

## Section 6 — Optional Q&A Appendix

These slides do **not** count against the 45-minute runtime. They sit at the end of the deck, ready to jump to if a question goes there. None are shown unless asked.

The questions they anticipate:

| Question | Slide |
|----------|-------|
| "What about Scala 3 Capture Checking?" | A1 |
| "What about ZIO / cats-effect — don't they already do this?" | A1 |
| "Where else does the linear / multiplicity-1 idea show up?" | A2 |
| "Can you show the dependent typing in Idris actually rejecting something?" | A3 |
| "Where did this whole tradition come from? More history please." | A4–A6 |
| "What should I read / watch next?" | A7 |
| "Why doesn't Scala just do full dependent types? / what's a match type, really?" | A8 |

---
### Slide A1 — Tracking Capabilities: Capture Checking and Effect Systems
**Type:** Optional Q&A
**Trigger:** capture-checking, ZIO, cats-effect, IO monad, resource leaks, effect tracking.

**Visual content:**
```
The shared concern: tracking *capabilities* — IO, file handles,
DB connections, mutable refs — in the type of every value
that touches them.

Two approaches in Scala today:

  Effect systems (ZIO, cats-effect — production today)
    ──────────────────────────────────────────────────
    Capabilities go into a monad parameter:
      def loadUser(id: UserId): ZIO[Database, DbError, User]
    The R parameter tracks "this needs a Database"; the
    A parameter tracks the success type; E tracks errors.
    Mature, widely deployed, large community libraries.
    Cost: monadic style — for-comprehensions, .flatMap chains.

  Capture Checking (Scala 3, experimental — "Caprese")
    ─────────────────────────────────────────────────────
    Capabilities go directly into the type:
      def loadUser(id: UserId): User^{db}
    The ^{db} says "this value carries the db capability".
    Use-after-close, capability escape across async boundaries,
    effect leaks become compile errors.
    Goal: direct imperative code keeps its shape; no monadic
    wrappers.
    Status: experimental in Scala 3; not yet production.
```

**Speaker notes (if asked, ~60 sec):**
"Effect systems and Capture Checking are two answers to the same problem: how do you put 'this function needs a database' or 'this function touches IO' into the type? ZIO and cats-effect — in production now — do it by wrapping the result in a monad whose parameters track the capability, the error channel, and the success type. The cost is that your code becomes monadic; you stay in for-comprehensions. Capture Checking is the Scala 3 experimental direction that tries to do this without the monad — capabilities are tracked as little tags on the type itself, and your code keeps its imperative shape. They are not exclusive: a project can absolutely use ZIO today and migrate piecewise as Capture Checking matures. If the multiplicity-1 mechanism from Stage 6 comes up here, the linearity slide (A2) covers it — it restricts *how many times* a value may be used, a related but distinct question from *which capabilities* it carries."

---

### Slide A2 — Linearity Across Languages
**Type:** Optional Q&A
**Trigger:** linear types, Rust, Haskell, ownership, %1 -> syntax, borrow checker.

**Visual content:**
```
The "use exactly once" idea isn't unique to Idris 2:

  Idris 2 (QTT)         (1 ch : Session p) -> ...
                        Multiplicities 0 / 1 / ω on bindings.
                        We used this in Stage 6 for the channel.

  Haskell (GHC ≥ 9)     ch %1 -> rest
                        Linear arrow syntax. Same idea, surface
                        difference: annotation on the function
                        arrow rather than the binding.

  Rust (since 1.0)      fn close(c: Channel) { ... }
                        Move semantics + borrow checker. Owning
                        a value means "you have it"; passing it
                        elsewhere moves it. The compiler tracks
                        this throughout. Different formal basis
                        (affine rather than linear — drops are
                        permitted, double-use is not), same
                        engineering payoff for resource safety.

  Clean (1987–)         uniqueness types — historically first.

Each system pays a different design cost:
  • Idris: multiplicities on most binders → noisier signatures
  • Haskell: opt-in syntax → less viral, but no shared library
    ecosystem yet
  • Rust: pervasive, mandatory — the entire language designed
    around it

The trade you pick depends on whether you want
linearity-as-default (Rust) or linearity-as-tool (the others).
```

**Speaker notes (if asked, ~60 sec):**
"Idris 2's QTT is one point in a family of approaches. Haskell with the linear-types extension uses a different surface syntax — `%1 ->` on the arrow rather than on the binding — but the semantics are very similar: a value passed at multiplicity 1 must be consumed exactly once. Rust takes a different formal route — its system is affine rather than linear, meaning dropping values without consuming them is allowed but using them twice is not — and bakes the entire mechanism into the language as ownership and the borrow checker. The engineering outcome for resource safety is similar: file handles, channels, database connections can't be leaked or double-closed by accident. The cost differs: Rust forces every developer to think about ownership all the time; Idris and Haskell let you opt in for resources that benefit, while keeping ordinary code at unrestricted multiplicity. There's no single right point — it depends on whether you want linearity as the default or as a precision tool."

---

### Slide A3 — Live: Dependent Typing Catching a Mismatch
**Type:** Optional Q&A (live demo)
**Trigger:** "Can you show dependent typing actually rejecting something?" / "How do I know the type really depends on the runtime value?"

**Visual content:**
```
runScenarioFor pattern-matches the snapshot and routes to the
right typed handler. The session-end and the assessment both
have types computed from the snapshot:

  runScenarioFor … (MkRiskSnapshot LowRisk    _ _ _ refund _) c s =
    let assessment : Assessment LowRisk n c = …
    par (serverLowRisk    refund assessment s) …

  runScenarioFor … (MkRiskSnapshot MediumRisk _ _ _ refund _) c s =
    let assessment : Assessment MediumRisk n c = …
    par (serverMediumRisk refund assessment s) …

Live edit: in the LowRisk arm, replace serverLowRisk with
serverMediumRisk. Idris responds immediately:

  Error: While processing right hand side of runScenarioFor.
  When unifying:
      Assessment LowRisk n c
  and:
      Assessment MediumRisk n c
  Mismatch between: LowRisk and MediumRisk.

The runtime risk level is in the type of the assessment, AND
in the type of the session. Sending a LowRisk assessment to a
MediumRisk handler is structurally impossible.
```

**Speaker notes (if asked, ~60 sec):**
"Here's how to see the dependent typing doing real work. In `runScenarioFor`, when we pattern-match `snap = MkRiskSnapshot LowRisk _ _ _ refund _`, two things reduce: the assessment type becomes `Assessment LowRisk n c`, and the session-end type becomes `Session (dual (lowRiskProtocol refund n c))`. Both carry the LowRisk index. If I now try to hand them to `serverMediumRisk`, the compiler refuses — the indices don't line up. Watch: *[swap `serverLowRisk` for `serverMediumRisk` in the LowRisk arm; run `idris2 --build payment.ipkg`]*. The error reports the first mismatch it finds — between `Assessment LowRisk` and `Assessment MediumRisk`. The session-end would also mismatch; the compiler stops at the first one. Restore the original — the program compiles again. Same code shape, different runtime risk classification, different type. That's the third lambda-cube axis firing at every dispatch."

**IDE setup:** Have `Main.idr` open at `runScenarioFor` before answering.

---

### Slide A4 — Extended History I · The Pre-History of Formal Structure
**Type:** Optional Q&A
**Trigger:** "Where did this whole tradition come from? Can you say more about the philosophy?"

**Visual content:**
```
Aristotle (4th c. BCE)
  Establishes the foundational concept of formal logic. By
  replacing concrete terms with variables, he shows that the
  validity of an argument can be evaluated entirely by its
  structural form, independent of semantic context.
  → plato.stanford.edu/entries/aristotle-logic/

Leibniz (17th c.)
  Links logic directly to calculation. Unifies truth with
  consistency: "false" means "leads to a contradiction." Conceives
  a universal notation (characteristica universalis) and a
  mechanical calculus (calculus ratiocinator) to reduce reasoning
  to arithmetic. Defines identity: two objects are identical iff
  they share every property.
  → plato.stanford.edu/entries/leibniz/

Boole (1847)
  Realises the algebraic engine. Proves propositional logic —
  including implication — is modelled completely using only AND,
  OR, NOT; logical operations obey strict algebraic laws.
  → plato.stanford.edu/entries/boole/

DeMorgan (1847)
  Exposes the structural dualities within Boolean algebra (the
  laws bearing his name). Treats relations as first-class
  composable mathematical objects, and uses the formal language
  to map the mechanics of mathematical induction.
  → plato.stanford.edu/entries/demorgan/
```

**Speaker notes (if asked, ~90 sec):**
Walk through each beat. Don't read the URLs — they're for the audience to follow up. Aristotle's move from contentful argument to structural form is the seed of the entire tradition. Leibniz wants to mechanise it; the programme fails in his lifetime but the idea is the line we follow to today. Boole and DeMorgan get the algebra working. Bottom line for the audience: "What we now call type-checking is the descendant of a 2,400-year argument about what makes inference valid."

---

### Slide A5 — Extended History II · The Great Synthesis and the Crisis of Consistency
**Type:** Optional Q&A
**Trigger:** "Russell's paradox?" / "Gödel?" / "Hilbert's programme?"

**Visual content:**
```
The Convergence (~1900):
  The algebraic tradition (Boole, DeMorgan, Peirce, Schröder) and
  the proof-theoretic tradition (Frege) fuse. Peano adopts
  Frege's syntactic precision in the mathematicians' symbolic
  clarity. Russell and Whitehead scale this synthesis in
  Principia Mathematica — an attempt to ground all of
  mathematical thought in one unified formal system.

Cantor — set theory as the ground
  Asserts that for any definable property there exists a set of
  objects possessing it. Universe analysed through membership,
  unions, intersections.
  → plato.stanford.edu/entries/set-theory/

Frege (Begriffsschrift, 1879)
  Permanently decouples Syntax (mechanical rules for token
  manipulation) from Semantics (how tokens map to a model).
  Introduces formal variable binding and quantification (∀, ∃)
  within second-order logic — functions over functions,
  abstraction over properties. Bedrock of modern mathematical
  logic, and the system Cantor's principle would break.
  → plato.stanford.edu/entries/frege/
  → plato.stanford.edu/entries/frege-logic/

Russell (1901)
  Exposes a fatal contradiction at the intersection of Cantor's
  intuitive sets and Frege's syntax: unrestricted self-reference.
  "The set of all sets that do not contain themselves" produces
  an infinite loop that destroys logical consistency. The fix:
  Types — a strict hierarchy ensuring a predicate cannot operate
  on objects at its own level.
  → plato.stanford.edu/entries/russell-paradox/
  → plato.stanford.edu/entries/type-theory/

The Constructivists — Brouwer, Heyting, Kolmogorov
  Reject classical platonic semantics. Asserting a statement is
  "true" requires a concrete, step-by-step recipe to construct a
  witness for it. The Law of Excluded Middle (A ∨ ¬A) is not a
  universal axiom; a disjunction is a tagged union requiring an
  active proof of one side or the other.
  → plato.stanford.edu/entries/intuitionism/
  → plato.stanford.edu/entries/intuitionistic-logic-development/

Hilbert (~1900–1930)
  Defines the desiderata for any perfect proof system. Demands
  a meta-mathematical proof that the foundational logic is
  globally:
    Consistent — never derives a structural contradiction ⊥
    Sound (⊢ ⟹ ⊨) — provable via syntax implies true via
                     semantics. In programming: type safety,
                     verified via Progress (well-typed code
                     never gets stuck) and Preservation
                     (evaluation never mutates the type).
    Complete (⊨ ⟹ ⊢) — semantically true implies provable.
  → plato.stanford.edu/entries/hilbert-program/

Gödel (1931)
  Proves global completeness is mathematically impossible. The
  moment a formal language can handle basic arithmetic, it gains
  the capacity for code reflection. By serialising syntax into
  numbers (Gödel numbering), the system can write a statement
  asserting its own unprovability. If the system proves it, it
  is inconsistent; if it cannot, the statement is true but
  unprovable. The field abandons global completeness and focuses
  entirely on protecting Soundness and Consistency.
  → plato.stanford.edu/entries/goedel-incompleteness/
```

**Speaker notes (if asked, ~2 min):**
The arc: Frege builds the modern apparatus of formal logic. Cantor builds the modern apparatus of set theory. Russell shows the combination is inconsistent unless you restrict self-reference — and the restriction is *types*. The constructivists, in parallel, argue that "true" should mean "constructible." Hilbert tries to nail down what a perfect system would have to look like. Gödel proves the strongest version of Hilbert's demand is impossible — which is, paradoxically, what gives modern type theory its scope: we don't try to be complete, we try to be sound, and that we can deliver.

---

### Slide A6 — Extended History III · The Computational Convergence
**Type:** Optional Q&A
**Trigger:** "Curry-Howard?" / "Why is Idris/Lean/Agda called dependent?" / "Where do types-as-propositions come from?"

**Visual content:**
```
Church and Turing (1936)
  Formalise execution by stripping away numbers and sets as
  primitives. Church's untyped λ-calculus proves anonymous
  functions over functions achieve Turing completeness, and
  exposes a fundamental conflict:
    Logical Consistency requires Strong Normalization —
      every evaluation path must terminate; otherwise an
      infinite loop is a fake witness for ⊥, proving any lie.
    Computation requires Turing Completeness — industrial
      languages must allow infinite loops and arbitrary
      recursion.
  Church's Simply Typed Lambda Calculus isolates this: types
  restrict inputs and guarantee termination where logical safety
  is mandatory.
  → plato.stanford.edu/entries/church-turing/
  → plato.stanford.edu/entries/lambda-calculus/

Gentzen (1935)
  Shifts logic from global axioms to local structural
  architecture. Every logical connective is defined purely by
  its interface: how you BUILD it (introduction rules /
  constructors) and how you USE it (elimination rules /
  destructors). Introducing a connective and immediately
  eliminating it is redundant — optimised away by cut
  elimination (a logical analogue of compiler dead-code
  removal).
  → plato.stanford.edu/entries/proof-theory-development/

Howard (1969) — the Curry-Howard isomorphism
  Uncovers a structural identity between Gentzen's logic and
  Church's typed functions. A logical proposition (A ∧ B) is
  identical to a data type (a Tuple). An implication (A → B)
  is a function type. A proof is an executing program; running
  it is simplifying the proof. Writing code that compiles is
  structurally identical to proving a theorem.
  → plato.stanford.edu/entries/type-theory/ (the Curry-Howard
    section)

Martin-Löf (1972) — dependent type theory
  Elevates expressivity by allowing types to depend directly on
  runtime values. A universal statement (∀) becomes a Π-type
  (dependent function): the return type is computed from the
  argument. An existential (∃) becomes a Σ-type (dependent
  pair): a value bundled with a proof depending on it.
  → plato.stanford.edu/entries/type-theory-intuitionistic/

Coquand (1988) — the Calculus of Constructions
  Compresses this lineage into a minimal, uniform core that
  unifies dependent types with polymorphism. The engine for
  Rocq (formerly Coq), Lean, Agda, and Idris: a tiny, auditable
  compiler kernel that type-checks code to provide a
  mathematical guarantee of soundness.

Voevodsky (2000s) — Univalent Foundations / HoTT
  Resolves the ambiguous definition of identity in highly
  expressive type systems. Equality is no longer a static
  true/false flag but a path of transformations (borrowed from
  topology). The Univalence Axiom: if two types are isomorphic,
  they are literally equal. For software: the geometric
  justification for refactoring — two libraries that behave
  identically are interchangeable.
  → plato.stanford.edu/entries/type-theory-homotopy/
```

**Speaker notes (if asked, ~2 min):**
The 20th-century half of the story. Church and Turing formalise computation; the typed lambda calculus is the safe sub-language where evaluation terminates. Gentzen redefines logic as something compositional — every connective has an "introduction" rule and an "elimination" rule, no more no less. Howard sees that these two systems — Gentzen's logic and Church's typed code — are the same mathematical structure under different names. Martin-Löf opens up the type system so types can depend on runtime values, which is exactly what we showed in Stage 6. Coquand packages all of this into the small auditable kernels that power modern proof assistants. Voevodsky reformulates equality itself as a topological object — the most aggressive recent move, still working its way into mainstream tooling.

---

### Slide A7 — Where to Read Next
**Type:** Optional Q&A
**Trigger:** "What should I read?" / "Where do I learn more?"

**Visual content:**
```
For Java/Scala practitioners, in roughly increasing depth:

  Rock the JVM (Daniel Ciocîrlan)
    Scala 3 deep-dive courses, free YouTube channel, blog
    Direct path from "I do Scala at work" to "I know what
    higher-kinded types and given/using really do."
    → rockthejvm.com
    → youtube.com/@rockthejvm

  Type-Driven Development with Idris (Edwin Brady, Manning)
    Hands-on Idris from someone who built it. Best on-ramp to
    dependent types for working programmers.
    → manning.com/books/type-driven-development-with-idris

  Bartosz Milewski — Category Theory for Programmers
    Blog, book (free PDF), and YouTube course. The connective
    tissue between the algebraic structures we used (sums,
    products, functors, catamorphisms) and the underlying
    mathematics.
    → bartoszmilewski.com/2014/10/28/category-theory-for-
      programmers-the-preface/
    → github.com/hmemcpy/milewski-ctfp-pdf
    → youtube.com/playlist?list=PLbgaMIhjbmEnaH_LTkxLI7FMa2HsnawM_

For deeper formal-methods study:

  Pierce — Types and Programming Languages (TAPL)
    The canonical textbook. Working through it is the standard
    rite of passage for type-system implementers.
    → cis.upenn.edu/~bcpierce/tapl/

  Pierce (ed.) — Advanced Topics in Types and Programming
    Languages (ATTPL)
    Successor volume. Subtyping, dependent types, linearity,
    effect systems — each chapter by a domain expert.
    → cis.upenn.edu/~bcpierce/attapl/

  Sørensen & Urzyczyn — Lectures on the Curry-Howard Isomorphism
    The book for the propositions-as-types story. Heavier than
    Pierce; the right next step once the basics of TAPL feel comfortable.
    → Elsevier, 2006 (search by title for current sources)

  Friedman & Christiansen — The Little Typer
    A gentler dependent-types introduction in the Little-Lisper
    tradition. Pie (a tiny dependent language) used throughout.
    → thelittletyper.com

For language-specific reference:

  Scala 3 reference         → docs.scala-lang.org/scala3/reference/
  Idris 2 documentation     → idris-lang.org/pages/documentation.html
  Iron (refined types)      → iltotore.github.io/iron/
  Programming Language Foundations in Agda (Wadler et al.)
                            → plfa.github.io

For verified proofs in practice:

  Lean 4 — interactive in-browser games (HHU Düsseldorf)
    The most accessible on-ramp: play logic, set theory, and
    natural-number proofs as guided puzzles in a real Lean 4
    environment. Built on Lean's Calculus of Inductive
    Constructions — you write actual proofs, not pseudocode.
    Natural Number Game, Set Theory Game, Logic Game, more.
    → adam.math.hhu.de

  Software Foundations (Pierce et al., Rocq-based)
                            → softwarefoundations.cis.upenn.edu
  Lean / Mathlib            → leanprover-community.github.io
```

**Speaker notes (if asked, ~60 sec):**
Order matters here. For someone doing Scala at work, Rock the JVM is the most useful starting point — direct application to what's in your IDE today. From there Brady's Idris book is the cleanest on-ramp to dependent types. Milewski's category-theory series is the connective tissue between the practical patterns we used in Stage 5 and the mathematics underneath. TAPL and ATTPL are heavier — the canonical academic references. The Little Typer is the most accessible book-length introduction to dependent types in a Lisp-style notation. If you want to actually try writing proofs without setting up a toolchain first, the HHU Düsseldorf in-browser Lean 4 games — Natural Number Game, Set Theory, Logic — are the easiest possible start. From there Software Foundations in Rocq and Mathlib in Lean are where the field actually is.

---

### Slide A8 — The Singleton Bridge: mimicking dependent types without paying for them
**Type:** Optional Q&A
**Trigger:** "Why doesn't Scala (or TypeScript) just do full dependent types?" / "How close can a non-dependent language get?" / "What is a match type, really?"

**Visual content:**
```
Scala stops short of full dependent types — but gets surprisingly
close, via a two-step detour around the λ-cube's third axis.

  Step 1 · ι-reduction (match types)
  ─────────────────────────────────
    Stay on the type-operators axis (Fω), but let type-level
    functions pattern-match and recurse. This is the actual
    Dual from Stage 5 (protocol/Dual.scala):

      type Dual[P <: Protocol] <: Protocol = P match
        case End           => End
        case Send[a, n]    => Receive[a, Dual[n]]
        case Receive[a, n] => Send[a, Dual[n]]
        case Choose[l, r]  => Offer[Dual[l], Dual[r]]
        case Offer[l, r]   => Choose[Dual[l], Dual[r]]

    The type checker now runs a compile-time ALGORITHM to
    compute a type. Still types-in, types-out — it cannot
    see runtime values.

  Step 2 · singleton types (the value→type bridge)
  ────────────────────────────────────────────────
    Give a literal a razor-thin type containing only itself:

      def openGate(code: 1234.type): OpenGate
      def openGate(code: Int):       ClosedGate

    1234.type is inhabited by exactly one value. Pairing it
    with match types lets a runtime literal steer a type-level
    computation — dependent-type BEHAVIOUR, compile-time only.

Why not climb to the actual summit (CIC / λΠ)?
  ─────────────────────────────────────────────
    Full dependent types erase the compile/runtime boundary:
    a type may depend on ANY term, so the compiler must be able
    to EVALUATE arbitrary programs while type-checking.

      → that requires TOTALITY checking (every function proven
        to terminate), or the compiler can loop forever
      → which puts a proof burden on ordinary, messy code

    Scala / TypeScript take the cheap detour and keep partial,
    Turing-complete term-level code. Idris / Agda / Lean / Rocq
    pay the totality price to get the real thing — which is why
    Stage 6's honesty note about `believe_me` matters: even
    there, the transport layer steps outside what's proven.
```

**Speaker notes (if asked, ~75 sec):**
"Great question — and the answer is a nice piece of language design. Scala doesn't reach the top of the lambda cube, but it gets close by a detour. Step one: match types. Stay on the type-operators axis — Fω — but let type-level functions pattern-match and recurse. `Dual` is exactly this: a compile-time algorithm that walks a protocol type and flips every send to a receive. The technical name is ι-reduction. It's real computation, but it only sees types, never runtime values. Step two: singleton types. You give the literal `1234` a type, `1234.type`, that contains only that one value. Now you can feed a runtime literal into a match type — and a runtime value steers a type-level result. That's dependent-type behaviour, achieved entirely at compile time. So why not just go to the summit — Idris, Agda, Lean? Because true dependent types erase the boundary between compile time and runtime: a type can depend on any term, so the compiler has to be able to evaluate any program while type-checking. If that program loops, the compiler loops. So you need totality checking — every function proven to terminate — and that pushes a proof burden onto ordinary code. Scala and TypeScript decline that bargain and keep partial, Turing-complete value-level code. Idris and friends pay the price to get the genuine article. It's the same boundary you saw in Stage 6 with the `believe_me` casts: even in a dependently typed language, the moment you hit the untyped transport layer, you've stepped back outside what's proven."

**IDE / terminal:** None (but the `Dual` match type is live in `05-scala3-payment/src/main/scala/protocol/Dual.scala` if someone wants to see it).

### IDE Setup
- [ ] All demo directories open in IDE tabs: `00`, `01`, `02`, `04`, `05`, `06`, `07`
- [ ] Within `04`: `PaymentMethod.java`, `Demo.java` open, `Demo.java:demo4()` visible
- [ ] Within `05`: `Payment.java` open, `Demo.java:demo4_TypestateCompileErrors()` AND `Demo.java:buggyDemo_WrongApprovalMethodStillPossible()` both visible
- [ ] Within `06`: `PaymentDemo.scala:serverMediumRisk` visible, `Derivation.scala:DualityChecks` visible, `Rules.scala:PolicyF` visible
- [ ] Within `07`: `Main.idr:runOrderScenario` visible, `PaymentSessionTypes.idr:dualInvolution` visible
- [ ] Language server running for all languages (red squiggles appear on hover within 1 sec)
- [ ] Dark theme, font size readable at back of room (≥18pt code font)

### Terminal Setup
- [ ] `05-scala3-payment/` has been `sbt compile`d — no build step on stage
- [ ] `06-idris2-payment/` has been built — `./build/exec/paymentdemo` runs without compilation
- [ ] `00-js-untyped-payment/` — `node demo.js` ready to run
- [ ] Terminal font size readable at back of room

### Live Edit Preparation

Five live compile-error moments during the talk. Practise each edit + revert until it takes under 20 seconds.

| # | Stage | Edit | Expected error |
|---|-------|------|----------------|
| 1 | Stage 1 (S18)  | Type `new Authorization(...)` next to the existing call | *"Authorization() has private access"* |
| 2 | Stage 3 (S20)  | Delete the `case Medium m -> "3DS path"` line live    | *"switch covers only 2 of 3 permitted subclasses"* |
| 3 | Stage 4 (S23)  | Uncomment `Payment.capture(init);` in `demo4_TypestateCompileErrors` | *"Payment<Initiated> cannot be converted to Payment<Authorized>"* |
| 4 | Stage 5 (S26)  | Change `ThreeDSApproved(proof)` to `AutoApproved` in `serverMediumRisk` | *"Found: AuthorizedPayment[LowRisk], Required: AuthorizedPayment[MediumRisk]"* |
| 5 | Stage 6 (S31)  | Comment out a `finish done` in any handler in `Main.idr` | *"There are 0 uses of linear name done. Suggestion: linearly bounded variables must be used exactly once"* |

- [ ] Know `⌘Z` (or `Ctrl+Z`) for each — must restore the original within seconds
- [ ] For #3, keep the `// ← UNCOMMENT` annotation in the comment so the audience sees where the edit happens

### Timing Rehearsal Targets
- [ ] Cold open (stories only, no slides): 4:30–5:00
- [ ] Theory section: 5:30–6:00 (never less; never more than 6:30)
- [ ] Stage 3 IDE segment including live delete: 2:45–3:15
- [ ] Stage 5 IDE segment 6a (toolkit, 3 live + 3 walk-through): 2:15–2:45
- [ ] Stage 5 IDE segment 6b (session types + duality + linearity-gap note): 2:30–3:00
- [ ] Total talk: 43:00–45:00

### Hard-Cut Cheat Sheet (tape to lectern or keep as phone note)
```
Behind by 1 min at 11:30  → cut MLTT slide (S13)
Behind by 1 min at 21:00  → trim S24 'still expressible here' bullets to a one-liner
Behind by 1 min at 30:00  → drop the Features 4–6 walk-through; go straight to session types
Never cut Stage 6
```
