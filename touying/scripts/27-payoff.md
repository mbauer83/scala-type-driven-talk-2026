A5-payoff · cap 0:50 · Act 5 beat 3 of 3 · KEEP v1 30-stage6-payoff

TALKING POINTS
1. Alice's boundary, Bob's branch, Charlie's lifecycle, Danielle's protocol
2. Every one of them is now a program that cannot be written down
3. A different kind of guarantee from a test that catches it
4. No test to write, no review to remember, no runtime check to skip
5. The shape of the type leaves nowhere to put the mistake
6. And the compiler required it every time — which is where we started
7. Let it sit. Do not fill the pause

VERBATIM

"Alice's boundary, Bob's branch, Charlie's lifecycle, Danielle's protocol — every
one of those four is now a program that cannot be written down.

That is a different kind of guarantee from a test that happens to catch it. There
is no test to write, nothing to remember in review, and no runtime check anybody
can skip, because the shape of the type leaves nowhere to put the mistake.

And every time, it was the compiler that required the proof — which is where this
evening started."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE SLIDE IS UNCHANGED AND SHOULD STAY UNCHANGED
Part 3: **KEEP**. It is the dark culmination slide, the four chips are on it, and
it is the emotional peak of the talk. It is also the deck's **only** collective
view of the four incidents — every payoff slide had a scoreboard in v1 and P5
removed all of them so this one would land.

DELIVERY — this is the slowest thing in the talk
Four names, one per breath — they are one sentence on the page so the linter does
not read them as cadence, and that changes nothing about how they are said. Pause
before the second paragraph. The words
are few on purpose. Do not gloss the chips, do not read the slide, and do not
start `A6-cost` until the room has stopped looking at it.

WHAT CHANGED IN THE SCRIPT, AND WHY
v1 ended: *The compiler required the proof. Gentzen required it. Curry-Howard
required it.* Three short sentences with the same shape — the linter's `tricolon`
rule, and it was the only ERROR in Act 5. The names also do not survive contact:
Gentzen did not require anything about this program, and invoking him at the
emotional peak asks the room to do bookkeeping at the moment it should be feeling
something.

*Which is where this evening started* keeps the callback and drops the roll-call.
`A6-close` then says the thesis in full, three slides later.

The other v1 phrase that is gone: *a much stronger guarantee than a test*.
**Different kind**, not stronger — a test that catches the bug catches it, and
the argument the talk has actually made all evening is that there is nothing left
to catch. C2, in its smallest form.

FOUR NAMES, FOUR STAGES — the bookkeeping, if anybody asks
- Alice: the boundary, Stage 1 (`02-incidents.md`: *closes: Stage 1* — `int`
  instead of `String`), reinforced by refinements at Stage 5.
- Bob: the missing branch, Stage 3 (sealed + exhaustive switch), and the wrong
  approval method for the tier, Stage 5 (`Approval[R]`).
- Charlie: the lifecycle, Stage 4 (phantom typestate).
- Danielle: the protocol, Stage 5 (session types and duality).
That is the whole ladder, and it is why no slide before this one runs a tally.

JOIN
Backwards: Demo 5's error, still on the screen behind you. Forwards: `A6-cost`,
which is a change of register — practical, brisk, and deliberately unemotional
after this.
