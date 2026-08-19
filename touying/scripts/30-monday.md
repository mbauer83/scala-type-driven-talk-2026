A6-monday · cap 0:44 · Act 6 beat 3 of 4 · MERGE of v1 where-to-start + 33-horizon

TALKING POINTS
1. If you want to try any of it — cheapest first, and none of it needs a mandate
2. An afternoon — sealed interfaces and switch expressions
3. One service — phantom typestate, wherever there is a lifecycle
4. A weekend — Scala 3 and Iron, where tonight's refinements came from. The
   scaffold in the repository builds as it stands
5. A rabbit hole — Brady's Idris book; Lean if you want the proof end, and it
   teaches itself in a browser
6. Reading list is in the appendix

VERBATIM

"So if any of this looks worth trying, here it is cheapest first — and each one
is small enough to do on your own, before anybody has to agree to anything.

An afternoon: sealed interfaces and switch expressions, and the compiler starts
checking that you handled every case.

One service: phantom typestate, wherever you have a lifecycle — it comes back out
as easily as it went in.

A weekend: Scala three and the Iron library, where tonight's refinements came
from; the scaffold in the repository builds as it stands.

And a rabbit hole, if you want the proof end of this: Brady's Idris book is the
on-ramp, and Lean will teach you in a browser game."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

GRADUAL TYPING LANDS HERE, NOT ON `A6-cost`
Part 3 assigns it to the cost slide because *how do I start without a rewrite* is
the question that slide exists to answer. It is answered better here, because
this slide **is** the incremental ladder — so the point becomes the ladder's
frame rather than an aside twenty seconds long. It is also in the room's own
terms, which was the plan's own instruction: a raw type interoperating with a
generic one, and `@Nullable` layered onto an existing codebase, are both things
this audience does already. Kotlin's platform types and TypeScript are the other
two examples in the plan; they are the answer if somebody asks, and they cost
words here for nothing this room has not already lived.

The move the sentence makes: *adopt a type system* is a migration and nobody has
budget for one; *add a type layer to one module* is a local decision, and there
are as many of them as you like. Deviation from Part 3, flagged, reversible.

`33-horizon` IS THREE LINES NOW, WHICH IS WHAT THE PLAN SAYS
v1 gave Lean, Cubical Agda and HoTT a slide with three callouts and a landing
line. `budget.tsv` has said *33-horizon — three lines on A6-monday* since the
cut list was written, and Part 4 lists the slide as gone. It is the HORIZON row
here, and it keeps the one thing worth keeping: Lean's browser proof games are a
genuinely good on-ramp and somebody in the room will go and play one.

The landing line v1 had on `33-horizon` — *the right question is not »is this
fancy?«* — is gone twice over: it is R1, and `A6-cost` has already said the
positive version one slide earlier.

FACTS
- Sealed interfaces and switch expressions: Java 17 (JEP 409 sealed classes,
  JEP 361 switch expressions). The slide says **Java 17+** (MB, 19 Aug) — the
  bare version number read as "on 17", and the audience is on 17, 21 or 25. Pattern matching for `switch` finalised in 21;
  Stage 3's code is what `03-java-function-types-sealed/` compiles.
- *Type-Driven Development with Idris*, Edwin Brady, Manning 2017. Written
  against Idris 1; the ideas carry, the syntax has moved. Say *the on-ramp*, not
  *the manual*.
- Lean 4's teaching games are at `adam.math.hhu.de` — Natural Number Game, and
  others. Free, in-browser, no install. This is the single most likely thing
  anybody in the room actually does on Monday.
- The Iron library: `io.github.iltotore` `iron` `2.6.0`,
  `05-scala3-payment/build.sbt:12`. Naming it is the R8 case where the audience
  wants the name so they can go and find it.
- The full reading list is appendix `a07-tracking`. The slide points at it; do
  not read it out.

WHY THE RUNGS ARE LABELLED BY COST NOW (MB, 19 Aug)
They used to read `NOW / SOON / NEXT / HORIZON`, and MB's objection is the right
one: that is a schedule, and it is a schedule for a team whose backlog, services
and hiring you know nothing about. *Soon: phantom typestate — that is a sprint*
tells a room of strangers how to spend a sprint.

`AN AFTERNOON / ONE SERVICE / A WEEKEND / A RABBIT HOLE` says the same four
things as a price rather than as a date, and every one of them is now something
**one person** can do without a decision above their head — which is also the
honest claim, since nobody in the room can commit their team from a chair at a
meetup. The title carries the invitation, so the list reads as an offer.

**All of this is reversible.** The old labels and the old lead line —
*»Every one of these is a change one team can make inside one service, and undo
inside one service if it turns out to be a mistake«* — are in git, one revert
away, and the spoken words here are MB's to rewrite in his own register.

JOIN
Backwards: `A6-cost` ended on the question this slide answers in four steps.
Forwards: `A6-close`, which is the thesis and nothing else.
