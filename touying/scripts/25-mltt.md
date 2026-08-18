A5-mltt · cap 1:45 · Act 5 beat 1 of 3 · MERGE of v1 28-stage6-bridge + 29-mltt-running

TALKING POINTS
1. Two things Scala could not say. Idris 2 says both
2. protocolFromSnapshot returns a SessionType. An ordinary function so far —
   concede that, it is the setup
3. openSession takes that value, calls it p, and p turns up INSIDE the type it
   returns: Session p, and Session (dual p)
4. Ignore L1 and LPair — linear plumbing. Value in on the left, in the type
   on the right
5. That is a type indexed by a runtime value, the first of the four rows
6. Which is why there is no menu: the protocol IS the argument
7. Second row — a value paired with a proof about it. assessOrder returns the
   level, and an assessment whose type mentions that level
8. The answer and the evidence, travelling together
9. Third row — that 1, in front of every channel argument
10. This binding must be used exactly once, and the compiler counts
11. Scala had no way to state that. So let me try to break it

VERBATIM

"Two things Scala could not say, and Idris 2 says both.

Here is the first. `protocolFromSnapshot` takes the risk snapshot and returns a
`SessionType` — an ordinary function returning an ordinary value, and you have
written a thousand of those.

Now look at the line under it. `openSession` takes that value and calls it `p` —
and then `p`, the value, turns up inside the type it hands back: one channel at
`Session p`, the other at `Session` of `dual p`. Ignore the `L1` and the `LPair`,
which are Idris's linear plumbing; the shape to see is a value going in on the
left and appearing in the type on the right.

That is the first of those four rows, a type indexed by a runtime value, and it
is why there is no menu here. The protocol is the argument.

The second row was a value paired with a proof about it, and `assessOrder` is
that: it hands back the risk level together with an assessment whose type
mentions the level it came from. The answer and the evidence, as one thing.

And the third row is that `1`. Every one of these channel operations carries a
`1` in front of its channel argument, which says that this binding has to be used
exactly once — and the compiler counts.

That is a rule about your program that Scala had no way to state. So let me try
to break it."

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
