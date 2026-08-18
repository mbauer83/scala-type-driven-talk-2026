A2-scenario · cap 0:40 · Act 2 beat 1 of 2

TALKING POINTS
1. The floor: Alice's service had no types — 12 plus 34 as strings gives 1234
2. That is where we start
3. The flow, once: order → assess → authorize → capture (→ refund or invoice)
4. What encoding a rule buys, four things:
5. — applied at every use, by the compiler, not every call you remembered
6. — the failure moves to compile time
7. — the signal is clear and small, and arrives where the rule is defined
8. — the defensive tests go; the behavioural ones stay
9. Hand off: so what is the compiler actually promising when it says yes?

VERBATIM

"Alice's service had no types at all: twelve plus thirty-four, as strings, is
twelve-thirty-four, and nothing anywhere complains. That is where we start.

One flow carries the rest of the talk, and you have seen it already. What changes
at each stage is how much of it the compiler enforces — and each time we move a
rule into a type we get the same four things back: it holds at every use, the
failure moves to compile time, the signal is small and arrives at the
definition, and the defensive tests go.

So before any of that: what is the compiler actually promising when it says yes?"

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHAT WAS HERE BEFORE, AND WHY IT WENT (MB, 18 Aug)
Untouched v1: headline *Demo Scenario & Potential Bugs*, a nine-row inventory
with a `CLOSES` column, and a note that re-explained the payment flow. Three
faults, all of them already written down in this plan and none of them executed:

- **The scenario is not new.** The room met the flow on slide 2 and the four
  incidents are named after it. Explaining it again spends the slide's whole
  budget on something already paid for.
- **The `CLOSES` column gives away every payoff** before its suspense exists.
  That is P5, verbatim, from the original diagnosis of v1.
- **Part 2 sent that table to the appendix** and it never moved. It is now
  `a10-invariants`, which is where it is actually useful: a Q&A artefact for
  anyone who asks for the complete set.

THE UNTYPED FLOOR — why this slide has to carry it
Stage 0 was cut with the note *one line on A2-scenario*, and the line was never
written. MB, 18 Aug: by the Stage 1 slide the contrast to Alice's untyped service
is gone, so *simple types* lands against nothing. One line here restores it, and
it is Alice's own bug, so it costs no setup.

THE FOUR THINGS — MB's framing, 18 Aug
*Encode invariants, and thus prevent bugs and reduce tests, for better
guarantees, stronger signals and shorter, more efficient and effective feedback
loops.* Mapped onto the slide: **every use** is the guarantee, **compile time**
is the feedback loop, **a line and a type** is the signal, **defensive tests go**
is the test reduction. The distinction that keeps this honest is the last one —
defensive tests shrink, behavioural tests do not, and saying otherwise is the
overclaim C2 exists for.

FACTS
- `»12« + »34« === »1234«` in JavaScript. Alice's incident, `02-incidents.md`.
- The flow diagram is unchanged v1 cetz and is the same shape as the strip on
  `A0-incidents`.
