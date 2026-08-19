A4-sessions · cap 1:30 · Act 4 beat 3 of 6

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
9. Hand off into Demo 4 — watch what happens when one side forgets whose turn
   it is. Do NOT close the point here; the demo closes it

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
nothing else to be correct against. This is that missing thing. So watch what
happens when one side forgets whose turn it is."

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

Reference the SLIDE, never the clock: *nobody references an earlier
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

IS THE SCALA SESSION TYPE A PHANTOM TYPE? YES (Q&A
Textbook case. `final class Channel[P <: Protocol]` has exactly three fields —
`outbox`, `inbox`, `label` — and **none of them mentions `P`**
(`runtime/Chan.scala:14-17`). `Proto.scala` says so in its own header comment:
*no values live here; types carry all the information*. `Send`, `Receive`,
`Choose` and `Offer` are `final class`es that are never instantiated
(`protocol/Proto.scala:12-15`). So `P` is erased, and every protocol step is
literally `new Channel[s.Rest](outbox, inbox, label)` — the same two queues,
re-wrapped with a different phantom parameter.

It is the same *mechanism* as Stage 4's `Payment<Initiated>`, one level up in
structure: Charlie's markers are atoms, and this phantom parameter is a whole
tree that `Dual` and `CanSend` compute over. Worth saying if it comes up — it
makes Stage 4 the thing the room already understood.

**And do not answer that Idris's version is the un-phantom one.** It is not.
`MkSession : Channel Blob -> Channel Blob -> Session p`
(`PaymentChannel.idr:66-67`) has two fields, neither mentioning `p`, and
`openSession _ = …` ignores its `p` argument outright
(`PaymentChannel.idr:73-78`).

Underneath, both are the same thing: **a protocol that exists only at compile
time, sitting on top of a pipe that carries no type information at all.**

  Scala   two `BlockingQueue[Any]`, and `receive` ends in
          `inbox.take().asInstanceOf[r.Msg]`  (`runtime/Chan.scala:15-16, 33`)
  Idris   two `Channel Blob`, where `Blob` is a one-constructor type and
          `packBlob = believe_me`, `unpackBlob = believe_me`
          (`PaymentChannel.idr:54-61`)

`believe_me` and `asInstanceOf` are the same move: assert a type the compiler
cannot check. So in both languages the protocol lives entirely in the parameter,
and the parameter is gone before a single message moves.

HOW MUCH OF THAT IS THE DEMO, AND HOW MUCH IS THE TECHNIQUE
Mostly the demo, and the distinction is worth having straight before answering.

**The unchecked cast is a shortcut.** `asInstanceOf` and `believe_me` are there
because these are two hundred lines meant to be read on a projector. A real
implementation replaces each with a decode that can fail, chosen by the same
evidence that produced `s.Msg` — so the narrowing becomes a checked operation
with a failure branch, not an assertion. In Idris you can go further and push the
index into the channel type itself, and drop `believe_me` from the in-memory
case entirely.

**A dynamically-typed carrier underneath is not a shortcut**, as long as the
transport is one object: the message type changes at every protocol step, so
whatever holds the messages is heterogeneous by construction. What a real
implementation changes is the honesty of the boundary — a sum type you pattern
match on, or bytes you decode — not the existence of one.

**And across a real process boundary it is unavoidable.** Bytes arrive from a
socket and something has to check them. Session types do not remove that check;
they tell you *which* decoder belongs at each step, and they guarantee your own
program's order of operations. That is the same shape Stage 5 already sold for
Iron: one real check at the edge, and no checks at all inside. It is also why
Scribble generates runtime monitors alongside its endpoint APIs — see
`a11-production`.

So the claim that survives is narrower than the code suggests, and it is still
the interesting one: **the protocol parameter is erased, and the wire is not
self-describing.** That is about the type parameter, not about the cast, and it
holds however carefully the transport is written.

**Why that matters, and it is the honest bound on the whole claim.** A session
type guarantees that *the program you compiled* uses its end of the channel in
the right order with the right message types. It does not make the wire
self-describing and it checks nothing at runtime. Hand the queue to something
compiled against a different protocol, or write to it from elsewhere, and
nothing catches it — the same way a phantom type does not stop reflection
building a `Payment<Authorized>` that was never authorized. This is also the
answer to *how does this meet a real socket*: identically. The protocol sits
above serialization, and the unchecked cast at the boundary is where a real
decoder would go.

So the difference between the two acts is **not** runtime presence. It is
**which language the index is written in, and who computes it**: in Scala a
type, assembled by type-level machinery out of what compile time already knows;
in Idris a value of an ordinary data type, produced by an ordinary function at
runtime — `protocolFromSnapshot snapshot n c` — and then appearing in a type.
That is the thing Scala cannot do, and it is exactly what `A5-mltt` shows.

HOW SESSION TYPES MEET REAL CHANNELS, IN PRACTICE (Q&A
The honest headline: **a session type is a contract, not a wire format.** It
constrains which operations your program can compile; something else still has
to move bytes. In practice there are three routes, and only the second is what
anybody deploys.

1. **Embedded in the host language**, which is what this repository does — the
   protocol lives in the type system and the channel is a typed wrapper over an
   untyped transport. Cheap, and it only protects code you compile yourself.

2. **Generated from a protocol description.** This is the practical route, and
   Scribble is the reference toolchain. You write ONE global protocol describing
   the whole conversation between all parties; the tool **projects** it to a
   local type per role, and generates an endpoint API for each — usually a
   typestate API, where each protocol state is a type exposing only the legal
   next operations, plus the codec. Because the API and the serialisation come
   out of the same description, the cast at the boundary is justified rather
   than assumed. Implementations exist for Java, Scala, F#, Go and TypeScript;
   StMungo generates Java typestate from Scribble, and nuScr is the current
   front end. This is the answer to "how would I use it at work".

3. **Runtime monitoring.** Generate a monitor from the same protocol and put it
   at the endpoint, checking the message sequence as it happens. Used when you
   cannot control what language the other end is written in — the guarantee
   drops from "cannot compile" to "fails loudly at the boundary", which is still
   far better than Danielle's three weeks.

**Multiparty session types** are what make any of this usable beyond two
parties: one global type, projected to N local ones. Two-party session types of
the kind in this deck are the special case.

**Where the room already meets the idea.** gRPC and protobuf give message
schemas and, in streaming RPC, a channel — but nothing types the *order* of
messages, which is the part session types add. OpenAPI/AsyncAPI describe shapes,
not sequences. And a typestate API — `Payment<Authorized>`, or any builder that
will not let you call `build()` early — is the single-party cousin of the same
idea, which is exactly the Stage 4 to Stage 5 move in this talk.

**The honest limits.** Classical session types assume a reliable, ordered,
non-failing channel. Timeouts, retries, crashes and partitions are where it gets
hard: there is real work on affine and exception-handling session types, but a
process that dies mid-protocol breaks the "used exactly once" story, and that is
a research frontier rather than something to promise a room.

AND IN THIS REPOSITORY SPECIFICALLY
It does not. The type is erased, and underneath are two ordinary untyped queues.

    final class Transport:
      private[runtime] val aToB = new LinkedBlockingQueue[Any](128)
      private[runtime] val bToA = new LinkedBlockingQueue[Any](128)
    def open[P <: Protocol]: (Channel[P], Channel[Dual[P]]) =
      client = new Channel[P](outbox = aToB, inbox = bToA)
      server = new Channel[Dual[P]](outbox = bToA, inbox = aToB)   -- crossed

`runtime/Transport.scala:9-18`. `P` is a phantom parameter carrying no data;
`send` is `outbox.put(value)` and `receive` is
`inbox.take().asInstanceOf[r.Msg]` (`runtime/Chan.scala:25-35`) — **an unchecked
cast**. So the guarantee is static and local: the types constrain which
operations *your program* can compile, and duality guarantees the two endpoints
were derived from one description. Nothing checks the bytes.

Why that is still worth having: the cast can only be wrong if the two sides were
built from different versions of the protocol, or something outside both programs
writes to the queue. In one process, sharing one definition, neither can happen —
which is the whole of Danielle's bug. Across a network it can, so a real
deployment needs the protocol shared as a build artifact and the codec derived
from the same definition. That is what Scribble-style toolchains generate, and it
is the honest answer to *does this work over a socket*: the session type is the
contract, not the wire format.

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
