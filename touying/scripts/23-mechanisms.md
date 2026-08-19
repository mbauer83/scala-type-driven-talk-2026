A4-mechanisms · cap 1:20 · Act 4 beat 5 of 6

TALKING POINTS
1. Everything Scala has been doing for the last few minutes has a name
2. The predicate in the type — a refined type
3. AuthCode that cannot go where CaptureId is expected — an opaque type
4. CanSend[P] — the twin of the CanReceive Demo 4 just failed to find. P is
   what is LEFT of the protocol; CanSend is a claim ABOUT P,
   that it starts with a send. Ask for the claim as evidence, get the message
   type with it — which is why send knows what it accepts
5. finish asks for evidence of a different claim: the protocol has ended
6. All of those put something about a value into its type
7. There is another family for what a value is allowed to DO
8. ZIO — loadUser returns ZIO of Database, DbError, User. In production today
9. Scala 3 experimental: all three go on the ARROW — the database, the
   permission to fail that way, and nothing else
10. Same move, applied to what a value lets you do

VERBATIM

"Everything Scala has been doing for the last few minutes has a name, and the
names are how you find any of it again. The predicate in the type is a refined
type; the `AuthCode` that cannot go where a `CaptureId` is expected is an opaque
one.

`CanSend[P]` is the twin of the `CanReceive` you just watched fail. `P` is
whatever is left of the protocol, and
`CanSend` is a claim about `P` — that it starts with a send. Ask the compiler for
that claim as evidence, and the message type comes with it, which is why `send`
already knows what it will accept. `finish` asks for evidence of a different
claim: that the protocol has ended.

And the last one goes up a level again. `F` of underscore is a type parameter
that is itself generic — it stands for `List`, not for a list of something — and
Java has no way to write that. Here it means the payment rules are one tree,
walked once, and what comes out of the walk is a parameter: an audit sentence, or
a risk analysis.

All of that puts something about a value into the value's type. Next door is a
family that puts in what a value may do. Plenty of teams run ZIO in production,
where `loadUser` comes back as `ZIO` of `Database`, `DbError`, `User` — it needs
a database, it can fail this way, it produces a user, and a caller has to deal
with all three. Scala 3 has an experimental way of putting the same three on the
arrow instead: a function to `User` carrying the database and the permission to
fail that way, and nothing else."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE SEAM WITH DEMO 4 (19 Aug)
`A4-demo4` now sits between `A4-sessions` and this slide, and its error is
*»No given instance of CanReceive…«*. So the `CanSend[P]` paragraph opens by
naming it as the twin of the thing the room has just watched the compiler fail to
find, instead of introducing it cold. Five words, and it turns a vocabulary row
into the explanation of an error they have seen. **Reversible** — it used to read
*»`CanSend[P]` is worth a second.«*

WHY A NAMING SLIDE IS NOT FURNITURE HERE
Part 12/R8 is the reason: the talk *should* use the technical term at the beat
where the technique is the subject, and the audience wants the name so they can
go and read about it afterwards. Every mechanism on this slide has just run in
front of them, so the name is being attached to a thing they have seen rather
than taught cold. That is the one shape in which a vocabulary slide earns a cap.

What it must not become is the v1 version: six rows, each read out in a sentence
of its own, which is the demo narrated a second time. The rows are on the wall to
be photographed; roughly twenty-five seconds of speech touches four of them and
the rest of the beat is the effects family, which is new.

THE EFFECTS ASIDE IS PART 3'S, AND IT IS ~40 SECONDS
Plan, Act 4: *»`ZIO[Database, DbError, User]` puts 'this needs a database' in the
type. Scala 3's experimental capture checking does the same without the monad —
`User^{db}`. Same idea one level up: not which values you hold, but which
capabilities they carry.«* Rewritten here to define positively (Part 12/R1) —
*the same move, applied to what a value lets you do* — because the plan's version
is a not-X-but-Y.

Depth stays in the appendix: `a01-tracking` has the ZIO/capture-checking pair
side by side with costs and status, for Q&A.

FACTS
- `ZIO[R, E, A]`: `R` is the environment the effect requires, `E` the error type,
  `A` the success type. `ZIO[Database, DbError, User]` reads exactly as spoken.
  Mature, widely deployed; cats-effect solves the same problem differently.
- **Parity with ZIO's three parameters** (MB, 19 Aug). `ZIO[Database, DbError,
  User]` carries all three; an arrow carrying only `db` did not match it. The
  capture set holds *references to capabilities*, not types, so it is
  `->{db, canThrow}` with `canThrow: CanThrow[DbError]` in scope, not
  `->{db, CanThrow[DbError]}`. `CanThrow` is `erased class CanThrow[-E <:
  Exception]` from `saferExceptions`, and a `throws E` clause desugars to
  `using CanThrow[E]` — so the two experiments compose, and the Scala 3 reference
  has a whole page on it (`capture-checking/checked-exceptions`). Say »the
  database, and the permission to fail that way«; do not say `CanThrow` aloud.
- Capture checking is experimental in Scala 3 (the Caprese line of work) and is
  not production. **The example is a FUNCTION type, not a data type** (MB, 18
  Aug): `A ->{c} B` is a pure function type capturing `c`, and is shorthand for
  `(A -> B)^{c}`; `A => B` is the impure form, an alias for `A ->{cap} B`. The
  earlier version on this slide was `def loadUser(id: UserId): User^{db}`, which
  annotates the *returned User* with a capability — a different and much less
  interesting claim, and not the parallel to ZIO's `R` parameter. Checked against
  the Scala 3 reference, `experimental/capture-checking/basics`. Say »experimental« out loud — a room that goes and tries it on
  Monday and finds a compiler flag will not forgive the omission.
- The mechanisms, grepped: `type NonEmptyString = String :| MinLength[1]`
  (`payment/Domain.scala:98`); `opaque type AuthCode = String`, `CaptureId`,
  `RefundId` (`Domain.scala:135-137`); `def send(using s: CanSend[P])(value:
  s.Msg): Channel[s.Rest]` (`runtime/Chan.scala:25`) with `CanSend`'s `type Msg`
  and `type Rest` in `protocol/ProtocolEvidence.scala:17-19`; `def
  finish()(using ev: P =:= End): Unit` (`Chan.scala:56`).

HIGHER-KINDED TYPES ARE BACK (MB, 19 Aug)
It was cut for width: real, good, closes no incident, appears in no demo, so it
paid least for the space it took. It was also recorded here as the cheapest thing
to restore if the read-through came in short — and MB's standing run came in at
33 minutes against a 45-minute slot, so it is restored.

It gets a short passage, not a paragraph, which is what kept the v1 version from
working. Two things have to land and nothing else. **`F[_]` is a type parameter
that is itself generic** — the Java room's hook is that `List` on its own is not
a type they can name in a signature, and here it is. And **what it buys**, in
this domain rather than in the abstract: the rules are one tree, walked once, and
the thing you walk it into is a parameter.

MB, 19 Aug, on both halves. *»a type that still wants a type«* was cute and told
nobody anything. *»audit string, risk analysis — whatever comes next«* was
gibberish to anyone who has not done a deep dive on algebras and interpreters,
because the room has never been shown either interpretation. Naming them as
things — the sentence an auditor reads, the analysis the risk engine runs — costs
four words and means something.

FACTS — grepped (C1)
- `trait Functor[F[_]]` with `def map[A, B](fa: F[A])(f: A => B): F[B]` —
  `payment/Rules.scala:22-23`.
- `def interpret[F[_]: Functor, A](algebra: F[A] => A)(fix: Fix[F]): A` —
  `payment/Rules.scala:41-42`. On the slide, truncated after the `algebra`
  parameter list, which is the part that shows the shape.
- `case class Fix[F[_]](unfix: F[Fix[F]])` — `payment/Rules.scala:37`; `type
  Policy = Fix[PolicyF]` — `:39`.
- The two interpretations that make the point are real and both in the file:
  `interpret[PolicyF, String]` at `:60` (the audit string) and
  `interpret[PolicyF, Analysis]` at `:80`. One tree, two folds.
- If asked why this is not just a visitor: the algebra is a value you pass, the
  recursion is written once in `interpret`, and `F` is a parameter — so a new
  interpretation is a new function, not a new class in a hierarchy somebody has
  to edit.

JOIN
Backwards: `A4-sessions`, and Danielle. Forwards: `A4-ceiling`, which is the
payoff and then the two things Scala still lets you write.
