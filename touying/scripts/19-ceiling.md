A3-ceiling · cap 1:20 · Act 3 beat 8 of 8

TALKING POINTS
1. Charlie's bug is a compile error too. Two of four gone, neither by a test
2. Three things you can still write, and each has a different answer:
3. — wrong approval method: Java CAN fix this. Another phantom parameter, noise
4. — no lines, negative quantity: a smart constructor gets the same guarantee
5.   but not on a literal, and two such predicates will not combine
6. — protocol disagreement: this one Java CANNOT reach
7.   deriving the other side needs types computed from types
8. That is Danielle's bug, and it is a real ceiling rather than a rhetorical one
9. The question is never whether to change language
10. It is which of these you already pay for, and what each costs to encode

VERBATIM

"Charlie's bug is a compile error too, so two of the four are gone — and neither
of them went to a test.

Here is what you can still write. You can approve a medium-risk order with the
automatic method, because the risk level is nowhere in the authorization's type.
Java can fix that one, properly: another phantom parameter and factory methods
that only produce the matching approval. It works, and it is noisy.

You can build an order with no lines in it, or a negative quantity. A smart
constructor gets you most of the way — make the type unconstructible without the
check and everything downstream is safe. What you cannot do is have the compiler
decide that on a literal, or combine two of those constraints.

And you can disagree with the service on the other end of the wire about what the
protocol is. That one Java cannot reach. Working out the other side's protocol
from yours means computing types from types, and Java has no such thing. You can
write both sides by hand, and nothing checks that they correspond — which is
precisely what happened to Danielle.

So the question from here is not whether to change language. Nobody does that for
types. It is which of these three you are already paying for, and what each one
costs you to encode where you are."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHAT JAVA CAN AND CANNOT ACTUALLY REACH (MB, 18 Aug — checked, one by one)
An earlier version said *Java can encode all three with enough hand-rolled
machinery*. That avoided the C2 overclaim in one direction and committed one in
the other. Per item:

1. **Risk-indexed approval — Java can do this properly.** Another phantom
   parameter, `Approval<R extends Risk>`, and factory methods that only produce
   the matching one. Same safety, more noise.
2. **Refinements — partly.** A smart constructor returning
   `Optional<NonEmptyList<T>>` gives the *same downstream guarantee*: the type is
   only constructible through the check. What Java cannot do is decide the
   predicate on a literal at compile time, or compose two refinements the way
   `MinLength[1] & MaxLength[10]` does.
3. **Protocol duality — no.** `Dual[P]` in `protocol/Dual.scala:7` is a **match
   type**: the compiler computes the other side's protocol from yours. Java has
   no type-level computation, so you can hand-write both sides and nothing
   relates them — which is exactly Danielle's incident. **This is a real
   ceiling**, and the only one of the three that is.

Say it that way. A room that contains one person who has built a phantom-typed
state machine in Java will believe the third claim precisely because you conceded
the first two.

THE CLOSING FRAME (MB, 18 Aug)
*Whether a language that gives it to you directly is worth the move* was the
wrong question: nobody changes language for better types, and framing it that way
invites the room to dismiss the rest of the talk as impractical. The question
they actually face is **which of these you are already paying for, and what each
one costs to encode where you are.** That is also the question `A6-cost` answers,
so this line is its setup.

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
