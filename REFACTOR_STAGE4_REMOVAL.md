# Handoff: Remove Stage 4 (Phantom Typestate) as Standalone Stage

## Decision and rationale

The talk's criterion is that every stage earns its place by encoding more domain rules at the
type level using **new** type-level mechanisms introduced at that stage. Stage 4 (phantom
typestate) fails this criterion: `Payment<S>` uses generics (Stage 2) and private constructors
(Stage 1). No new type-level feature is introduced. The lifecycle-ordering guarantee it claims
to provide was already structurally enforced at Stage 1 via private constructors, was **lost**
at Stage 3 when `Authorization`, `Capture`, and `Refund` became public Java records, and was
merely **restored** at Stage 4 — not newly achieved.

Phantom typestate is a useful design pattern and belongs in the talk, but as an observation
within Stage 3's IDE demo ("here is a more composable encoding using the same Java 17 toolkit"),
not as a separate stage claiming to close Charlie.

**Charlie closes at Stage 3.** The Java 17 toolkit (sealed + records + private constructors) is
sufficient. Stage 3 closes both Bob (exhaustive dispatch via sealed) and Charlie (lifecycle
ordering via private constructors, shown with the phantom-type encoding as the elegant form).

### New stage numbering

| Old number | New number | Content |
|---|---|---|
| Stage 0 | Stage 0 | JavaScript — unchanged |
| Stage 1 | Stage 1 | Java simple types — unchanged |
| Stage 2 | Stage 2 | Java generics + function types — unchanged |
| Stage 3 | Stage 3 | Java ADTs + typestate (expanded) |
| Stage 4 | **REMOVED** | Phantom typestate — absorbed into Stage 3 |
| Stage 5 | **Stage 4** | Scala 3 |
| Stage 6 | **Stage 5** | Idris 2 |

All files, code, slides, comments, and speaker notes must use the new numbering throughout.
No reference to the old Stage 4, Stage 5, or Stage 6 labels may survive.

---

## 1. Code directories

### Renames
```
04-java-advanced-generics-typestate/  →  03-java-typestate/
05-scala3-payment/                    →  04-scala3-payment/
06-idris2-payment/                    →  05-idris2-payment/
```

### Within `03-java-typestate/` (formerly `04-java-advanced-generics-typestate/`)

This directory now represents a Stage 3 design-pattern demo, not a standalone stage.

Update **every** file's header comment that says "Stage 05" or "Stage 04" (the old internal
numbering) to say "Stage 3 — typestate design pattern". Specifically:

- `Payment.java` header: change "Stage 05: Payment<S extends PaymentState>" → "Stage 3 design
  pattern: Payment<S extends PaymentState> — phantom typestate as a composable encoding of the
  same lifecycle guarantee achievable with separate private-constructor classes."
- `Demo.java` header: update the Lambda-cube line — this is still λω-adjacent but it is not a
  new lambda-cube position beyond Stage 2; remove any claim that Stage 4/5 are distinct positions.
- `Demo.java` — the comment `// closed at stage 6: ...` and `// closed at stage 7: ...`
  (referring to old numbering) should become `// closed at stage 4 (Scala 3): ...` and
  `// closed at stage 5 (Idris 2): ...`.
- `Demo.java` — `buggyDemo_WrongApprovalMethodStillPossible`: the comment "(closed at stage 6:
  Approval[R] phantom indexing)" → "(closed at Stage 4 — Scala 3: Approval[R] phantom indexing)"

### Within `04-scala3-payment/` (formerly `05-scala3-payment/`)

**Private constructors on lifecycle case classes** — this is the main code change here.

In `src/main/scala/payment/Domain.scala`, add `private[payment]` to the constructors of:
- `AuthorizedPayment[R <: Risk]`
- `CapturedPayment`
- `RefundedPayment`

These become:
```scala
final case class AuthorizedPayment[R <: Risk] private[payment](
  order:      Order,
  authCode:   AuthCode,
  approval:   Approval[R],
  auditTrail: List[String],
)

final case class CapturedPayment private[payment](
  order:      Order,
  captureId:  CaptureId,
  auditTrail: List[String],
)

final case class RefundedPayment private[payment](
  order:      Order,
  refundId:   RefundId,
  auditTrail: List[String],
)
```

The `authorize`, `capture`, and `refund` top-level functions are defined at package level in
`payment`, so they retain construction access. External code can only obtain lifecycle objects
by calling those functions. This restores the ordering guarantee (private constructors, same
principle as Stage 1 and Stage 3) while keeping full case-class ADT ergonomics (structural
equality, pattern matching on fields, `.copy()` within the package).

**Add a block comment above the lifecycle types** explaining the combined design:
- Case class → structural equality, pattern matching, ADT ergonomics
- `private[payment]` constructor → only `authorize`/`capture`/`refund` can produce instances;
  external fabrication is a compile error
- Type parameter `R <: Risk` on `AuthorizedPayment` → risk level encoded in the type; only
  `Approval[R]` of the matching risk level produces `AuthorizedPayment[R]`

**Either note — add to Domain.scala header comment:**

`authorize` and `capture` are modelled as infallible for clarity. In production, they would
return `Either[AuthorizationError, AuthorizedPayment[R]]` and
`Either[CaptureError, CapturedPayment]` respectively — network calls to payment gateways can
fail. The `refund` function already demonstrates the correct pattern:
`Either[String, RefundedPayment]`. The type-level encoding of the lifecycle and risk binding
composes naturally with `Either`; both are orthogonal concerns.

**Update all internal comments** that say "Stage 6" → "Stage 4" and "Stage 7" → "Stage 5".

### Within `05-idris2-payment/` (formerly `06-idris2-payment/`)

Update any header comments referencing "Stage 6" to "Stage 5".

### README.md

Update stage descriptions and directory links throughout. Stage 4 (phantom typestate) no longer
has its own directory entry as a standalone stage — reference `03-java-typestate/` as a Stage 3
companion demo.

---

## 2. Slide files

### Files to DELETE
```
touying/slides/22-stage4.typ
touying/slides/23-stage4-payoff.typ
```

Their content is not preserved verbatim — the Stage 3 slides absorb what is needed.

### Files to RENAME

```
touying/slides/21-bridge.typ          →  REWRITE (see below — no longer a bridge to Stage 4)
touying/slides/24-java-ceiling.typ    →  touying/slides/21-java-ceiling.typ
touying/slides/25-stage5.typ          →  touying/slides/22-stage4.typ
touying/slides/26-session-types.typ   →  touying/slides/23-session-types.typ
touying/slides/stage5-mechanisms.typ  →  touying/slides/stage4-mechanisms.typ
touying/slides/27-stage5-payoff.typ   →  touying/slides/24-stage4-payoff.typ
touying/slides/scala3-ceiling.typ     →  touying/slides/scala3-ceiling.typ  (no number, keep)
touying/slides/28-stage6-bridge.typ   →  touying/slides/25-stage5-bridge.typ
touying/slides/29-mltt-running.typ    →  touying/slides/26-mltt-running.typ
touying/slides/30-stage6-payoff.typ   →  touying/slides/27-stage5-payoff.typ
touying/slides/31-the-climb.typ       →  touying/slides/28-the-climb.typ
touying/slides/32-agentic.typ         →  touying/slides/29-agentic.typ
touying/slides/33-horizon.typ         →  touying/slides/30-horizon.typ
touying/slides/34-close.typ           →  touying/slides/31-close.typ
```

Slides `01` through `20` keep their numbers unchanged.

---

## 3. Content changes by file

### `touying/slides/19-stage3.typ` — EXPAND

The Stage 3 IDE segment now covers two beats:

**Beat A (current content):** ADTs — sealed risk hierarchy, exhaustive dispatch via switch
expressions, records for value types. This closes Bob. Unchanged from current content.

**Beat B (new):** Typestate — show that the same Java 17 toolkit can encode lifecycle ordering.
The `03-java-typestate/` directory (formerly Stage 4's demo) provides the code. The key spoken
points:
- Separate classes with private constructors already enforce ordering (Stage 1 approach)
- `Payment<S>` with phantom type parameter is a more composable encoding of the same guarantee:
  one unified type, state as a parameter, the method signatures form a readable state machine
- This closes Charlie — capture without prior authorization is a compile error
- Phantom typestate introduces no new type-level feature; it uses Stage 2 generics + Stage 1
  private constructors in a more elegant arrangement

The eyebrow and stage-opener content should reflect "Stage 3" (not 4). The IDE segment
references should point to `03-java-typestate/`.

**Time note:** Stage 3's demo now runs two IDE beats. Assess whether the clock allocation needs
expanding or whether the typestate beat can be kept brief (showing `Payment.java` signatures
only, without the full live-error demo that was in the old Stage 4).

### `touying/slides/20-stage3-payoff.typ` — REWRITE

**Headline:** "Bob and Charlie Closed — Two Gaps Remain"  
(was "Bob Closed — One Gap Remains")

**CLOSED section:**
- ADTs: sealed hierarchy makes forgotten branches a compile error. (Bob ✓)
- Private constructors on lifecycle types enforce ordering. `Payment<S>` encodes the same
  guarantee as a unified type-parameterised object. (Charlie ✓)

**STILL EXPRESSIBLE section:**
- Risk level not in authorization type — wrong approval method still compiles
- Boundary predicates still runtime checks
- (Same as before but now pointing to Stage 4 / Scala 3, not Stage 5)

**test-list:** items 3 and 4 both `"just-gone"`. Starting summary: "2 invariants already closed
✓ — Stages 1–2". Items 5–9 remain active with new stage labels: `[S·4]` for items 5–7,
`[S·5]` for items 8–9.

**story-strip:** Bob ✓, Charlie ✓, Alice still open, Danielle still open.

**Speaker notes:** Explain that Stage 3 closes Charlie using the same private-constructor
principle that was available at Stage 1. The phantom-type encoding (`Payment<S>`) is the more
elegant form — one unified class rather than three separate named classes — but both use the
same type-level toolkit. The progression of correctness is now: Stage 1 established it,
Stage 3 brings it back with ADT ergonomics and richer design.

### `touying/slides/21-bridge.typ` — REWRITE COMPLETELY

The current content bridges ADTs → phantom typestate. That bridge no longer exists.

New purpose: frame the transition from Java to the Java ceiling to Scala 3.

Suggested content: name what the full Java 17 toolkit can now say (exhaustive dispatch, lifecycle
ordering, amount integrity) and name what it cannot say: no predicate types, no runtime-to-type
bridge, no type-indexed authorization. The ceiling slide (`21-java-ceiling.typ`) develops this;
this bridge slide is the one-paragraph setup.

Eyebrow: `Bridge · Stage 3 → Stage 4`  
Title: something like "What Java 17 Can and Cannot Say"  
Body: brief — three things encoded, three things still out of reach. Speaker notes carry the rest.

### `touying/slides/21-java-ceiling.typ` (renamed from `24-java-ceiling.typ`)

**Content changes:**
- Remove any reference to Stage 4 as a preceding stage — the ceiling now follows Stage 3
  directly
- Any "Stage 4 gave us X; we still can't do Y" language → "Stage 3 gave us X; we still can't
  do Y"
- "Stage 5" references throughout → "Stage 4"
- The ceiling body content (no predicate types, no runtime-to-type bridge, no path-dependent
  approval binding) is unchanged — it remains accurate

### `touying/slides/22-stage4.typ` (renamed from `25-stage5.typ`)

**Content changes:**
- `stage-opener-slide([5], ...)` → `stage-opener-slide([4], ...)`
- Eyebrow: "Stage 5 · Scala 3" → "Stage 4 · Scala 3"
- All body text references "Stage 5" → "Stage 4"
- Speaker notes: all "Stage 5" → "Stage 4"
- Add a note about private constructors as part of this stage's contribution:
  the case-class lifecycle types (`AuthorizedPayment[R]`, `CapturedPayment`, `RefundedPayment`)
  use `private[payment]` constructors — the same ordering guarantee as Stage 3's private
  constructors, now combined with case-class ADT ergonomics (structural equality, pattern
  matching) and the risk-level type parameter on `AuthorizedPayment[R]`
- Add a brief note (body or speaker notes) that `authorize` and `capture` are modelled as
  infallible for clarity; in production they would return `Either[AuthError, AuthorizedPayment[R]]`
  and `Either[CaptureError, CapturedPayment]`, composing naturally with the type-level lifecycle
  encoding. `refund` already demonstrates this pattern.

### `touying/slides/23-session-types.typ` (renamed from `26-session-types.typ`)

Check for any "Stage 5" eyebrow or body references → "Stage 4". Otherwise content unchanged.

### `touying/slides/stage4-mechanisms.typ` (renamed from `stage5-mechanisms.typ`)

- Title/eyebrow: "Stage 5 mechanisms" → "Stage 4 mechanisms"
- Any internal "Stage 5" references → "Stage 4"

### `touying/slides/24-stage4-payoff.typ` (renamed from `27-stage5-payoff.typ`)

**Content changes:**
- Eyebrow: "Stage 5 Payoff" → "Stage 4 Payoff"
- Headline: "Three Stories Closed — Two Gaps Remain" — unchanged (Alice, Bob, Danielle closed
  here for their Stage 4 items; Charlie was already closed at Stage 3)
- **test-list starting summary:** "5 invariants already closed ✓ — Stages 1–3" (not 4, since
  items 1–4 are now all closed by Stage 3)
- Items 5, 6, 7: `"just-gone"` — unchanged
- Items 8, 9: active with `[S·5]` (was `[S·6]`)
- story-strip: all four closed (Alice ✓, Bob ✓, Charlie ✓, Danielle ✓ for protocol drift)
- Speaker notes: replace all "Stage 5" → "Stage 4", "Stage 6" → "Stage 5"

### `touying/slides/scala3-ceiling.typ`

- Any "Stage 5" eyebrow/references → "Stage 4"
- "Stage 6" references → "Stage 5"

### `touying/slides/25-stage5-bridge.typ` (renamed from `28-stage6-bridge.typ`)

- `stage-opener-slide([6], ...)` → `stage-opener-slide([5], ...)`
- "Stage 6" → "Stage 5" throughout
- "Stage 5" → "Stage 4" where referring to the Scala 3 stage

### `touying/slides/26-mltt-running.typ` (renamed from `29-mltt-running.typ`)

Check for stage number references; update any "Stage 6" → "Stage 5".

### `touying/slides/27-stage5-payoff.typ` (renamed from `30-stage6-payoff.typ`)

- "Stage 6" → "Stage 5" in any eyebrow or body text
- Dark culmination slide content ("All four incidents are unrepresentable") — unchanged,
  this is the right emotional beat regardless of stage number
- Speaker notes: "Stage 6" → "Stage 5"; "Stages 5 and 6" → "Stages 4 and 5"

### `touying/slides/28-the-climb.typ` (renamed from `31-the-climb.typ`)

**The summary table requires structural changes:**

Current rows: Stage 0, 1, 2, 3, 4, 5, 6.
New rows: Stage 0, 1, 2, 3, 4, 5.

- **Row "3"** (currently "ADTs: records + sealed"): expand the "what it prevents" column to
  include lifecycle ordering. Suggested: "Forgotten branches. Unhandled error paths. Lifecycle
  ordering — private constructors on lifecycle types make out-of-order construction a compile
  error."
- **Row "4"** (currently "Phantom typestate"): **REMOVE this row entirely.**
- **Row "5"** becomes **Row "4"**: "Scala 3" — same content, renumbered
- **Row "6"** becomes **Row "5"**: "Idris 2" — same content, renumbered

The DOCUMENTED / TESTED / ENCODED ladder below the table is unchanged.

The four incident chips (Alice, Bob, Charlie, Danielle) are unchanged.

**Speaker notes:** Update the narration — remove "Stage 4: lifecycle ordering is no longer a
runtime check or a naming convention, it is a structural guarantee in the phantom type parameter"
and merge it into the Stage 3 description: "Stage 3: algebraic data types close forgotten
branches and unhandled error paths. The same stage, using private constructors on lifecycle
types, closes lifecycle ordering — Charlie's bug. The phantom type encoding is the elegant form
of that same guarantee."  
"Stage 5" → "Stage 4", "Stage 6" → "Stage 5" throughout the notes.

### `touying/slides/29-agentic.typ` (renamed from `32-agentic.typ`)

Check for stage number references; update accordingly.

Also: the existing sentence "The compiler's type error IS the specification" (line 47) is
factually imprecise — the **type** is the specification; the error is what the compiler emits
when a program violates it. Correct to something like: "the type error tells the agent exactly
which part of the specification was violated and what shape would satisfy it — no human needed
to interpret it."

### `touying/slides/30-horizon.typ` (renamed from `33-horizon.typ`)

Check for stage number references; update accordingly.

### `touying/slides/31-close.typ` (renamed from `34-close.typ`)

Check for stage number references; update accordingly.

### `touying/slides/where-to-start.typ`

The SOON entry currently reads "Stage 4 in existing Java — Phantom generics — one interface,
private constructor. One bounded-context service." This entry described a stage that no longer
exists as a separate stage.

**Revised ladder:**

- **NOW**: Stage 3 in existing Java 17 — sealed interfaces + switch expressions + private
  constructors on lifecycle types. The phantom `Payment<S>` pattern is an afternoon of
  refactoring on top. Zero new dependencies.
- **SOON**: Stage 4 — Scala 3 + Iron library. `sbt new` scaffold in the Stage 4 repo.
  90-minute port of a bounded-context service.
- **HORIZON**: Stage 5 — Idris 2. Brady's "Type-Driven Development with Idris" is the on-ramp.

The three-rung ladder (was four) reflects the new structure.

Speaker notes: update "Stage 5 repo", "Stage 6", etc. to new numbers.

### `touying/slides/14-lambda-cube.typ`

**Footer:** "Stages 1–5 move along the first two axes (terms-on-types, types-on-types). Stage 6
crosses into the third." → "Stages 1–4 move along the first two axes. Stage 5 crosses into the
third."

**Speaker notes:** 
- "We move along the `f[A]` axis through Stages 2 to 4. We move along the `F[A]` axis through
  Stages 4 to 5. Stage 6 lifts us into the `B(a)` axis." →
  "We move along the `f[A]` axis through Stages 2 to 3. We move along the `F[A]` axis through
  Stages 3 to 4. Stage 5 lifts us into the `B(a)` axis."
- "Stages 4 to 5" lambda-cube references throughout: update to "Stages 3 to 4"
- "the unique contribution of Stage 6" → "the unique contribution of Stage 5"

### `touying/slides/15-test-spine.typ`

Test item 4: change `[S·4]` → `[S·3]`
```
("4", [Lifecycle ordering — capture only after authorize], [S·3], "active"),
```

Items 5–7: change `[S·5]` → `[S·4]`  
Items 8–9: change `[S·6]` → `[S·5]`

### `touying/slides/17-stage1.typ`, `18-stage2.typ`

Check for forward references to "Stage 4", "Stage 5", "Stage 6"; update accordingly.

### `touying/slides/a01-tracking.typ`

"Stage 6" reference (line 54, linearity) → "Stage 5"

### `touying/slides/a02-tracking.typ`

"Stage 6" reference → "Stage 5"

### `touying/slides/a06-tracking.typ`

"Stage 6" references (lines 27, 38) → "Stage 5"

### `touying/slides/a07-tracking.typ`

"Stage 6" reference (line 65 — Iron) → "Stage 4"  
"Stage 6" reference (line 81 — reading list) → "Stage 5"

### `touying/slides/a08-singleton.typ`, `a09-singletons.typ`

Check for stage number references; update accordingly.

---

## 4. `touying/deck.typ`

**Update the header comment stage map:**
```
// Stage numbering (0–5, six stages):
//   Stage 0  JS untyped baseline         S17
//   Stage 1  Java simple types            S18
//   Stage 2  Java generics + functions    S19
//   Stage 3  ADTs + typestate             S20  (sealed, records, phantom pattern)
//   Stage 4  Scala 3                      S23
//   Stage 5  Idris 2 / MLTT / QTT        S28+
```

Remove the "new slides added" note about `scala3-ceiling.typ` being between stage5-payoff and
stage6-bridge; update to reflect the new positions.

**Update the `#include` sequence** to:
1. Remove `#include "slides/21-bridge.typ"` (or keep if rewritten — see below)
2. Remove `#include "slides/22-stage4.typ"` (deleted)
3. Remove `#include "slides/23-stage4-payoff.typ"` (deleted)
4. Add `#include "slides/21-bridge.typ"` if kept (rewritten content)
5. Use new filenames for the renamed slides:

```typst
#include "slides/19-stage3.typ"
#include "slides/20-stage3-payoff.typ"
#include "slides/21-bridge.typ"           // rewritten; or remove if merged into payoff
#include "slides/21-java-ceiling.typ"     // was 24
#include "slides/22-stage4.typ"           // was 25
#include "slides/23-session-types.typ"    // was 26
#include "slides/stage4-mechanisms.typ"   // was stage5-mechanisms
#include "slides/24-stage4-payoff.typ"    // was 27
#include "slides/scala3-ceiling.typ"
#include "slides/25-stage5-bridge.typ"    // was 28
#include "slides/26-mltt-running.typ"     // was 29
#include "slides/27-stage5-payoff.typ"    // was 30
#include "slides/28-the-climb.typ"        // was 31
#include "slides/29-agentic.typ"          // was 32
#include "slides/30-horizon.typ"          // was 33
#include "slides/where-to-start.typ"
#include "slides/31-close.typ"            // was 34
```

Note: the `// clock` comments at the top of individual slide files will also need updating
since removing Stage 4 shifts all subsequent clock targets by roughly 4–5 minutes earlier.

---

## 5. `PRESENTATION_SLIDE_PLAN.md`

This file is ~2000 lines and contains extensive stage-numbered content. Rather than enumerating
every line, apply these systematic replacements after handling the structural deletions:

### Structural deletions
- Remove the "Slide 22 — Bridge: Stage 3 → Stage 4" section
- Remove the "Slide 23 — Stage 4: Phantom Typestate" section  
- Remove the "Slide 24 — Stage 4 Payoff: Charlie Closed" section

### Content changes to Stage 3 section
- Expand the Stage 3 IDE segment description to cover two beats: ADTs (current) + typestate
  (new — show `Payment<S>` from `03-java-typestate/` as design pattern using existing features)
- Update Stage 3 payoff description to show both Bob and Charlie closed

### Systematic renames throughout
- "Stage 4 Payoff" → remove (absorbed into Stage 3)
- Old "Stage 5" → "Stage 4" everywhere
- Old "Stage 6" → "Stage 5" everywhere
- "stage5-payoff" → "stage4-payoff"
- "stage6-bridge" → "stage5-bridge"
- "stage6-payoff" → "stage5-payoff"
- "the Stage 5 repo" → "the Stage 4 repo"
- `S·4` (lifecycle ordering) → now closed at S·3; update in all payoff table descriptions
- `S·5` (items 5–7) → `S·4`
- `S·6` (items 8–9) → `S·5`

### Clock targets
Stage 4 was allocated ~6 minutes (21:00–27:00 in the plan). After removal:
- Stage 3 (expanded with typestate beat) will run ~21:00–27:00 (same total window)
- Stage 4 (was Stage 5) shifts to ~27:00–35:00
- Stage 5 (was Stage 6) shifts to ~35:00–41:00
- Subsequent slides shift accordingly

The hard-cut rules need updating:
- Old rule 2 "Stage 4 overran" → remove
- Old rule 3 "Stage 5 overran" → becomes rule 2 "Stage 4 overran"
- Renumber accordingly

### Lambda cube diagram in plan (ASCII art section ~line 561)
- Update stage labels on the diagram: "Stage 4: Java" → "Stage 3: Java (ADTs + typestate)",
  "Stage 5: Scala 3" → "Stage 4: Scala 3", "Stage 6: Idris 2" → "Stage 5: Idris 2"
- Update surrounding narrative text for stage numbers

---

## 6. Things to verify after changes

- [ ] `typst compile touying/deck.typ deck.pdf` compiles without errors
- [ ] `make talk.pdfpc` succeeds
- [ ] Slide count in rendered PDF: should be ~32 main slides (was ~34), reflecting removal of
      2 slides (22, 23) with 21-bridge rewritten rather than removed
- [ ] All `test-list` components in payoff slides show correct `S·N` closed labels with the new
      numbering
- [ ] `20-stage3-payoff.typ` story-strip: Bob ✓, Charlie ✓, Alice open, Danielle open
- [ ] `24-stage4-payoff.typ` story-strip: all four incidents ✓
- [ ] `28-the-climb.typ` table: 6 rows (0–5), no phantom-typestate row
- [ ] `15-test-spine.typ`: item 4 shows `[S·3]`
- [ ] No `S·6` appears anywhere in the main deck slides
- [ ] `04-scala3-payment/src/main/scala/payment/Domain.scala` compiles with `private[payment]`
      constructors and all existing tests pass
- [ ] `sbt test` in `04-scala3-payment/` passes
- [ ] `where-to-start.typ` has a three-rung ladder (NOW / SOON / HORIZON), not four
- [ ] No file under `touying/` still imports or references `22-stage4.typ` or `23-stage4-payoff.typ`
- [ ] No code file still has a header comment referencing "Stage 05" or "Stage 06" (old internal
      numbering)
- [ ] `README.md` stage table reflects 6 stages (0–5)
- [ ] `MANIM_VIDEO_PLAN.md` (if it references stage numbers): update Stage 4→removed,
      Stage 5→Stage 4, Stage 6→Stage 5

---

## 7. Open question for the implementing session

**Stage 3 time budget:** The IDE demo for Stage 3 now covers two beats (ADTs + typestate). The
current Stage 3 allocation is approximately 6–7 minutes. Assess during implementation whether:
- The typestate beat can be kept to 90 seconds (showing `Payment.java` signatures only, not a
  full live-error demo), making the combined demo fit in ~7 minutes, or
- The Stage 3 window needs expanding to 8–9 minutes, with a corresponding trim elsewhere

The hard-cut rule for Stage 3 overrun should specify which beat to cut first: if time is tight,
cut the typestate pattern explanation and rely on the payoff slide to note that Charlie is closed.
The typestate code exists in the repo; the audience does not need a live demo of it to accept
the claim.
