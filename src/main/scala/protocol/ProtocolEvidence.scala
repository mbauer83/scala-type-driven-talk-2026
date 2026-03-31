package protocol

/**
 * LAYER 1b — Type-extracting evidence for protocol operations
 *
 * These sealed traits decompose a protocol type P into its components,
 * so that Channel operations can infer all types from P alone — callers
 * never have to spell out the continuation type manually.
 *
 *   CanReceive[P] — proves P = Receive[Msg, Rest], exposes Msg and Rest
 *   CanSend[P]    — proves P = Send[Msg, Rest],    exposes Msg and Rest
 *   CanChoose[P]  — proves P = Choose[L, R],       exposes L and R
 *   CanOffer[P]   — proves P = Offer[L, R],        exposes L and R
 *
 * The traits are sealed so no spurious instances can be defined outside
 * this file, preserving the same soundness guarantees as the =:= approach.
 */

sealed trait CanReceive[P <: Protocol]:
  type Msg
  type Rest <: Protocol

object CanReceive:
  given [A, Next <: Protocol]: CanReceive[Receive[A, Next]] with
    type Msg  = A
    type Rest = Next

sealed trait CanSend[P <: Protocol]:
  type Msg
  type Rest <: Protocol

object CanSend:
  given [A, Next <: Protocol]: CanSend[Send[A, Next]] with
    type Msg  = A
    type Rest = Next

sealed trait CanChoose[P <: Protocol]:
  type L <: Protocol
  type R <: Protocol

object CanChoose:
  given [LL <: Protocol, RR <: Protocol]: CanChoose[Choose[LL, RR]] with
    type L = LL
    type R = RR

sealed trait CanOffer[P <: Protocol]:
  type L <: Protocol
  type R <: Protocol

object CanOffer:
  given [LL <: Protocol, RR <: Protocol]: CanOffer[Offer[LL, RR]] with
    type L = LL
    type R = RR
