A3-ceiling · cap 1:20 · Act 3 beat 8 of 8

TALKING POINTS
1. Charlie's bug is a compile error too. Two of four gone, neither by a test
2. Bob's needed every case; Charlie's needed the right order
3. Three things you can still write, and Java will still take:
4. — approve a medium-risk order the automatic way
5. — build an order with no lines, or a negative quantity
6. — disagree with the other service about the protocol
7. Java CAN encode all three with enough hand-rolled machinery
8. The question from here is what it costs

VERBATIM

"Charlie's bug is a compile error too, so two of the four incidents are gone —
and neither of them went to a test. Bob's needed every case handled; Charlie's
needed the right order.

Here is what you can still write, and Java will still take it. You can approve a
medium-risk order with the automatic method, because the risk level is nowhere in
the authorization's type. You can build an order with no lines in it, or a
negative quantity, because non-empty and at-least-zero live in a constructor
rather than in a type. And you can disagree with the service on the other end of
the wire about what the protocol is, because each side is checked against its own
contract and nothing relates the two.

Now — Java can encode all three of those. With phantom parameters, witness
classes and enough patience, people do. The question from here is not whether it
is possible. It is what it costs, and whether a language that gives it to you
directly is worth the move."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE C2 DISCIPLINE ON THIS SLIDE
*Java cannot express approval indexed by risk* is a Part 8/C2 overclaim and is
one of the four the linter has an `overclaim` rule for. It **can** — phantom
generics and GADT-style witness encodings get you there. The honest limit is the
cost and the ergonomics, not the possibility, and saying it the strong way hands
the sharpest person in the room an easy correction on the act's closing beat.
The last paragraph concedes it explicitly, which is also the setup for `A6-cost`.

CHARLIE'S PAYOFF IS A LINE, NOT A SLIDE
v1's `23-stage4-payoff` carried the nine-row inventory and the four-chip strip
again — the fifth appearance of tracking furniture P5 removed. Deleted; the
collective view happens once, at the end, on the dark *Unrepresentable* slide.

NO CUBE REVEAL — DECIDED, NOT FORGOTTEN
Part 2/Device 2 wants `lambda-cube-canvas(reveal: 1)` here, with two more at
`A4-ceiling` and `A5-payoff`. `diagrams/lambda-cube.typ:29` is still the fixed
canvas value it has always been; parameterising it is an hour of component work
that buys a navigational aid, not an argument. The reveal's job was to name the
two axes Java does not reach, and the three bullets do that in words at no risk.
The full cube slide is in the appendix for Q&A. **If the Wednesday read-through
comes in short, this is the first thing worth adding back.**

FACTS
- Three limits, all real and all closed later: risk-indexed approval →
  `Approval[R <: Risk]`, Stage 5; refinements (`MinLength[1]`,
  `GreaterEqual[0]`) → Stage 5; session types with duality → Stage 5, and the
  runtime-derived protocol → Stage 6.
- Danielle's incident is the third one; naming it here is what makes her close
  in Act 4 a payoff rather than a new topic.

JOIN
Backwards: Demo 2, sixty seconds old. Forwards: Act 4 opens on what can still go
wrong — D-C's option (d), capability-led and motivated by residual failure —
and this slide is the residual failure it is motivated from.
