A4-sessions · cap 1:30 · Act 4 beat 3 of 5

TALKING POINTS
1. The four things a type can do, from the end of the history — here is the first
2. LowRiskProtocol: send order, receive snapshot, receive auth, receive capture,
   then choose
3. The channel is typed by what is left to do; every send hands back a smaller
   protocol; nothing left is End
4. Dual is a match — scrutinee is a type, result is a type, runs in the compiler
5. Send turns into receive, choose into offer, recursing into the remainder
6. Client holds Channel of P, server holds Channel of Dual of P — one definition
7. Danielle's two services were each correct against their own contract
8. There was no third thing for them to be correct against. This is it
9. A server that sends where it should receive does not compile

VERBATIM

"At the end of the history I showed you four things a type can do, and said you
would watch every one of them run. Here is the first — a conversation between two
services, written down as one type.

`LowRiskProtocol` is the whole exchange, in order: send an order, receive the
risk snapshot, the authorization, the capture, then choose between a refund and
finishing. The channel you are holding is typed by what is left to do — so every
step hands back a smaller protocol, and when nothing is left the type is `End`.
That is the protocol as a type.

Now the part Java has no version of. `Dual` is a `match` — Scala's switch — except
that it matches on a type, returns a type, and runs inside the compiler: send
turns into receive, choose into offer, and it recurses into the remainder of the
protocol, so the whole conversation comes back turned around. The client holds a
channel of `P` and the server one of `Dual` of `P`, both out of that one
definition.

Danielle's two services were each correct against their own contract, with
nothing else to be correct against. This is that missing thing —
and a server that sends where it should receive does not compile, so the drift
she found three weeks in has nowhere left to happen."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE CALLBACK IS EXACT, AND IT IS THE REASON THIS SLIDE OPENS THAT WAY
`A1-above` closes on four things the room is promised it will see running: *a
type indexed by a runtime value; a value paired with a proof about that value; an
instruction that tells the compiler to verify that a resource is used exactly
once; and a conversation between two services written down as one type.* This is
the fourth, and it is the first of the four to be paid off. The other three land
in Act 5, and `A4-ceiling` says which two of them Scala cannot reach.

Reference the SLIDE, never the clock. MB, 18 Aug: *nobody references an earlier
place in a talk like that.* Correct — »at minute nine« is a stage direction read
out loud. Name what was on the slide instead; the room remembers the four rows,
and it can place them without being told the time.

FACTS — grepped against `05-scala3-payment/src/main/scala/` (C1, rule 9)
- `type Dual[P <: Protocol] <: Protocol = P match` with the five cases —
  `protocol/Dual.scala:7-12`. On the slide verbatim, all five arms.
- `LowRiskProtocol` — `payment/Derivation.scala:38-43`. Verbatim.
- `sealed trait Protocol`, `End`, `Send[A, Next]`, `Receive[A, Next]`,
  `Choose[L, R]`, `Offer[L, R]` — `protocol/Proto.scala:7-15`.
- `def send(using s: CanSend[P])(value: s.Msg): Channel[s.Rest]` —
  `runtime/Chan.scala:25`. This is the *channel typed by what is left to do*:
  `s.Rest` is the continuation, extracted by the evidence.
- `summon[Dual[LowRiskProtocol] =:= Receive[Order, Send[RiskSnapshot, …]]]` —
  `payment/Derivation.scala:86`, in `private object DualityChecks` (`:83`). Three of
  them, one per protocol.

THE SUMMON BLOCK IS ON THE SLIDE AND NOT IN THE SCRIPT
`summon[… =:= …]` is a test with no test runner: it compiles or the build fails.
That is a good forty-second beat and there is no forty seconds here — this slide
already carries the callback, the protocol, the match type and Danielle. It is on
the wall for anyone reading ahead, it is the honest answer to »how do you know
`Dual` is right«, and Q&A is where it gets explained. Do not start it on stage.

WHY »JAVA HAS NO VERSION OF« RATHER THAN A STRONGER CLAIM
`A3-ceiling` conceded the first two of its three limits and drew the line at this
one: *deriving the other side's protocol needs types computed from types, and
Java has no such thing.* That concession is what makes this claim land, so the
phrasing here matches it and does not escalate. Java's generics have no
type-level computation at all: no matching on a type, no recursion over one.
Wildcards are existentials, not a `match`.

WHAT »MATCH TYPE« IS, IF ASKED
A match type is evaluated by the compiler by reducing the scrutinee against the
patterns, exactly like a term-level match, and it is recursive. It is Scala 3's
type-level computation; the same axis Java is missing. The reduction is not
guaranteed to terminate, which is why the compiler has a recursion depth limit —
worth knowing, not worth saying.

THE DUALITY PROOFS IN `Dual.scala` ARE A SECOND ANSWER
`Dual.scala:20-26` has a `private object DualityProofs` with six one-line checks,
including `summon[Dual[Dual[Send[Int, End]]] =:= Send[Int, End]]`. Those are
instances, not the general involution — Scala cannot prove `Dual[Dual[P]] = P`
for every `P`. Do not claim it does. It is a good Q&A answer and it is the honest
shape of the difference between a type checker and a proof assistant.

JOIN
Backwards: Demo 3, ninety seconds old. Forwards: `A4-mechanisms` names what has
been running and then moves the same idea onto capabilities.
