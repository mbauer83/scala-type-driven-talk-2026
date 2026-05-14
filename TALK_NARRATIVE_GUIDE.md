# Type-Driven Payments Talk: Narrative Guide

This file is the companion to [PAYMENT_TALK_PLAN.md](/home/mb/workspace/scala-type-driven-talk/PAYMENT_TALK_PLAN.md).

Its job is different:

- `PAYMENT_TALK_PLAN.md` defines what to implement,
- this file defines how to turn those implementations into a coherent, persuasive, audience-appropriate talk.

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
2. `3-4 min` opening incidents and human cost
3. `6-7 min` history, motivation, and theory
4. `28-30 min` practical progression through the examples
5. `2-3 min` conclusion and “beyond” glimpse

This balance matters. The theory should orient the audience, but the center of gravity must remain the practical progression.

## 45-Minute Delivery Plan

Use this as the default live schedule:

1. `00:00-00:30` personal intro
2. `00:30-04:00` cold open with incidents
3. `04:00-10:30` history, motivation, lambda-cube map
4. `10:30-13:30` JS + simple Java
5. `13:30-17:00` generics + function pipelines
6. `17:00-21:00` records/sealed
7. `21:00-27:00` Java typestate
8. `27:00-35:00` Scala 3
9. `35:00-42:00` Idris 2
10. `42:00-45:00` return to opening promise, summarize, horizon

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
2. Each increase in type-level expressivity removes a more realistic class of bug.
3. Java can already go surprisingly far with ADTs and typestate-style encodings.
4. Scala 3 lets us encode protocol structure and duality directly.
5. Idris 2 removes the remaining runtime-to-type bridge.

Everything else is subordinate to these five points.

Notice that none of these five points require the talk to sound like a theorem-proving lecture. “Proving more things” is a useful explanatory thread, but the primary payoff should still feel like ordinary engineering value.

## Opening: Human Stakes First

The opening should not begin with definitions, the lambda cube, or “what is a type?”.

It should begin with credible operational pain.

The audience should first feel:

- these are bugs I have seen,
- these are bugs that cost sleep, money, and trust,
- these are bugs that were not caused by stupidity,
- these are bugs that a stronger language/design could have prevented.

Do not mention the solution yet. Let the pain stand on its own for a moment.

## Suggested Cold Open: Four On-Call Mini-Stories

Use named developers because people remember people better than abstract failure modes.

Keep the stories short, concrete, and slightly uncomfortable. They should sound like incidents that happened in a competent team under normal pressure.

In a 45-minute talk, use four stories, not five. Evan should remain optional and likely be omitted live unless the room is highly engaged and pacing is ahead of schedule.

These opening stories do not all have to come from the payment domain. In fact, using multiple domains can make the talk more broadly relatable, as long as each story foreshadows a kind of proof the later examples will make possible.

## Concrete Incident Suggestions

These are not mandatory scripts, but they are concrete enough to present directly with only minor wording changes.

### Alice: stringly-typed input at a pricing boundary

Scenario:

- an internal admin tool exports CSV rows with `quantity` and `unitPrice` as strings,
- a Node.js import job builds draft invoices from those rows.

Concrete bug:

- the code computes `total = row.quantity + row.unitPrice` instead of parsing both fields first,
- for the row `quantity = "2"` and `unitPrice = "15"`, the stored total becomes `"215"` instead of `30`.

Why this is a good opening example:

- everybody understands it immediately,
- it is low on theory and high on relatability,
- it cleanly motivates the first rung: basic static typing and boundary validation.

### Bob: forgotten workflow branch in a risk decision

Scenario:

- an e-commerce checkout service classifies orders as `low`, `medium`, or `high` risk,
- only medium-risk card orders must go through 3DS.

Concrete bug:

- a new `medium` risk branch was added to the risk engine, but the application flow still has `if (risk == low) fastPath() else manualReview()`,
- medium-risk card orders incorrectly go through the low-risk fast path and skip 3DS entirely.

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
- one cancelled rollout is accidentally released to production during an overnight incident.

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

This section is not a survey course. Its job is to answer three questions:

1. Why has formalizing reasoning mattered for so long?
2. Why do types exist at all?
3. What kind of additional expressive and checking power are we gaining as we move through the examples?

If the audience finishes this section thinking “I now know all of proof theory,” it went wrong.

If they finish thinking “I see that types are part of a long tradition of formalizing valid reasoning, and I have a map for the stronger guarantees and checks we’re about to gain,” it worked.

## Theory Section: Recommended Arc

This section should take `6-7 minutes`, not `10`, in the default version of the talk.

Prepare a longer variant for special occasions, but the 45-minute version needs a strict cut.

### Part 1: Formalizing thought is an old ambition

Keep this brisk.

Possible arc:

- Aristotle, `4th century BCE`: early formal logic as a study of valid inference.
- Euclid, around `300 BCE`: a canonical example of systematic axiomatic reasoning.
- Immanuel Kant, `1724-1804`: logic as a condition on rational thought, though still pre-symbolic in the modern sense.
- George Boole, `1815-1864`: algebraic treatment of logic.
- Charles Sanders Peirce, `1839-1914`: formal logic and relational thinking.
- Gottlob Frege, `1848-1925`: predicate logic and a far more expressive formal language.

Message:

- logic became increasingly explicit, symbolic, and structurally precise.

### Part 2: Precision created both power and paradox

Names to touch briefly:

- Bertrand Russell, `1872-1970`: paradoxes force us to confront unrestricted self-reference.
- David Hilbert, `1862-1943`: formalization, consistency, and proof as objects of study.
- Alfred Tarski, `1901-1983`: semantics and truth in formal languages.
- Kurt Gödel, `1906-1978`: hard limits on what formal systems can prove about themselves.

Message:

- formal systems are powerful, but naive expressiveness is dangerous;
- “types” are not decoration, they are one answer to controlling expressive power so that stronger guarantees remain sound.

### Part 3: Logic and computation become deeply connected

Key figures:

- Alonzo Church, `1903-1995`: lambda calculus and foundational computation.
- Haskell Curry, `1900-1982`, and William Alvin Howard, `1926-2007`: the propositions-as-types/programs-as-proofs correspondence.
- Jean-Yves Girard, `born 1947`: System F and polymorphism.
- Per Martin-Löf, `born 1942`: constructive type theory and dependent types.
- Joachim Lambek, `1922-2014`: categorical and logical structure relevant to typed calculi.
- Vladimir Voevodsky, `1966-2017`: modern developments pointing toward homotopical and richer foundations.

Message:

- at this point, types are no longer just “labels on values”;
- they become a disciplined language for expressing valid construction, stronger guarantees, and in some settings machine-checked proof.

## Theory Section: Concepts To Hit

Keep the phrasing practical, not textbook-heavy.

### Constructivity

Say:

- in constructive mathematics and intuitionistic logic, to claim something exists, you should be able to construct it;
- programs fit this worldview naturally because a valid computation is itself a construction.

Connect immediately to the talk:

- when the type checker accepts a program, it is not just allowing a sentence; it is verifying a construction under certain rules.
- each later stage lets the checker verify stronger claims, but those claims matter because they improve real engineering outcomes.

### Predicativity and impredicativity

This should be short and careful.

Say:

- some systems only allow definitions built from previously available layers;
- others allow more self-referential or “quantify over everything including the thing being defined” patterns;
- that extra power is useful but delicate.

Use this mainly to position System F and richer calculi, not to digress into foundational controversy. In the 45-minute version, this is probably one sentence, not a subsection with examples.

### Lambda calculus to typed calculi

Give the compression:

- untyped lambda calculus gives expressive computation but few safety boundaries,
- STLC adds simple function typing,
- System F adds polymorphism,
- System F<: adds bounded polymorphism and structured subtype constraints,
- System F omega adds richer type operators and abstraction over type constructors,
- dependent type theories go further by letting types depend on values.

Frame this as an increasing-strength ladder:

- first we check small local facts,
- then reusable generic facts,
- then structural facts about branching and state,
- then relational facts about interacting components,
- and finally facts whose very statement depends on runtime values.

### Barendregt’s lambda cube

This is the map, not the destination.

Use it as a compact way to explain three axes of increased expressive power:

- terms depending on types,
- types depending on types,
- types depending on terms.

Do not spend long on notation. The point is:

- each step in the practical examples is buying additional expressive power,
- and that power lets us state and check more business invariants directly.

## Theory Section: What To Avoid

Avoid these failure modes:

- lecturing the room as if they signed up for a logic seminar,
- proving theorems on slides,
- spending too long distinguishing schools of foundations,
- introducing too many symbols too early,
- using category theory as a prestige signal.

You can mention homotopy type theory, cubical Agda, and topos theory later as “further horizon” material. They should not occupy the center of this talk.

For a mixed Java meetup, explicitly avoid assuming prior knowledge of:

- ADTs,
- variance,
- proofs-as-programs,
- category theory,
- theorem provers.

Introduce only the minimum needed to follow the engineering argument.

Also avoid treating “proof” as if it only means fully formal theorem proving in a separate assistant. One useful educational move of the talk should be:

- a smart constructor is already a way of packaging evidence,
- an exhaustive match is already a branch obligation discharged,
- a typestate transition signature is already a strong statement about legal next steps,
- a protocol duality check is already a strong compatibility claim,
- dependent types let us state and check even stronger such claims.

## Practical Section: Governing Principle

After the theory section, the talk should become relentlessly concrete.

Each stage should follow the same rhythm:

1. show the current implementation style,
2. show the realistic bug it still allows,
3. identify the missing expressive/checking power,
4. move one rung up,
5. show how that bug is now caught or structurally removed,
6. be explicit about what still remains unsolved.

This repeated structure is what makes the talk intelligible rather than just impressive.

## Practical Section: Suggested Stage Narrative

This section should track the directories from [PAYMENT_TALK_PLAN.md](/home/mb/workspace/scala-type-driven-talk/PAYMENT_TALK_PLAN.md), but the talk does not need equal time for each stage.

### Stage 0: JavaScript

Narrative role:

- establish the baseline of maximum freedom and maximum latent risk.

Main message:

- the program is easy to write but hard to trust.

Use one or two examples only:

- capture before authorization,
- skipped 3DS because risk was computed but not enforced.

Do not linger. This stage exists so the later gains are visible.

### Stage 1: Simple Java

Narrative role:

- show the first real win of nominal structure.

Main message:

- types already remove nonsense, but not process errors.

Make sure the audience sees this distinction:

- “wrong shape” bugs get caught,
- “wrong state / wrong flow / wrong evidence” bugs remain.

### Stage 2: Generics

Narrative role:

- show that polymorphism helps structure and reuse, but it is not magic.

Main message:

- generics reduce duplication and category mistakes,
- they still do not encode lifecycle or business constraints.

This is where you can briefly name System F and say:

- we have moved to terms depending on types;
- useful, powerful, still far from enough.

### Stage 3: Function pipelines

Narrative role:

- show that making business rules explicit as values improves structure before it improves guarantees.

Main message:

- higher-order composition helps isolate logic and reduces duplication,
- but it does not yet force the right lifecycle or protocol.

Keep this very short live. The value of this stage is that it prepares the audience for “structure first, stronger guarantees later”.

### Stage 4: Records and sealed unions

Narrative role:

- show that domain honesty matters.

Main message:

- product and sum types stop us from lying about possible states and branches.

This is a good place for the skipped-3DS story:

- once `RiskDecision` is explicit as `Low | Medium | High`, forgetting a branch becomes harder to hide.

But be honest:

- the compiler may force you to branch,
- it still does not force the branch to carry the right subsequent protocol.

### Stage 5: Advanced Java typestate

Narrative role:

- this is the first big “wow, the type system is modeling process” step.

Main message:

- capture-before-authorize and refund-before-capture are no longer just tested rules; they are illegal constructions.

This stage should also show strain:

- the design is conceptually right,
- the encoding is verbose and awkward.

That awkwardness is rhetorically useful. It creates appetite for a language that expresses the same idea more directly.

If you include F-bounded polymorphism, present it as one tool among several, not the headline.

### Stage 6: Scala 3

Narrative role:

- show the professional sweet spot: protocol as type, duality, stronger compile-time structure, but still not full dependency on runtime values.

Main message:

- now we can model not only payment object states, but communication behavior itself.

In the Scala stage, make sure to surface three specific ideas visibly in the IDE:

- refinement-style boundaries through smart constructors,
- path-dependent types or associated-type style relationships,
- evidence values or compiler-constructed witnesses.

This is where the audience should feel a major leap:

- illegal message order is caught,
- client/server drift is caught,
- several runtime checks disappear,
- the policy DSL can select between predeclared variants.

Then show the ceiling clearly:

- the risk analysis lives at runtime,
- the full protocol type still cannot simply be computed from arbitrary runtime values in the same direct way Idris allows.

This is where you name the remaining bridge, and why it exists.

### Stage 7: Idris 2

Narrative role:

- the end of the climb.

Main message:

- the remaining runtime-to-type gap is gone.

Key moments to land:

- runtime order facts drive risk analysis,
- risk analysis drives protocol shape,
- required evidence depends on that result,
- legal lifecycle transitions construct the audit trail,
- duality is not just checked on examples but stated as a theorem.

If the audience is following well, say explicitly that the later stages are no longer just “using types to avoid bugs”; they are using types to state and check progressively richer properties of the program.

This is where you return to Alice, Bob, Charlie, and Danielle.

Not by saying “types are cool,” but by saying:

- Alice’s premature capture is impossible because the state transition is not expressible.
- Bob’s skipped 3DS path is impossible because the protocol path is derived from the risk result.
- Charlie’s amount confusion is structurally constrained by the typed lifecycle objects.
- Danielle’s invalid refund path is absent from the protocol where refund is not permitted.

## Timing Guidance For The Practical Section

Rough pacing for the `28-30 minute` practical block:

- `3 min` JavaScript + simple Java
- `3-4 min` generics + function pipelines
- `4 min` records/sealed unions
- `6 min` advanced Java typestate
- `8 min` Scala 3
- `7 min` Idris 2

This is intentionally back-loaded. The later stages deserve more time because they are where the strongest payoff and the most unfamiliar ideas live.

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

Then give a short “beyond” glimpse:

- Lean for proof-heavy verification and theorem proving,
- Cubical Agda for richer equality and constructive reasoning,
- perhaps a brief nod to homotopy type theory and topos-theoretic perspectives as examples of how far the landscape extends.

That ending should be aspirational, not obligatory. The audience should leave with a practical win, not a feeling that everything short of full theorem proving is worthless.

In the 45-minute version, this “beyond” glimpse should be under one minute.

## What The Audience Should Remember

If the talk works, a week later the audience should remember roughly this:

- some production pain is caused by invalid states being representable,
- stronger types are a practical way to remove those states,
- the history of logic and type theory explains why these tools exist,
- stronger type systems are also understandable as stronger checking disciplines,
- Scala 3 gets surprisingly far,
- Idris 2 can express the final step where runtime analysis itself shapes typed protocol structure,
- the right question is not “is this fancy?” but “is this invariant expensive enough to encode?”

## Speaker Preparation Notes

Before giving the talk, prepare these transitions explicitly:

- from incidents to theory,
- from theory to the first code example,
- from Java typestate to Scala 3 session types,
- from Scala 3’s ceiling to Idris 2’s payoff,
- from the final demo to the closing horizon.

Those transitions are where talks like this usually either come alive or lose the room.

Also prepare a short version and a long version of the theory section:

- short version: `7 minutes`
- long version: `10 minutes`

That gives you flexibility if the room is highly engaged on the practical side.

Also prepare a hard-cut version of each practical stage:

- one sentence,
- one code signature,
- one surviving bug,
- one new guarantee.

If you start slipping on time, cut detail rather than cutting the final Scala/Idris payoff.

## Coordination With The Implementation Plan

As you implement each example stage, verify two things against [PAYMENT_TALK_PLAN.md](/home/mb/workspace/scala-type-driven-talk/PAYMENT_TALK_PLAN.md):

- the code actually supports the bug/story claimed here,
- the next stage actually removes that bug in a visible way.

If either is false, fix the implementation before refining the slides.
