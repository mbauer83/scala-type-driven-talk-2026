package protocol

// Duality — computed at compile time via a match type.
// If the client has protocol P, the server must have Dual[P].
// A mismatch is a compile error, not a runtime protocol disagreement.

type Dual[P <: Protocol] <: Protocol = P match
  case End           => End
  case Send[a, n]    => Receive[a, Dual[n]]
  case Receive[a, n] => Send[a, Dual[n]]
  case Choose[l, r]  => Offer[Dual[l], Dual[r]]
  case Offer[l, r]   => Choose[Dual[l], Dual[r]]

private object DualityProofs:
  summon[Dual[End] =:= End]
  summon[Dual[Send[Int, End]] =:= Receive[Int, End]]
  summon[Dual[Receive[String, End]] =:= Send[String, End]]
  summon[Dual[Dual[End]] =:= End]
  summon[Dual[Dual[Send[Int, End]]] =:= Send[Int, End]]
  summon[Dual[Choose[End, Send[Int, End]]] =:= Offer[End, Receive[Int, End]]]
