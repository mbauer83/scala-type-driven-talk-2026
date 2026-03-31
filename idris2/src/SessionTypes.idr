||| LAYER 1 — Session Type Algebra + Duality
|||
||| In Scala 3 (see ../src/main/scala/protocol/), the session type is a phantom
||| class hierarchy and Dual is a *match type* — a compile-time type function.
|||
||| In Idris 2, SessionType is an ordinary *value* of type Type.
||| dual is an ordinary *function* (total, verified by the termination checker).
||| dualInvolution is a *theorem* (a proof term, verified by the type checker).
|||
||| The three key advances over the Scala implementation:
|||   1. dual is provably an involution: dual (dual p) = p
|||   2. SessionType values can be computed from runtime data (e.g. Rule -> SessionType)
|||   3. Chan p can be indexed by a SessionType computed at runtime
module SessionTypes

%default total  -- all functions in this module are verified total

||| The grammar of session types.
|||
||| A SessionType describes the complete communication behaviour of one end of a
||| session.  The other end must have the dual type (see below).
public export
data SessionType : Type where
  ||| The session is complete; no further communication.
  End    : SessionType

  ||| This end sends a value of type `a`, then continues with `rest`.
  Send   : (a : Type) -> (rest : SessionType) -> SessionType

  ||| This end receives a value of type `a`, then continues with `rest`.
  Receive   : (a : Type) -> (rest : SessionType) -> SessionType

  ||| This end *chooses* between left branch `l` and right branch `r`.
  ||| (Internal choice: this end is in control.)
  Choose : (l : SessionType) -> (r : SessionType) -> SessionType

  ||| This end *offers* the other end a choice between `l` and `r`.
  ||| (External choice: the other end decides.)
  Offer  : (l : SessionType) -> (r : SessionType) -> SessionType

-- ─── Duality ─────────────────────────────────────────────────────────────────

||| Compute the dual of a session type.
|||
||| Duality laws:
|||   dual End          = End
|||   dual (Send a p)   = Receive a (dual p)
|||   dual (Receive a p)   = Send a (dual p)
|||   dual (Choose l r) = Offer (dual l) (dual r)
|||   dual (Offer l r)  = Choose (dual l) (dual r)
|||
||| In Scala 3, this is a *match type* (type-level function).
||| Here it is a plain total function from SessionType to SessionType.
||| The termination checker guarantees it is not partial.
public export
dual : SessionType -> SessionType
dual End          = End
dual (Send a p)   = Receive a (dual p)
dual (Receive a p)   = Send a (dual p)
dual (Choose l r) = Offer  (dual l) (dual r)
dual (Offer  l r) = Choose (dual l) (dual r)

-- ─── Compiler-verified theorem: dual is an involution ────────────────────────

||| Proof that applying dual twice is the identity: dual (dual p) = p.
|||
||| In Scala, this property is stated as separate summon[] calls that check
||| individual instances.  Here it is a single *universally quantified* theorem,
||| checked for ALL SessionType values by the Idris type checker.
|||
||| The proof proceeds by structural induction on p.
public export
dualInvolution : (p : SessionType) -> dual (dual p) = p
dualInvolution End = Refl
dualInvolution (Send a p) =
  -- dual (dual (Send a p))
  -- = dual (Receive a (dual p))
  -- = Send a (dual (dual p))
  -- = Send a p         [by induction hypothesis]
  cong (Send a) (dualInvolution p)
dualInvolution (Receive a p) =
  cong (Receive a) (dualInvolution p)
dualInvolution (Choose l r) =
  -- dual (dual (Choose l r))
  -- = dual (Offer (dual l) (dual r))
  -- = Choose (dual (dual l)) (dual (dual r))
  -- = Choose l r              [by IH on l and r]
  rewrite dualInvolution l in
  rewrite dualInvolution r in
  Refl
dualInvolution (Offer l r) =
  rewrite dualInvolution l in
  rewrite dualInvolution r in
  Refl

-- ─── Additional compile-time duality checks ──────────────────────────────────

-- These are checked by the type checker (Refl only typechecks if both sides
-- reduce to the same normal form).

private dualEndIsEnd : dual End = End
dualEndIsEnd = Refl

private dualSendIsReceive : dual (Send Int End) = Receive Int End
dualSendIsReceive = Refl

private dualReceiveIsSend : dual (Receive String End) = Send String End
dualReceiveIsSend = Refl

private dualChooseIsOffer :
  dual (Choose (Send Int End) (Receive Bool End)) =
  Offer (Receive Int End) (Send Bool End)
dualChooseIsOffer = Refl

private dualNestedOk :
  dual (Send Int (Receive String End)) = Receive Int (Send String End)
dualNestedOk = Refl
