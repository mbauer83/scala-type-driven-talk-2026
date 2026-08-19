A5-mltt · cap 1:45 · Act 5 beat 1 of 3 · MERGE of v1 28-stage6-bridge + 29-mltt-running

TALKING POINTS
1. Two things Scala could not say. Idris 2 says both
2. START at `data Session : SessionType -> Type` — that line is the trick
2b. A SessionType is only a DESCRIPTION — a tree. It holds no code
3. protocolFromSnapshot is an ORDINARY function: snapshot in, a value out
4. openSession takes that value, calls it p, and p turns up INSIDE the type it
   returns: Session p, and Session (dual p)
5. Ignore L1 and LPair — linear plumbing. Value in on the left, in the type
   on the right
6. A type indexed by a runtime value. No hardcoded list of protocol variants
7. Second row — a value paired with a proof about it. assessOrder returns the
   level, and an assessment whose type mentions that level
8. The answer and the evidence, travelling together
9. Third row — that 1, in front of every channel argument
10. This binding must be used exactly once, and the compiler counts
11. Scala had no way to state that. So let me try to break it

VERBATIM

"Two things Scala could not say, and Idris 2 says both.

Start at the top, because that first line is the whole trick. `Session` is a type
that takes a `SessionType`, so which type you get depends on the value you hand
it. and a `SessionType` is a description and nothing more — a little tree that says
send this, then receive that.

`protocolFromSnapshot` underneath is an ordinary function: snapshot in, one of
those descriptions out, and you have written a thousand like it.

Now put them together. `openSession` takes that value, calls it `p`, and `p`
turns up inside the type it hands back — one channel at `Session p`, the other
at `Session` of `dual p`. Ignore the `L1` and the `LPair`; the shape to see is a
value going in on the left and appearing in a type on the right.

That is the first of the four rows, a type indexed by a runtime value, and it is
why nobody has to write the protocol variants out in advance.

The second row is a value paired with a proof about it: `assessOrder` hands back
the risk level together with an assessment whose type mentions that level. The
answer and the evidence, as one thing.

And the third is that `1`. Every channel operation carries one in front of its
channel argument, meaning this binding has to be used exactly once — and the
compiler counts.

A rule about your program that Scala had no way to state. So let me break it."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE LANGUAGE CHANGE IS ANNOUNCED HERE, IN THE FIRST SENTENCE
Same decision as `A4-opens`, and its PREPARATION has the reasoning for why there
is no dark stage-opener slide at either language change. The first sentence
names Idris 2 and the eyebrow is a filled chip; that is the whole announcement.

THIS SLIDE PAYS OFF THREE OF THE FOUR ROWS FROM `A1-above`
`A1-above` puts four notations on the wall with their real code and promises
*you will walk out knowing what each one buys, having watched all four run on the
payment flow*:

    Π   Approval : RiskLevel -> Type              a type indexed by a runtime value
    Σ   (lvl : RiskLevel ** Assessment lvl n c)   a value paired with a proof about it
    1   (1 _ : Session p) -> ...                  a binding used exactly once
    ⇄   Send[Order, Receive[RiskSnapshot, ...]]   a whole conversation, as one type

⇄ was paid off at `A4-sessions`. Π and Σ land here, `1` is set up here and fired
by Demo 4. The slide shows the same fragments the primer showed, beside the real
signatures — that is the payoff, and it is why the row order is Π, Σ, 1.

Reference the SLIDE, never the clock (MB, 18 Aug). `A4-sessions` has already
reminded the room what the four rows were, so this beat can just say *the first
of those four* and get on with it.

FACTS — grepped against `06-idris2-payment/src/` (C1, rule 9)
- `protocolFromSnapshot : (snap : RiskSnapshot) -> (n : Nat) -> (c : Currency)
  -> SessionType` — `PaymentRules.idr:212-214`. **Three parameters.** The
  one-argument story belongs to `protocolDerivedFrom` (`:224`), which takes an
  `Order` plus two implicits and is not a drop-in substitute. The slide shows
  the three-parameter signature and elides nothing.
- `openSession : (p : SessionType) -> L1 IO (LPair (Session p) (Session (dual p)))`
  — `PaymentChannel.idr:73`. This is the best single line in the repository for
  this talk: the return type is indexed by the argument *value*, and the two ends
  are `p` and `dual p` from one expression.
- The call site: `(clientEnd # serverEnd) <- openSession (protocolFromSnapshot
  snapshot n c)` — `Main.idr:277`, inside `runOrderScenario`.
- `assessOrder : Order n c -> (lvl : RiskLevel ** Assessment lvl n c)` —
  `PaymentDomain.idr:255`. **Keep the `: RiskLevel` in the dependent pair.**
  Dropping it is legal Idris sugar and it hides the index type, which is the
  whole point of the row.
- `data Approval : RiskLevel -> Type` — `PaymentDomain.idr:264`. The literal
  fragment from `A1-above`, on the slide as the callback.
- `finish : (1 _ : Session End) -> L IO ()` — `PaymentChannel.idr:146`. `send`,
  `receive`, `selectLeft`, `selectRight` and `awaitChoice` all carry the same
  `(1 _ : Session ...)`.

`Send` AND `Receive` ARE CONSTRUCTORS, NOT METHODS (MB, 19 Aug — checked)
MB asked whether the protocol value holds the send/receive operations, i.e.
whether it contains a client. It does not, and the naming is what makes that
worth one clause on stage:

- `Send`, `Receive`, `Choose`, `Offer`, `End` are **data constructors of
  `SessionType`** (`PaymentSessionTypes.idr:7-12`). `lowRiskProtocol` builds
  `Send (Order n c) $ Receive RiskSnapshot $ …` (`PaymentRules.idr:182-186`) —
  a tree of tags. No behaviour anywhere in it.
- The endpoint is `data Session : SessionType -> Type` with
  `MkSession : Channel Blob -> Channel Blob -> Session p`
  (`PaymentChannel.idr:66-67`) — two byte channels, and that is all.
- The operations are ordinary top-level functions whose *types* pattern-match on
  the description: `send : (1 _ : Session (Send a rest)) -> a -> L1 IO (Session
  rest)` (`PaymentChannel.idr:82`). `send` will only accept a channel whose
  description starts with `Send`.

So: description, endpoint, and operations are three separate things. If someone
reads `Send` as a method the whole beat collapses, which is why the script now
says *a description — a little tree … it holds no code and does nothing*.

`protocolFromSnapshot` IS NOT A TYPE-LEVEL FUNCTION (MB, 19 Aug — checked)
The question was whether it returns a *type* or a *value*. It returns a **value**,
and the distinction is the whole beat, so it must not blur:

- `data SessionType : Type where End | Send | Receive | Choose | Offer`
  (`PaymentSessionTypes.idr:7-12`) — an ordinary algebraic data type.
- `protocolFromSnapshot : (snap : RiskSnapshot) -> (n : Nat) -> (c : Currency)
  -> SessionType` (`PaymentRules.idr:212-214`) — an ordinary function returning
  an ordinary value. Nothing dependent about it.
- `dual : SessionType -> SessionType` (`PaymentSessionTypes.idr:15-20`) —
  likewise ordinary, and `%default total`.
- **`data Session : SessionType -> Type`** (`PaymentChannel.idr:66`) — THIS is
  the dependency. `Session` is a type family *indexed by a value*, so `Session p`
  is a type determined by which `SessionType` value `p` is.
- It bites at `openSession : (p : SessionType) -> L1 IO (LPair (Session p)
  (Session (dual p)))` (`PaymentChannel.idr:73`): the return type mentions the
  argument value. That is the Π-type, and `p` can be computed at runtime.

So the slide leads with `data Session : SessionType -> Type` and the script says
so first. Saying *protocolFromSnapshot computes a type* would be plainly false
and a Scala or Haskell person in the room would catch it.

WHY `L1 IO` IS WAVED PAST OUT LOUD (MB, 18 Aug)
It is on the slide because the signature is verbatim, and MB is right that a room
cannot parse it cold. Saying *ignore the linear plumbing; the shape to see is the
value on the left turning up in the type on the right* costs ten words and tells
them where to look. Teaching `L1` costs thirty seconds and buys nothing this beat
needs. The slide carries a dim gloss saying the same.

ALSO MB: *a value computed while the program is running, out of data from
outside* describes almost every program, so it established nothing. The beat now
concedes the mundane first — an ordinary function returning an ordinary value —
and the step is the NEXT line, where that value appears inside a type.

WHAT `L1 IO`, `LPair` AND `#` ARE, IF ASKED
`L1 IO` is a linear `IO`; `LPair` is a pair whose components are linear; `#` is
its constructor, which is why the call site destructures with `clientEnd #
serverEnd`. None of that is said out loud — it is Idris's linear plumbing and it
teaches nothing about the argument. If the room asks, that is the answer.

MULTIPLICITIES, IF ASKED
Idris 2 is built on Quantitative Type Theory: every binding carries a
multiplicity, and there are three. `0` means erased — present for the type
checker, gone at runtime. `1` means used exactly once. Unwritten means
unrestricted, which is what every other language in this talk has for everything.
Do **not** say *QTT* on stage; say *the compiler counts*. The name is for Q&A.

TWO THINGS THE SLIDE DOES NOT CLAIM (C2)
- **Idris proves duality in general, and Scala cannot.** True —
  `dualInvolution : (p : SessionType) -> dual (dual p) = p`,
  `PaymentSessionTypes.idr:23-34`, by structural induction. It is the honest
  answer to the Q&A question `A4-ceiling` sets up, and it is not on this slide
  because it is a proof-assistant point and there is no airtime.
- **Serialisation is still unsafe.** `PaymentChannel.idr` uses `believe_me`
  casts in the transport layer, so a type mismatch on the wire is still a runtime
  error. That is a real remaining gap and it belongs in Q&A, honestly given.

WHY 29-mltt-running IS GONE
It carried the Π and Σ inference rules as rule-cards beside the code — a second
telling of `A1-connectives`' notation, 315 words against no cap, and its speaker
note was a nine-item IDE runbook. The rules were taught in Act 1; what this beat
needs is the code running, which is what is left.

JOIN
Backwards: `A4-ceiling` named exactly these two limits and said there is a
language that does both. Forwards: Demo 4 fires the `1`.
