A6-close · cap 0:50 · Act 6 beat 3 of 3 · REWORK of v1 34-close

TALKING POINTS
1. At the start: a program that type-checks is, in a precise sense, a proof
2. And you have been writing them all along
3. Every stage tonight was one move, repeated
4. Something that was only promised — a comment, a test, somebody's head —
   became something the type states
5. That is what the four incidents had in common
6. Each was a rule the business needed, with nowhere in the language to put it
7. Put it where the compiler looks, and it stops being a program you can write
8. Thank you

VERBATIM

"I said at the start that a program which type-checks is, in a precise sense, a
proof — and that you have been writing them all along.

Every stage tonight was the same move, repeated. Something that was only
promised, in a comment or a test or somebody's head, became something the type
states, and the compiler went and checked it.

That is what the four incidents had in common. Each of them was a rule the
business needed, and the language had nowhere to put it. Put it somewhere the
compiler looks, and it stops being a program anybody can write — yourself
included.

Thank you."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHAT THIS SLIDE IS FOR, AND WHAT IT MUST NOT DO
It closes the loop opened by `A0-title`, and nothing else. The exact promise, in
MB's own words: *By the end I think you'll see that writing a program that
type-checks is, in a precise sense, the same thing as constructing a proof in
formal logic — and that you've been doing it all along.* The first sentence here
is that sentence, returned.

It must **not** re-tell the four incidents. `A5-payoff` is the dark
*Unrepresentable* slide with the four chips on it, three slides earlier, and it
is the emotional peak of the talk. Part 3 cut `31-the-climb` precisely so the
last four minutes carry two summaries and not three. v1's script opened with a
sentence per incident — Alice, Bob, Charlie, Danielle — which is the third
telling of the same four stories in under five minutes.

WHAT WAS ON v1 AND WHERE IT WENT
- **Four incidents restated.** Deleted. `A5-payoff` does it.
- **The zero-runtime-overhead footnote** (~110 words, at the very end). Moved to
  `A6-cost`, where it is a cost fact and belongs. Ending a talk on a footnote
  about erasure is ending on a technicality.
- **Regulated industries** — avionics, medical devices, finance. Q&A note on
  `A6-cost`. It is an unverifiable anecdote and it was doing the cost slide's
  job from the close.
- **The question isn't 'should I use dependent types for my CRUD endpoints'.**
  `A6-cost` has the positive version, one slide before this one. Saying it here
  as well would be its third appearance in the deck.
- **Some bugs aren't »just part of engineering life«.** R1 — define positively,
  never by exclusion — and the scare quotes make it worse. What replaces it says
  the same thing forwards: *each of them was a rule the business needed, and the
  language had nowhere to put it.*

THE THROUGH-LINE IS MB'S OWN, FROM PART 14/L26
*Each stage takes something the code only promises and makes the type state it.*
That was checked against all six stages and it holds for all six, which is why it
is the sentence the talk ends on. The earlier candidate — *every stage deletes
one of null, throws, never* — is false for four of the six and is in
`retired.tsv`.

C13 ON THE SECOND SENTENCE
*Became something the type states, and the compiler went and checked it* keeps
the three things apart: the program is the construction, the type is the claim,
the compiler is what verifies one against the other. Do not compress it to *the
compiler knows* — that merges type and checker, which is the exact fault F-10
found on `A1-curry-howard`.

DELIVERY
Short, and it should feel short. Land the first sentence, pause, then the middle
paragraph at an even pace. *Yourself included* is the last thing before thank-you
and it is the L2 move — the speaker inside the set, which is where this talk has
stood since `A0-incidents`. Do not rush it and do not add anything after it.

JOIN
Backwards: `A6-monday`, which is practical and slightly brisk; this one slows
down. Forwards: the Q&A card, `36-qa`.
