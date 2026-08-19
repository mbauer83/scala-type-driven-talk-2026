A2-scenario · cap 0:40 · Act 2 beat 1 of 2

TALKING POINTS
1. The floor: Alice's service had no types — 12 plus 34 as strings gives 1234
2. That is where we start
3. The flow, once: order → assess → authorize → capture (→ refund or invoice)
4. What encoding a rule in the type system buys, four things:
5. — applied at every use, by the compiler, not every call you remembered
6. — the failure moves to compile time
7. — the signal is clear and small, and arrives where the rule is defined
8. — the defensive tests go; the behavioural ones stay
9. Hand off: so what is the compiler actually promising when it says yes?

VERBATIM

"Alice's service had no types at all: twelve plus thirty-four, as strings, is
twelve-thirty-four, and nothing anywhere complains. That is where we start.

Our payment-flow still carries the rest of the talk. What changes at each stage 
is how much of it the compiler enforces — and each time we move a
rule into a type, we get the same four things back: it holds at every use, the
failure moves to compile time, the signal of intent is precise, brief and located 
at the site of definition - and the defensive tests go.

So before any of that: what is the compiler actually promising when it says yes?"

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE UNTYPED FLOOR — why this slide has to carry it
Stage 0 was cut with the note *one line on A2-scenario*, and the line was never
written. by the Stage 1 slide the contrast to Alice's untyped service
is gone, so *simple types* lands against nothing. One line here restores it, and
it is Alice's own bug, so it costs no setup.

THE FOUR THINGS — the framing
*Encode invariants, and thus prevent bugs and reduce tests, for better
guarantees, stronger signals and shorter, more efficient and effective feedback
loops.* Mapped onto the slide: **every use** is the guarantee, **compile time**
is the feedback loop, **a line and a type** is the signal, **defensive tests go**
is the test reduction. The distinction that keeps this honest is the last one —
defensive tests shrink, behavioural tests do not, and saying otherwise is the
overclaim C2 exists for.

FACTS
- `»12« + »34« === »1234«` in JavaScript. Alice's incident, `02-incidents.md`.
- The flow diagram is unchanged cetz and is the same shape as the strip on
  `A0-incidents`.
