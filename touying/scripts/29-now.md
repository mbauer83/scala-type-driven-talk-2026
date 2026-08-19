A6-now · cap 1:10 · Act 6 beat 2 of 4 · NEW · partly un-merges v1 32-agentic

TALKING POINTS
1. A great deal of the code we ship is now written by a model. SAY SO
2. People still review, and read carefully. What changes is volume and speed
3. Ten changes before lunch: attention per line thins, and what scales is what
   needs no attention
4. A type is a HARD CONSTRAINT — every line, every author, every build
5. A test only covers the case somebody thought of
6. Clearest statement of intent you can hand a model — and it cannot drift,
   because it is checked
7. The loop is seconds long and answers BY NAME
8. Approval of LowRisk where MediumRisk was required says what to change;
   a red test says only that something is wrong
9. Deliver this slowly. It is the practical argument the room came for

VERBATIM

"And the arithmetic behind all of this has changed, because a great deal of the
code we ship is now written by a model.

People still review, and they read carefully. What changes is volume and speed:
when ten changes land before lunch, attention per line thins, and what scales is
the part that needs no attention at all.

A type is a hard constraint. It holds on every line, from every author, on every
build, and it does not care whether a person or a model wrote it. A test only
ever covers the case somebody thought of.

It is also the clearest statement of intent you can hand a model. A signature
says what a thing is for in a form it can read, and it cannot drift, because it
is checked every time.

And the loop is seconds long and it answers by name. `Approval` of `LowRisk`
where `Approval` of `MediumRisk` was required says exactly what to change; a red
test says only that something is wrong."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

NAME IT: "AGENTIC SOFTWARE DEVELOPMENT" (MB, 19 Aug)
That is the term to use — not "LLM-driven", which MB corrected on 19 Aug.
An earlier version of this beat never named it at all —
it said *whoever wrote the line*, *whatever generated the patch*, *a person and a
model both read*. MB: *why do you dance around the issue … I really don't
understand why you did that.* Fair. This is the one slide in the deck whose
entire purpose is that argument, and hedging on it is worse than leaving it out.
Name it in the first sentence.

Also corrected: *code arrives faster than anyone can read it* implied nobody
reviews, which is both untrue and insulting to a room of working developers. The
true claim is MB's own — **volume and iteration speed** are what change, so hard
constraints, fast feedback and clear signals are worth more than a suite of
tests. Concede the review explicitly before making it.

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
