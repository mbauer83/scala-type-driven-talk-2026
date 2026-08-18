A6-now · cap 1:10 · Act 6 beat 2 of 4 · NEW · partly un-merges v1 32-agentic

TALKING POINTS
1. Code arrives faster than anyone can read it. That is the second reason
2. A hard constraint — enforced on every line, from every author, every build.
   Not a convention somebody has to remember
3. The densest statement of intent you can put in a file
4. A signature says what a thing is for, and it cannot drift, because it is
   checked on every build. A comment can
5. And it answers in seconds, by name
6. Found Approval of LowRisk, required Approval of MediumRisk — that says
   exactly which thing to change
7. A review comment for a person; a specification for whatever wrote the patch
8. Deliver this slowly. It is the practical argument the room came for

VERBATIM

"There is a second reason that set keeps growing. Code now arrives faster than
anybody can read it.

A type is a hard constraint. The compiler applies it to every line, from every
author, on every build — and it does not get tired at four in the afternoon, or
care what wrote the diff.

It is also the densest statement of intent you can put in a file. A signature
says what a thing is for, in a form a person and a model both read, and it cannot
drift away from the code the way the comment above it can, because it is checked
every time.

And it answers in seconds, by name. `Approval` of `LowRisk` where `Approval` of
`MediumRisk` was required says exactly which thing to change — a review comment
if a person is reading it, and a specification precise enough to act on if
something else is."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHY THIS BEAT EXISTS (MB, 19 Aug)
*I'm not quite sure that the immense value of types as hard constraints, dense
and clear signals of intent and fast feedback loops for iteration for AI agents
is made clear enough towards the end of the talk, where it should land again
forcefully.* It was not. It was sixty words at the tail of `A6-cost`, spoken over
a four-row cost table the room was still reading.

The three claims are MB's own, one paragraph each, in his order: **hard
constraint**, **dense signal of intent**, **fast feedback loop**. Do not merge
them back into one paragraph; the merge is what buried them.

THIS PARTLY UN-MERGES A PART 3 DECISION, DELIBERATELY
Part 3 folded v1's `32-agentic` into the new cost slide *»because they are the
same conversation — the price, and why the price is worth paying now«*. They are
the same conversation and they are still adjacent, but one slide could not hold a
cost table and a three-claim argument without the argument losing. Flagged rather
than done quietly. Cost: +0:35 across Act 6, caps 40:45 → 41:20, spare 4:15 →
3:40. Nothing else was shaved to pay for it.

WHAT EACH CLAIM DOES AND DOES NOT ASSERT (C2)
- **Hard constraint.** True as stated: the checker applies the rule uniformly.
  It does *not* claim the type system catches everything — the escape hatches
  were conceded at `A2-promises` and the ceilings at `A3-ceiling`, `A4-ceiling`.
- **Densest statement of intent.** *Densest* is a superlative, and it is defended
  by the next clause rather than left hanging: what makes it dense is that it is
  checked, so it cannot drift. A comment can say more and guarantee none of it.
  If challenged, that is the answer.
- **Answers in seconds.** True for `javac`; Scala 3 compile times are seconds
  rather than milliseconds and `A6-cost` has just said so out loud, thirty
  seconds earlier. Do not claim milliseconds.
- It does **not** claim a type error beats a test failure in general. It claims
  the error names the type it wanted, which a red assertion does not.

`Approval[LowRisk]` / `Approval[MediumRisk]` is the error the room watched come
out of `scalac` at Demo 3, so it is a memory rather than an example.

FOR Q&A
The proof-assistant tail — Lean, Rocq, Agda, Idris, where the proof obligation is
part of the type and you supply the proof term — is in `28-cost.md`'s
PREPARATION. So is the regulated-industries point.

DELIVERY
Slow. Three claims, a beat between each. This is the practical argument a room of
working developers came for, and it is the last thing before what to do on
Monday.

JOIN
Backwards: `A6-cost` ends on *there is a second reason it is growing* and hands
straight over. Forwards: `A6-monday`.
