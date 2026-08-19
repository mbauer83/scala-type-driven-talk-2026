A4-opens · cap 1:20 · Act 4 beat 1 of 6

TALKING POINTS
1. So we leave Java. Same flow, same incidents, and this is Scala 3
1b. Two of those three cost about a line each
2. Each risk level is a type of its own now
3. AutoApproved is an Approval of LowRisk
4. The only way to an Approval of MediumRisk is handing over the 3DS proof
5. authorize takes an Approval at level R, gives back a payment at the same R
6. The level travels with the payment
7. NonEmptyLines — the predicate MinLength[1], written into the type
8. The payoff is the line underneath: firstLine calls head, and it is total
9. Java gets most of that from a smart constructor
10. What it could not do — the rule on a literal, or two rules combined

VERBATIM

"So we leave Java. Same payment flow, same four incidents, and this is Scala 3,
where two of those three cost about a line each.

Each risk level is a type of its own now, and an approval is evidence for one
particular level.
`AutoApproved` is an `Approval` of `LowRisk`, and the only way to an `Approval`
of `MediumRisk` is handing over a three-D-Secure proof — the only constructor
there is. `authorize` takes an approval at level `R` and gives back an authorized
payment at the same `R`, so the level travels with the payment for the rest of
its life.

The second one is the predicate. `NonEmptyLines` is a list of order lines with
`MinLength` of one in the type, and the payoff is the line underneath:
`firstLine` calls `head`, and it is total. No `Optional`, no defensive branch,
nothing to explain — the emptiness was excluded once, at the boundary.

A smart constructor in Java gets most of that. What it cannot do is decide
the rule on a literal the compiler can already read, or combine two rules into
one type."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE LANGUAGE CHANGE IS ANNOUNCED HERE, IN THE FIRST CLAUSE (MB, 18 Aug)
MB: *nothing in notes or on the slide makes it prominent that we're now moving
to Scala.* True, and it was worse than that — the word **Scala** was not spoken
anywhere at the boundary. `A3-ceiling` hands over with *what comes next is a
language where all three of these are cheap*, which names no language, and this
script opened on *two of those three cost about a line each*, which names none
either.

Two dark stage-opener slides were built for this and then cut again. The
reasoning is worth keeping, because v1 had one of those for every stage 0-6 and
somebody will propose bringing them back:

1. **Rendered, the v1 template does not carry 0:12 of speech.** Two-thirds of
   the slide is empty and its dominant element is a 320px numeral — the room does
   not need to be told it is Stage 5, it needs to be told it is Scala.
2. **It weakens the demo card.** `a4-demo3` is two slides later and its whole
   job is *stop reading, look at the IDE* (`a3-demo1.typ` says so in its own
   comment). A second dark card at the same distance, doing a different job,
   dilutes the one that has to work.
3. **It costs 0:30 of the margin** that exists to absorb nerves and questions,
   to deliver a framing sentence that fits in a subordinate clause.

What the boundary actually needed was the language **named**, out loud and on
the wall. It is now the first clause here, and the eyebrow is a filled chip
instead of grey mono. No slide, no seconds.

THE JOIN, AND WHY THIS SLIDE OPENS ON A LIST IT DID NOT WRITE
`A3-ceiling` ends on three things Java still accepts, with a different verdict
on each: risk-indexed approval Java can do properly but noisily; refinements it
gets downstream but not on a literal and not composed; protocol duality it cannot
reach. That is D-C option (d) — capability-led, motivated by residual failure —
and this act answers the three in that order. Beat 1 takes the first two, the
demo fires the first, and `A4-sessions` takes the third.

Do not re-state the three. The room heard them ninety seconds ago and the whole
value of the join is that it costs one clause.

FACTS — grepped against `05-scala3-payment/src/main/scala/` (C1, rule 9)
- `sealed trait Risk` / `LowRisk` / `MediumRisk` / `HighRisk` — `payment/Domain.scala:62-65`.
  Three levels; `Risk` itself is the bound.
- `sealed trait Approval[+R <: Risk]` — `Domain.scala:76`.
- `case object AutoApproved extends Approval[LowRisk]` — `Domain.scala:82`.
- `final case class ThreeDSApproved(proof: ThreeDSProof) extends Approval[MediumRisk]`
  — `Domain.scala:85`.
- `def authorize[R <: Risk](order: Order, approval: Approval[R]): AuthorizedPayment[R]`
  — `Domain.scala:285`.
- `type NonEmptyLines = List[OrderLine] :| MinLength[1]` — `Domain.scala:211`.
- `def firstLine: OrderLine = lines.head` with the comment *»Total, because `lines`
  cannot be empty. No Option, no exception.«* — `Domain.scala:221-222`. The comment is
  the argument; the slide shows the code and says it out loud.
- `type NonNegativeInt = Int :| GreaterEqual[0]` — `Domain.scala:187`. On the slide
  as the second predicate because `A3-ceiling` named negative quantities.

THE COVARIANCE IS NOT SAID OUT LOUD
`Approval[+R <: Risk]` is covariant, and `Domain.scala:77-80` is explicit that the
variance is sound but not load-bearing: the safety comes from `authorize[R]`
inferring `R` from the argument. Saying `+R` on stage buys a question and no
argument. The `+` is on the slide because it is in the file; if asked, that
comment is the answer.

COMPOSITION IS SPOKEN, NOT SHOWN
`MinLength[1] & MaxLength[10]` is real in Iron and is the thing Java cannot do,
but it appears nowhere in this repository. Part 12/R9: do not put an invented
identifier in a pane with a filename on it. It stays a clause in speech.

WHAT WAS ON THE v1 SLIDE, AND WHY IT IS GONE
v1 showed the body of `authorize` — a match over the three approval constructors
building an audit string — with `order.id`, `p.id`, `a.id` and `audit =`. None of
those identifiers exist: the real fields are `order.orderId.orderIdStr`,
`p.challengeId`, `a.reviewer` and `auditTrail`. It also demonstrated nothing: the
match is bookkeeping, and the signature above it is the entire point. Replaced by
the signature plus the two constructors, which is what makes the demo's error
legible sixty seconds later.

JOIN
Forwards: Demo 3 swaps `ThreeDSApproved(proof)` for `AutoApproved` and lets
`scalac` say what `Approval[R]` is for. Do not describe the error here.
