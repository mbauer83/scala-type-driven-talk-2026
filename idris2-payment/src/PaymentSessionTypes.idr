||| Session-type core for the payment demo.
module PaymentSessionTypes

%default total

public export
data SessionType : Type where
  End     : SessionType
  Send    : (a : Type) -> (rest : SessionType) -> SessionType
  Receive : (a : Type) -> (rest : SessionType) -> SessionType
  Choose  : (l : SessionType) -> (r : SessionType) -> SessionType
  Offer   : (l : SessionType) -> (r : SessionType) -> SessionType

public export
dual : SessionType -> SessionType
dual End            = End
dual (Send a rest)    = Receive a (dual rest)
dual (Receive a rest) = Send a (dual rest)
dual (Choose l r)   = Offer (dual l) (dual r)
dual (Offer l r)    = Choose (dual l) (dual r)

public export
dualInvolution : (p : SessionType) -> dual (dual p) = p
dualInvolution End = Refl
dualInvolution (Send a rest) = cong (Send a) (dualInvolution rest)
dualInvolution (Receive a rest) = cong (Receive a) (dualInvolution rest)
dualInvolution (Choose l r) =
  rewrite dualInvolution l in
  rewrite dualInvolution r in
  Refl
dualInvolution (Offer l r) =
  rewrite dualInvolution l in
  rewrite dualInvolution r in
  Refl
