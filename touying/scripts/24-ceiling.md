A4-ceiling · cap 1:20 · Act 4 beat 5 of 5 · MERGE of v1 27-stage5-payoff + scala3-ceiling

TALKING POINTS
1. Danielle's bug is a compile error now, and so is the demo's — the medium
   case with an automatic approval inside it. NOT "Bob's open half": Bob closed
   at Stage 3
2. Two things you can still write, and Scala will still take them
3. — the protocol comes off a menu: low+refund, low, medium, high, all in source
4.   the compiler checks each one completely
5.   what it cannot do is build the protocol out of the order in front of it
6.   for that you need a type that depends on a value
7. — nothing makes you finish the channel
8.   finish will not let you hang up early; it wants proof the protocol ended
9.   drop the channel halfway and the compiler has nothing to say
10. Both were on that same list of four
11. One needs a type computed from a value; the other needs the compiler to count

VERBATIM

"Danielle's bug is a compile error now, and so is the one you watched in the
demo — the medium case with an automatic approval inside it.

Two things you can still write here, and Scala will still take them.

The protocol comes off a menu. `ProtocolVariant` lists them — low with a refund,
low without, medium, high — written out in the source, and the risk assessment
picks one while the program runs. Each is checked completely. What the compiler
cannot do is build the protocol out of the order in front of it, and for that you
need a type that depends on a value.

And nothing makes you finish the channel. `finish` will not let you hang up
early — it asks for a proof that the protocol has ended, and mid-way through
there is none to be had. Drop the channel halfway down and walk away, though, and
nothing objects. What is missing is a way to write: this has to
be used exactly once.

Both of those were on that same list of four. One wants a type computed from a
value, the other wants the compiler to count, and there is a language that does
both."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THIS SLIDE IS TWO v1 SLIDES, AND IT DROPS BOTH SCOREBOARDS
`27-stage5-payoff` carried a nine-row `test-list` with a `CLOSES` column *and* a
four-chip `story-strip` — the same furniture P5 removed from every other payoff
slide and Part 2 replaced with Device 1: one declarative claim plus what is now
unwriteable. `scala3-ceiling` was the second half. Merged here, per the plan and
`budget.tsv`.

**No collective view here.** The standing decision is that it happens once, at
the end, on the dark *Unrepresentable* slide, which is the emotional peak and
already works. That is also why this script does not count incidents: `A3-ceiling`
says *two of the four* at the end of Act 3, and Alice's closed silently back at
Stage 1, so any count stated here has to relitigate Act 3's bookkeeping on stage.
Name what closed, do not tally.

NO CUBE REVEAL — SAME DECISION AS `A3-ceiling`
Part 2/Device 2 wants `lambda-cube-canvas(reveal: 2)` here. The diagram is still
unparameterised (`diagrams/lambda-cube.typ:29`), the full cube is in the appendix
for Q&A, and — more to the point — the deck has never named an axis of it out
loud. `A1-above` says *there is a map of this territory, and we fill it in as we
go*, and that is the whole issuance. Talking about a third axis here would be
Part 9/L18 exactly: a metaphor the talk has not issued. v1's script did it twice.

THE TWO LIMITS, CHECKED ONE AT A TIME (C2 — the same discipline as `A3-ceiling`)

1. **The protocol type cannot be computed from a runtime value.** True, and worth
   stating carefully. `ProtocolVariant` (`payment/Derivation.scala:67-79`) is a
   sealed trait with four cases and `fromSnapshot` maps a `RiskSnapshot` onto one
   of them. Each variant is fully checked; what is absent is any way to say *the
   protocol whose shape depends on this value*. Scala 3 does have singleton types
   and `inline`/`scala.compiletime`, so a good deal can be computed from things
   the compiler can already see — a literal, a known type. A value read off a
   queue at runtime is not one of those. The honest form is **the menu has to be
   written out in advance**, and that is what the slide says.

2. **Use-exactly-once is not expressible.** True. `finish()(using ev: P =:= End)`
   (`runtime/Chan.scala:56`) rejects an early close because the evidence cannot be
   summoned mid-protocol. Dropping the channel is not rejected by anything.
   `PaymentDemo.scala:96-102` says so in the source: *Scala 3 lacks linear types …
   Handlers return `Channel[End]` (not `Unit`) to signal intent and centralise
   `finish()` naturally, but must-use-exactly-once is not enforced here.*

WHAT IS **NOT** CLAIMED, AND WAS IN v1
- *Proof that `dual(dual(P)) = P` for all `P`.* True that Scala cannot do it, and
  it is a proof-assistant point, not a payment point. `Dual.scala:20-26` checks
  instances. Q&A material; off the slide.
- *Open-ended protocol vocabulary.* This is limit 1 again, said a second way.
- *Alice's boundary class is done.* v1 said this; Alice's incident closes at
  Stage 1 (`02-incidents.md`: *closes: Stage 1*). Refinements close a different
  thing — the second item on `A3-ceiling`'s list — and that landed on `A4-opens`.

THE DOUBLE-USE GUARD, IF ASKED
Using a channel twice throws `IllegalStateException` at runtime — `Channel`
carries an `AtomicBoolean` (`Chan.scala:19-23`). So of the three failures, Scala
puts *close early* in the type, *use twice* behind a runtime guard, and *drop it*
nowhere at all. Good answer, too long for the slide.

THE CLOSING FRAME
Two limits, and they need two different things: dependent types for the first,
quantities for the second. Idris 2's QTT gives both, which is why Act 5 is one
language and not two. Do not say *QTT* here — `A5-mltt` teaches it.

JOIN
Backwards: `A4-mechanisms`. Forwards: `A5-mltt` opens on the type that depends on
a value, and Demo 4 is the linearity error — `demos/4-linearity.txt`, already
captured: *There are 0 uses of linear name done.*
