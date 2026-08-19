A4-mechanisms · cap 2:00 · Act 4 beat 5 of 6

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
type; the `AuthCode` that cannot go where a `CaptureId` is expected, though both
are strings, is an opaque type.

`CanSend[P]` is the twin of the `CanReceive` you just watched fail. `P` is
whatever is left of the protocol, and
`CanSend` is a claim about `P` — that it starts with a send. Ask the compiler for
that claim as evidence, and the message type comes with it, which is why `send`
already knows what it will accept. `finish` asks for evidence of a different
claim: that the type for the current protocol-remainder is <<End>> at this point.

And the last one goes up a level again. `F` of underscore is a type parameter
that is itself generic — it stands, say, for `List`, not for a list of something
— which Java has no way to write. Here it means the payment rules are one tree,
walked once, and what comes out depends on what you walk it into: an audit
sentence, or a risk analysis.

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

THE EFFECTS ASIDE IS PART 3'S, AND IT IS ~40 SECONDS
Plan, Act 4: *»`ZIO[Database, DbError, User]` puts 'this needs a database' in the
type. Scala 3's experimental capture checking does the same without the monad —
`User^{db}`. Same idea one level up: not which values you hold, but which
capabilities they carry.«* Rewritten here to define positively —
*the same move, applied to what a value lets you do* — because the plan's version
is a not-X-but-Y.

Depth stays in the appendix: `a01-tracking` has the ZIO/capture-checking pair
side by side with costs and status, for Q&A.

FACTS
- `ZIO[R, E, A]`: `R` is the environment the effect requires, `E` the error type,
  `A` the success type. `ZIO[Database, DbError, User]` reads exactly as spoken.
  Mature, widely deployed; cats-effect solves the same problem differently.
- **Parity with ZIO's three parameters**. `ZIO[Database, DbError,
  User]` carries all three; an arrow carrying only `db` did not match it. The
  capture set holds *references to capabilities*, not types, so it is
  `->{db, canThrow}` with `canThrow: CanThrow[DbError]` in scope, not
  `->{db, CanThrow[DbError]}`. `CanThrow` is `erased class CanThrow[-E <:
  Exception]` from `saferExceptions`, and a `throws E` clause desugars to
  `using CanThrow[E]` — so the two experiments compose, and the Scala 3 reference
  has a whole page on it (`capture-checking/checked-exceptions`). Say »the
  database, and the permission to fail that way«; do not say `CanThrow` aloud.
- Capture checking is experimental in Scala 3 (the Caprese line of work) and is
  not production. **The example is a FUNCTION type, not a data type** (the speaker, 18
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
