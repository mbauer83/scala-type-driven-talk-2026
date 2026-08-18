A6-monday · cap 0:55 · Act 6 beat 2 of 3 · MERGE of v1 where-to-start + 33-horizon

TALKING POINTS
1. Monday. Each of these is a change one team makes in one service
2. And can undo in one service. That is the whole blast radius
3. NOW — sealed interfaces and switch expressions. An afternoon
4. SOON — phantom typestate, on the one service that has a lifecycle. A sprint
5. NEXT — Scala 3 and Iron, where tonight's refinements came from. Scaffold is
   in the repository
6. HORIZON — Brady's Idris book; Lean if you want the proof end, and it has
   browser games that teach it
7. Reading list is in the appendix

VERBATIM

"So, Monday. Every one of these is a change one team can make inside one service,
and undo inside one service if it turns out to be a mistake.

Now: sealed interfaces and switch expressions, which is an afternoon.

Soon: phantom typestate, on the one service you have that carries a lifecycle —
that is a sprint, and it touches nothing else.

Next: Scala three and the Iron library, which is where tonight's refinements came
from; the scaffold is in the repository.

And on the horizon, if you want to see where the proof end of this goes, Brady's
Idris book is the on-ramp, and Lean will teach you in a browser game."

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
  JEP 361 switch expressions). Pattern matching for `switch` finalised in 21;
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

WHY THE FOUR RUNGS KEEP THEIR v1 WORDING
`NOW / SOON / NEXT / HORIZON` and the four one-line costs were already right, and
they are the one place in the deck where the audience is told to do something.
What changed is the frame at the top, the horizon row, and the removal of the
*is this mature?* landing line.

JOIN
Backwards: `A6-cost` ended on the question this slide answers in four steps.
Forwards: `A6-close`, which is the thesis and nothing else.
