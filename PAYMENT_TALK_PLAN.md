# Payment Example Implementation Plan

This file is the technical implementation plan for the staged examples that support the talk.

Its purpose is to define:

- the main worked example domain,
- the progression of expressive power,
- the classes of bugs each rung should still allow or forbid,
- the implementation constraints that keep the examples teachable.

It is not a speaker script, and it should not read like one. The companion narrative and pacing document is [TALK_NARRATIVE_GUIDE.md](/home/mb/workspace/scala-type-driven-talk/TALK_NARRATIVE_GUIDE.md).

One important idea behind the examples is:

> Each rung lets us prove more about values, functions, state transitions, communication procedures, and finally whole program fragments.

That should remain one lens among several, not the only lens. The examples should also show:

- clearer domain models,
- better API design,
- more local reasoning,
- fewer invalid states,
- reduced operational risk,
- and a more honest picture of what different languages are good at.

The talk’s opening incident stories do not need to come from the payment domain. They only need to correspond to bug classes that the worked examples progressively eliminate. The main implementation ladder in the repository should still converge on one coherent domain, and payment remains the best candidate for that.

## Source Of Truth

Treat the current code, not older plans, as canonical:

- `src/main/scala/` is the implemented Scala 3 booking example.
- `idris2/` is the implemented Idris 2 booking example.
- `idris2-payment/` is the new target domain and should become the semantic source of truth for the staged rewrite.

The earlier examples should be derived from the `idris2-payment/` end-state by removing expressive power step by step. Do not design each directory independently. If each stage invents a different domain model, the audience will spend attention reloading context instead of seeing what the type system adds.

## Primary Goal

Build a family of examples that all model the same realistic payment workflow:

1. submit order,
2. derive runtime risk policy from order facts,
3. require no extra step, 3DS, or manual review depending on risk,
4. authorize,
5. capture,
6. optionally refund,
7. maintain an audit trail.

The progression must make three things increasingly obvious:

- more expressive type systems catch more realistic bugs before runtime,
- many defensive tests disappear because illegal states stop being representable,
- the final Idris example closes the runtime-to-type gap that Scala cannot close.

There is a fourth point that should guide implementation choices:

- each stage should feel like a stronger proof discipline, not just a richer syntax.

That point should support the implementation, not dominate it. The examples should still read first as realistic engineering artifacts.

## Separation Of Concerns: Opening Incidents Vs. Worked Example

Do not force the opening incident stories and the main worked example to be the same thing.

Recommended split:

- the opening incidents may come from different domains if that makes them more immediately relatable,
- the main worked example progression should still use one stable domain, so the audience does not have to reload business context at every rung.

This means:

- a JavaScript rung may use a very small example such as a forgotten `parseInt`,
- a later rung may demonstrate typestate or protocol safety in the payment domain,
- the talk can still be coherent because the underlying point is “what stronger guarantees can we now get?” rather than “is every story from the same product area?”

The payment domain should remain the canonical implementation spine for the richer stages, especially from records/sealed onward and certainly for Scala 3 and Idris 2.

## Proof Obligations Ladder

This should guide both implementation and explanation.

The stages are not just accumulating features; they are accumulating stronger obligations that the language can check.

That is not the only way to describe the progression, but it is a useful internal design guide because it helps keep the examples well ordered.

Suggested ladder:

1. check that a value even has the expected basic shape,
2. check that a function is only called with and returns the right kinds of things,
3. check that generic code behaves uniformly across types,
4. check that all relevant variants and branches are handled,
5. check that illegal lifecycle transitions cannot be expressed,
6. check that two interacting procedures obey the same protocol,
7. check that runtime-derived facts come with the evidence required to proceed.

The examples should be chosen to make this ladder visible.

## Non-Negotiable Design Rules

### 1. Keep the domain stable across stages

Use the same concepts in every directory:

- `Order`
- `OrderLine`
- `PaymentMethod`
- `RiskDecision`
- `Authorization`
- `Capture`
- `Refund`
- `AuditTrail`

Names can be adapted to language conventions, but the concepts should not drift.

### 2. Keep the scenarios stable across stages

Use the same sample cases everywhere:

- `lowRiskCardOrder`
- `mediumRiskCardOrder`
- `highRiskInvoiceOrder`
- one invalid boundary case such as zero quantity or empty order

This is critical. The audience should recognize the business cases immediately and focus on what the type system changed.

### 3. Keep the bugs realistic

Do not use fake “string vs int” bugs as the main event after the first stage. The low rung may start with something simple such as a forgotten `parseInt`, but the progression should quickly move to realistic engineering failures.

The important later bugs should be the kind of mistakes competent engineers actually make in payment code:

- capturing before authorization,
- allowing refund on a non-refundable payment path,
- forgetting the 3DS step for a medium-risk order,
- forgetting the manual-review step for a high-risk order,
- capturing the wrong amount because the value came from the wrong object,
- missing an audit event on one branch,
- client and server drifting out of protocol sync.

### 4. The next stage must clearly kill a previous-stage bug

Every directory should intentionally contain one or two bugs that still compile there, but that the next directory makes impossible or much harder.

If a stage does not remove a clearly demonstrated failure mode from the previous stage, it should not exist.

### 5. Favor tiny, comparable examples over “complete applications”

Each directory should stay small:

- one domain file,
- one policy/risk file if needed,
- one flow/demo file,
- optionally one test file,
- optionally one “bad example” file meant to fail in later stages.

Do not add frameworks, persistence, HTTP, databases, or build complexity beyond what is necessary to demonstrate the type-level point.

## Recommended Directory Sequence

Use these directories, unless time forces a collapse:

1. `00-js-untyped-payment`
2. `01-java14-simple-types`
3. `02-java5-generics`
4. `03-java8-function-pipelines`
5. `04-java17-records-sealed`
6. `05-java-advanced-generics-typestate`
7. `06-scala3-payment`
8. `07-idris2-payment`

This sequence is deliberate. It now tracks the talk more closely:

- first get from no types to basic structure,
- then get reusable typed abstraction through generics,
- then make control flow explicit through function values and composable rule pipelines,
- then get products and sums honest,
- then encode process/typestate,
- then move to Scala 3 for type-level protocol structure,
- then move to Idris 2 for runtime-driven dependent typing.

If presentation time is tighter than implementation scope, compress the talk coverage, not the codebase plan:

- `02` and `03` can be covered quickly in the talk,
- `04` and `05` deserve more space,
- `06` and `07` are the main payoff.

Do not remove `03`. Function values and composable processing are a meaningful rung in the conceptual ladder, especially for audiences whose instinct is still “business code is just if-statements plus DTOs”.

## Talk Coverage Priority

The repository can and probably should contain all eight stages, but the live 45-minute talk should not allocate equal time to all of them.

Priority for live coverage:

1. `05-java-advanced-generics-typestate`
2. `06-scala3-payment`
3. `07-idris2-payment`
4. `04-java17-records-sealed`
5. `03-java8-function-pipelines`
6. `02-java5-generics`
7. `01-java14-simple-types`
8. `00-js-untyped-payment`

Interpret this correctly:

- `00` through `03` are still important to implement because they make the progression honest,
- but in the talk they should be handled as compressed setup,
- while `05` through `07` carry most of the conceptual and practical payoff.

This is necessary to keep the full story coherent inside 45 minutes.

## Cross-Domain Incident Bank

The opening stories in the talk may draw from a broader set of domains than the main payment example. That is acceptable and often preferable for relatability.

Recommended incident bank by expressive rung:

- very low rung: forgotten `parseInt`, stringly-typed data ingestion, malformed JSON shape, wrong field names
- simple typing rung: swapped arguments, wrong return shape, invalid nullable/object-shape assumptions
- branching/product-sum rung: forgotten case in a workflow or domain variant
- typestate rung: invalid state transition in checkout, document approval, deployment rollout, or payment capture
- protocol/evidence rung: service integration drift, missing challenge step, missing proof or approval artifact

Use this bank for the cold open and for transitions if needed, but keep the repository’s main implementation ladder centered on the payment example.

## Build Strategy

Implement backward from the target, not forward from scratch.

### Step A: keep `idris2-payment/` as the semantic reference

Its current responsibilities should remain the target:

- refined boundary checks,
- indexed line counts,
- runtime risk classification,
- policy DSL with multiple interpretations,
- protocol derivation from runtime values,
- witness-indexed approval,
- typestate transitions,
- indexed audit trail.

### Step B: derive Scala 3 from it by removing dependent typing

Scala 3 should preserve:

- the domain story,
- session types,
- duality,
- a policy DSL,
- runtime analysis selecting among a fixed set of predeclared protocol variants.

Scala 3 should lose:

- protocols computed from arbitrary runtime values as first-class indexed values,
- witness requirements that depend directly on runtime analysis without a bridging ADT,
- fully dependent indices such as `Vect n`.

### Step C: derive Java typestate from Scala by removing type-level protocol algebra

Keep:

- state-indexed payment objects,
- legal transitions as methods or interfaces,
- explicit risk-decision ADTs if using a modern Java stage.

Lose:

- duality,
- session algebra,
- type-driven client/server protocol matching.

### Step D: derive simpler Java and JS examples by erasing more structure

Each earlier stage should feel like a recognizable simplification of the later one, not an unrelated rewrite.

## Cross-Stage Fixture Set

Use the same facts everywhere. This matters both for pedagogy and for implementation reuse.

### Low-risk card order

- one line item,
- small amount,
- payment method = card,
- no 3DS,
- direct authorize then capture,
- refund allowed.

### Medium-risk card order

- higher amount,
- payment method = card,
- requires 3DS,
- authorize only after challenge success,
- refund allowed.

### High-risk invoice order

- large amount or invoice method,
- requires manual review,
- no refund branch in the normal customer flow.

### Invalid input case

- zero quantity or empty order.

Keep these names and facts stable. That allows side-by-side demos and lets tests be conceptually shared even if not mechanically shared.

## Narrative Coupling Constraints

The code plan should explicitly support the narrative arc from [TALK_NARRATIVE_GUIDE.md](/home/mb/workspace/scala-type-driven-talk/TALK_NARRATIVE_GUIDE.md), but the mapping should be by bug class or proof obligation, not necessarily by exact domain story.

For each stage, there should be a clear answer to:

- what kind of mistake is still expressible here?
- what stronger fact can the next stage establish or check?

Each implementation stage should contain either:

- a runnable bad scenario,
- or a commented “this still compiles here” example,
- or later, a compile-fail example showing that the same mistake is no longer representable.

If the audience cannot see the direct line from the opening incident class to the code on screen, the narrative arc weakens.

## Recurring Bug And Proof Spine

The progression needs both:

- a small number of recurring higher-level bug classes,
- and a well-ordered increase in what the language can establish or check.

Use the following spine.

### Stage-appropriate bug 0: stringly input / forgotten parse

Realistic cause:

- form fields, CSV values, JSON payloads, or environment variables arrive as strings,
- a conversion is forgotten or assumed,
- the system keeps going with the wrong value shape.

Best stage to catch it:

- simple static typing and boundary validation.

Use this only at the very beginning. It is the “baseline stupidity the compiler can remove quickly,” not the heart of the talk.

### Bug 1: capture before authorization

Realistic cause:

- the code exposes `capture(order)` or `capture(payment)` directly without modeling lifecycle state.

Best stage to catch it:

- advanced Java typestate and later.

### Bug 2: Refund on a non-refundable path

Realistic cause:

- invoice and card flows share the same “post-payment” API,
- refund support is modeled as a boolean or comment rather than in the shape of the flow.

Best stage to catch it:

- records/sealed can make branch handling explicit,
- Scala session types and Idris protocol derivation should remove it more strongly by changing protocol shape.

### Bug 3: Medium-risk order silently skips 3DS

Realistic cause:

- risk decision is computed from runtime amount,
- developer forgets to thread that result into the required next step,
- default branch falls through to the fast path.

Best stage to catch it:

- Scala can select from fixed protocol variants after runtime analysis,
- Idris can make the protocol itself depend on the runtime-derived value.

### Bug 4: Wrong amount captured

Realistic cause:

- code captures `order.subtotal`,
- or reuses the pre-discount amount,
- or forgets to use the authorized amount/result object.

Best stage to catch it:

- generics do not solve this,
- typestate helps if the amount lives on the correct state object,
- Scala and Idris should model stronger associations between order, auth, and capture values.

### Bug 5: audit trail missing on one branch

Realistic cause:

- happy path appends audit events,
- refund or manual-review branch forgets to do so.

Best stage to catch it:

- not fully caught until the audit trail becomes part of the constructed state,
- strongest in Idris where legal transitions construct the indexed trail.

## Proof Narrative By Stage

This section is what should connect the implementation plan to the theory section of the talk.

- `00-js-untyped-payment`: we can establish almost nothing statically; even basic value interpretation is fragile.
- `01-java14-simple-types`: we can establish shape-level sanity for values and function signatures.
- `02-java5-generics`: we can establish uniformity properties over families of types and get safer reusable abstractions.
- `03-java8-function-pipelines`: we make more reasoning explicit in code by reifying functions and rule composition, but still establish little about process.
- `04-java17-records-sealed`: we can establish more about the space of valid variants and branch coverage.
- `05-java-advanced-generics-typestate`: we can establish more about legal state transitions.
- `06-scala3-payment`: we can establish richer relationships between values, evidence, and protocols, including path-dependent structure and richer type-level computations.
- `07-idris2-payment`: we can establish facts that directly depend on runtime values and can construct the evidence required for later steps.

## Per-Stage Implementation Plan

Each stage below includes:

- the point of the stage,
- the theory rung it corresponds to,
- what to build,
- which bug should still survive there,
- what the next stage should remove.

### `00-js-untyped-payment`

Purpose:

- establish the business story with maximum familiarity and minimum guarantees.

Theory rung:

- untyped lambda calculus as the “computation without static discipline” baseline.

Files:

- `payment.js`
- optional `payment.test.js`

Implementation shape:

- plain objects for orders, auths, captures, refunds,
- plain functions for `assessRisk`, `authorize`, `capture`, `refund`,
- one demo runner with the three stable scenarios.

Bugs that should remain:

- `capture(order)` can be called without authorization,
- medium-risk order can skip 3DS,
- refund can happen on invoice path,
- amount mismatch can occur if wrong field is used,
- branch-specific audit event can be forgotten.

Pedagogic note:

- this stage should not be stupid code. Make it look like the sort of small service code a decent engineer might write under delivery pressure.

Next stage should remove:

- shape confusion and obvious API misuse.

### `01-java14-simple-types`

Purpose:

- introduce nominal structure and method signatures, but no advanced expressivity.

Theory rung:

- simply typed lambda calculus in spirit: base types plus function signatures.

Files:

- `Order.java`
- `PaymentMethod.java`
- `PaymentFlow.java`
- `Demo.java`

Implementation shape:

- mutable or simple immutable classes,
- service methods like `Authorization authorize(Order order)` and `Capture capture(Authorization auth)`,
- keep risk handling mostly imperative.

Bugs that should remain:

- wrong branch sequencing,
- wrong capture amount,
- skipped 3DS,
- refund on invoice flow,
- missing audit entry.

Bugs this stage should now reject:

- swapped argument order,
- property-name mistakes,
- blatantly wrong object shape usage.

Pedagogic note:

- this stage is about structure, not safety depth.

### `02-java5-generics`

Purpose:

- introduce reusable typed containers and validators without pretending generics solve business invariants.

Theory rung:

- System F / parametric polymorphism.

Files:

- previous stage files, plus
- `Result.java`
- `Validator.java`
- `AuditEntry.java`

Implementation shape:

- `Result<T>` for validations and risk checks,
- generic collection handling for audit and rules,
- maybe generic rule combinators if they remain readable.

Bugs that should remain:

- lifecycle errors,
- skipped 3DS,
- wrong capture amount,
- refund on invoice flow.

Bugs this stage should remove:

- mixing results or collections of the wrong element type,
- some repetitive unchecked casting or ad hoc validation plumbing.

Pedagogic note:

- do not oversell generics. Their real value here is reuse and category safety, not protocol safety.

### `03-java8-function-pipelines`

Purpose:

- make rule-processing and validation explicit as values that can be composed, reused, and reasoned about.

Theory rung:

- function types in mainstream practice; still fundamentally simple typing, but with a much more expressive programming style.

Files:

- `RiskRule.java`
- `Validation.java`
- `AuditStep.java`
- updated flow/demo files

Implementation shape:

- `Function<Order, RiskDecision>` or domain-specific functional interfaces,
- `Predicate<Order>` or equivalent rule checks,
- composable validation/risk pipelines,
- audit or enrichment steps as values rather than only statements.

Bugs that should remain:

- capture before auth,
- refund before capture,
- skipped 3DS if the pipeline result is not enforced structurally,
- wrong amount captured,
- missing audit entry on one branch.

Bugs this stage should reduce:

- duplicated validation logic,
- invisible control flow hidden in large service methods,
- difficulty isolating business rules for tests.

Pedagogic note:

- the point here is not “functions solve correctness.” The point is that explicit composition prepares the ground for later type-level structure and already improves architecture.

### `04-java17-records-sealed`

Purpose:

- make products and sums honest so branch structure becomes explicit and exhaustible.

Theory rung:

- product and sum types in a mainstream setting; a better domain language, still not full protocol typing.

Files:

- `Order.java` as a `record`
- sealed `PaymentMethod`
- sealed `RiskDecision`
- updated flow code using pattern matching or explicit exhaustive branching

Implementation shape:

- `PaymentMethod` variants should be `Card`, `Wallet`, `Invoice`,
- `RiskDecision` variants should be `Low`, `Medium`, `High`,
- risk assessment should return the ADT, not a string or enum plus comments.

Bugs that should remain:

- capture before auth,
- refund before capture,
- wrong capture amount,
- audit omission on one branch.

Bugs this stage should remove or sharply reduce:

- incomplete branch handling,
- accidental “default fast path” for medium/high risk,
- invoice/card confusion caused by flags instead of variant types.

Pedagogic note:

- this is the point where the audience should feel the domain become more truthful.

### `05-java-advanced-generics-typestate`

Purpose:

- encode lifecycle state in types, even if the encoding is awkward.

Theory rung:

- bounded polymorphism and typestate-style encodings; conceptually near System F<: and state-indexed APIs.

Files:

- `PaymentState.java`
- `Payment<S>.java`
- `Authorized.java`
- `Captured.java`
- `Refunded.java`
- updated flow/demo files

Possible encoding options:

- phantom generic `Payment<S>`,
- disjoint state wrappers,
- interface-based transition APIs,
- optionally F-bounded polymorphism if it genuinely helps rather than showing off.

Bugs that should remain:

- medium-risk runtime decision may still need a bridge into the right flow,
- client/server drift is still not modeled,
- some evidence requirements still live outside the type system.

Bugs this stage should remove:

- capture before auth,
- refund before capture,
- some amount/source mixups if capture can only consume `AuthorizedPayment`.

Pedagogic note:

- make the awkwardness visible. This is important architecturally: it sets up why Scala’s richer type system is not “academic ornament” but a simpler encoding of the same intent.

### `06-scala3-payment`

Purpose:

- introduce protocol-as-type, duality, and stronger type-level domain coupling.

Theory rung:

- bounded polymorphism, ADTs, and type-level computation in a practical language; the strongest point in the talk before full dependency on runtime values.

Files:

- mirror the current root `src/main/scala/` structure,
- adapt domain and demo from booking to payment,
- keep a small, runnable session runtime.

Required techniques:

- phantom protocol algebra,
- match-type `Dual`,
- path-dependent types for protocol/evidence relationships,
- sealed ADTs for payment/risk/policy,
- refinement-style boundary validation via smart constructors,
- witness and evidence construction that is visible in the API,
- a policy DSL with multiple interpretations,
- runtime selection among a fixed set of protocol variants.

Desirable additions if they remain teachable:

- an example where a path-dependent type is easier to explain than a large type alias,
- a small “proof-like” compile-time check that feels stronger than ordinary data modeling,
- evidence passed or summoned in a way the audience can see in the IDE.

Important design constraint:

- do not try to fake full dependent typing.
- Scala’s role in this progression is to go as far as possible while still requiring a runtime-to-compile-time bridge.

Bugs that should remain:

- arbitrary runtime-derived protocols still need bridging through a fixed closed set of variants,
- some witness relationships must still be mediated by enums/ADTs instead of direct dependent indexing.

Bugs this stage should remove:

- client/server protocol drift,
- illegal message ordering,
- many state-machine misuse cases,
- some cross-object inconsistencies through stronger typed coupling.

Pedagogic note:

- this is the “professional sweet spot” stage: highly practical, already very powerful, but still with a visible ceiling.

### `07-idris2-payment`

Purpose:

- finish the story with direct dependent typing.

Theory rung:

- beyond the lambda cube’s mainstream stopping point: dependent types combined with session-typed protocol structure and refinement-style boundary validation.

Source:

- `idris2-payment/`

Keep and refine:

- refined order-line and order construction,
- `Vect n`-indexed order contents,
- runtime risk classification,
- policy DSL,
- `protocolDerivedFrom : Order n c -> SessionType`,
- approval witnesses indexed by risk,
- typed authorization/capture/refund transitions,
- indexed audit trail.

Possible future improvement to the Idris payment example:

- add one tiny, isolated theorem or total function that explicitly reads as “this property of the workflow is machine-checked,” so that aspect is visible even to people who only half-follow the dependent typing.

Bugs this stage should remove:

- missing 3DS witness on challenged flows,
- missing manual-review evidence on high-risk flows,
- drift between runtime policy result and protocol shape,
- illegal construction of bad inputs once boundary checks have succeeded,
- lifecycle errors and branch-specific audit omissions where encoded through constructors.

Pedagogic note:

- this stage should feel like the previous stages resolving their last remaining compromises, not like switching to an unrelated theorem-proving demo.

## Compile-Fail Artifact Strategy

To support both implementation and presentation, every stage from `04` onward should eventually include one or more intentionally invalid artifacts.

Recommended naming convention:

- `GoodDemo*`
- `BadCaptureBeforeAuthorize*`
- `BadSkip3DS*`
- `BadRefundPath*`
- `BadWrongAmount*`

What they are for:

- before strong typing, they are runnable or compilable but wrong;
- after stronger typing, they should become compile-fail examples or commented non-compiling fragments used on slides.

This is one of the clearest ways to make “the next rung catches it” visible without overexplaining.

For the live talk, each stage should have at most one primary “bad artifact” on screen. More than that creates noise and burns time.

## Stage-to-Incident Matrix

The examples should be built so the audience can repeatedly revisit the same incidents.

- `00-js-untyped-payment`: all five core bugs can still happen.
- `01-java14-simple-types`: only obvious shape misuse is gone; all opening incidents still fundamentally survive.
- `02-java5-generics`: incidents still survive; reuse improves, but operations pain remains.
- `03-java8-function-pipelines`: incidents still survive, but the logic becomes easier to isolate and discuss.
- `04-java17-records-sealed`: Bob’s skipped-branch story becomes harder to hide because risk variants are explicit.
- `05-java-advanced-generics-typestate`: Alice and Danielle lose their bug classes.
- `06-scala3-payment`: protocol drift and more sequencing errors disappear; Bob’s story is reduced to the runtime-to-type bridge problem.
- `07-idris2-payment`: Bob’s remaining gap disappears, and Evan’s audit/evidence story becomes much stronger by construction.

Do not interpret this matrix too rigidly. It is acceptable if the live talk uses a simpler cross-domain bug early on, such as forgotten parsing, before settling into the payment-domain examples.

## Minimum Viable Example Set For The Talk

To keep the talk understandable for a mixed Java meetup audience, each stage should ideally revolve around one primary bug and at most one secondary bug.

Recommended primary emphasis:

- `00-js-untyped-payment`: forgotten parse / stringly input
- `01-java14-simple-types`: obvious shape/API correctness only
- `02-java5-generics`: reuse and typed containers, not a core incident payoff
- `03-java8-function-pipelines`: rules become explicit values, but Bob still survives
- `04-java17-records-sealed`: Bob becomes harder to hide because risk variants are explicit
- `05-java-advanced-generics-typestate`: Alice and Danielle are removed
- `06-scala3-payment`: protocol drift and stronger sequencing guarantees
- `07-idris2-payment`: Bob’s remaining bridge problem disappears

Recommended secondary emphasis across the later stages:

- Charlie’s wrong amount can be threaded from typestate onward,
- Evan’s audit/evidence story should be saved mostly for Idris unless time is abundant.

This selective emphasis is important. Trying to demonstrate every bug equally at every rung will overload the audience and break the timing.

## Tests By Stage

Do not use the same testing strategy everywhere.

### JS

Need many runtime tests:

- every branch,
- sequencing,
- amount correctness,
- audit coverage.

### Early Java

Still mostly runtime tests, but fewer nonsense-shape tests.

### Sealed/records Java

Need fewer branch-shape tests because the compiler helps with exhaustiveness.

### Typestate Java

Many sequencing tests should disappear or become compile-fail examples instead.

### Scala 3

Turn protocol misuse and duality checks into compile-time examples or compile-time tests where possible.

### Idris 2

Push even more illegal-state checks into typechecking. Tests should focus on business policy decisions and external behavior, not on whether nonsense states can be constructed.

## Mixed-Audience Constraints

These examples are being prepared for a Java meetup with participants from different industries and different experience levels.

That imposes concrete implementation constraints:

- stage APIs must be readable in isolation,
- example names must stay domain-obvious,
- type parameters should be few and motivated,
- proof or evidence language should always be translated back into everyday engineering consequences,
- no stage should require the audience to understand advanced FP jargon before seeing the engineering value,
- “bad” examples should fail for reasons visible from a signature or short snippet, not from ten layers of abstraction.

When in doubt, choose the version that is easier to explain on one slide.

## Implementation Constraint: One-Slide Explainability

Before accepting an example stage, verify that its core move can be shown in a single slide or terminal pane containing:

- one short type or method signature,
- one short usage example,
- one sentence explaining the removed bug class.

If the stage needs a long walkthrough to be intelligible, it is too complicated for this talk and should be simplified.

## Recommended Demo Artifacts Per Stage

Each directory should eventually contain:

- one `README` with exactly what the stage demonstrates,
- one runnable happy-path demo,
- one or two intentionally bad examples,
- one short section titled `What Still Goes Wrong Here`.

That last section is critical. It sets up the next rung honestly.

## Audience Shaping Notes

This matters for implementation because the examples should feel native to the audience.

### Java-heavy audience

Emphasize:

- simpler APIs through stronger types,
- removal of whole test categories,
- fewer invalid states crossing service boundaries,
- state machines encoded once instead of documented everywhere.

### FP-curious mixed audience

Emphasize:

- ADTs,
- exhaustive handling,
- policy interpretation reuse,
- “same structure, many meanings” before dependent typing appears.

### More advanced audience

Emphasize:

- why Scala still needs a bridge,
- why Idris can type-check protocol derivation from runtime values directly,
- how witness-carrying APIs replace comments and defensive branching.

## Practical Next Session Checklist

When continuing this work, do the following in order:

1. Review `idris2-payment/` and decide which parts are the stable semantic target.
2. Implement `06-scala3-payment` by adapting the existing Scala booking example into the payment domain.
3. From that Scala version, design `05-java-advanced-generics-typestate` by erasing session-algebra machinery but preserving lifecycle-state modeling.
4. From the typestate stage, derive `04-java17-records-sealed` by flattening state-indexed transitions back into branch-checked domain modeling.
5. From there, derive `03-java8-function-pipelines` so the rule logic is still explicit but not structurally enforced.
6. Then derive `02-java5-generics` and `01-java14-simple-types` by progressively removing abstraction and constraints.
7. End with `00-js-untyped-payment` by stripping the remaining static structure while preserving the same scenarios and latent bugs.

This reverse derivation is important. It prevents the earlier examples from drifting away from the final destination.

## Final Sanity Check

Before accepting any stage as complete, ask:

- Is the business scenario still recognizably the same?
- Is there a realistic bug that still compiles here?
- Does the next stage clearly eliminate that bug?
- Did we add complexity that the audience will experience as value rather than ceremony?
- Would a working engineer believe this code belongs in the language used for that stage?

If any answer is “no”, revise the stage before moving on.
