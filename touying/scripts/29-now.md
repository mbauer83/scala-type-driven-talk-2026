A6-now · cap 1:10 · Act 6 beat 2 of 4

TALKING POINTS
1. A great deal of the code we ship is now written by a model. SAY SO
2. People still review, and read carefully. What changes is volume and speed
3. Ten changes before lunch: attention per line thins, and what scales is what
   needs no attention
4. A type is a HARD CONSTRAINT — every use, every author, every build
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

People still review at least some of the code - and good shops will require human review
of modifications to critical paths. What changes is volume and speed: when ten changes land 
before lunch, attention per line thins, and to support our efforts, the only approach that 
actually scales is one that requires no attention at all.

A type is a hard constraint. It holds at every use, from every author, on every
build, and it does not care whether a person or a model wrote it. A test only
ever covers the case somebody thought of.

It is also the clearest statement of intent you can hand a model. A type
signature says what a thing is for in a form it can read, and it cannot drift, because it
is checked every time.

And - the feedback loop is very short and inexpensive. `Approval` of `LowRisk`
where `Approval` of `MediumRisk` was required says exactly what to change, 
and is available as feedback before the code is ever run;"

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

NAME IT: "AGENTIC SOFTWARE DEVELOPMENT"
That is the term to use — not "LLM-driven", which the review corrected.
An earlier version of this beat never named it at all —
it said *whoever wrote the line*, *whatever generated the patch*, *a person and a
model both read*. the speaker: *why do you dance around the issue … I really don't
understand why you did that.* Fair. This is the one slide in the deck whose
entire purpose is that argument, and hedging on it is worse than leaving it out.
Name it in the first sentence.

Also corrected: *code arrives faster than anyone can read it* implied nobody
reviews, which is both untrue and insulting to a room of working developers. The
true claim is the speaker's own — **volume and iteration speed** are what change, so hard
constraints, fast feedback and clear signals are worth more than a suite of
tests. Concede the review explicitly before making it.

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
