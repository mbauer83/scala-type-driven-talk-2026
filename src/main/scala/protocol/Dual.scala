package protocol

/**
 * LAYER 1 — Duality (compile-time type-level computation)
 *
 * If one end has protocol P, the other end MUST have Dual[P].
 * This is enforced at compile time via a Scala 3 match type.
 *
 * Duality laws:
 *   Dual[Send[A, N]]     = Receive[A, Dual[N]]
 *   Dual[Receive[A, N]]  = Send[A, Dual[N]]
 *   Dual[Choose[L, R]]   = Offer[Dual[L], Dual[R]]
 *   Dual[Offer[L, R]]    = Choose[Dual[L], Dual[R]]
 *   Dual[End]            = End
 *
 * The `Transport.open` method uses this to hand out paired channels:
 *   (Channel[P], Channel[Dual[P]])
 * so it is impossible to create a (client, server) pair where the protocols
 * don't correspond.
 */
type Dual[P <: Protocol] <: Protocol = P match
  case End              => End
  case Send[a, n]       => Receive[a, Dual[n]]
  case Receive[a, n]    => Send[a, Dual[n]]
  case Choose[l, r]     => Offer[Dual[l], Dual[r]]
  case Offer[l, r]      => Choose[Dual[l], Dual[r]]

// ─── Compile-time duality proofs ──────────────────────────────────────────────
// The compiler checks these at compile time.  A compilation failure means
// the match type is wrong.

private object DualityProofs:
  // Base cases
  summon[Dual[End] =:= End]
  summon[Dual[Send[Int, End]] =:= Receive[Int, End]]
  summon[Dual[Receive[String, End]] =:= Send[String, End]]

  // Composed
  summon[Dual[Send[Int, Receive[String, End]]] =:= Receive[Int, Send[String, End]]]

  // Choice / Offer
  summon[Dual[Choose[Send[Int, End], Receive[Boolean, End]]] =:=
         Offer[Receive[Int, End], Send[Boolean, End]]]
  summon[Dual[Offer[Send[Int, End], End]] =:=
         Choose[Receive[Int, End], End]]

  // Dual is an involution: Dual[Dual[P]] =:= P
  // (checked for representative cases)
  summon[Dual[Dual[End]]                              =:= End]
  summon[Dual[Dual[Send[Int, End]]]                   =:= Send[Int, End]]
  summon[Dual[Dual[Receive[Int, End]]]                =:= Receive[Int, End]]
  summon[Dual[Dual[Choose[End, Send[Int, End]]]]      =:= Choose[End, Send[Int, End]]]
