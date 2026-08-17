package protocol

// Type-extracting evidence for channel operations.
// Each trait proves a protocol is in a particular form and extracts the
// message type and continuation — so callers never spell out continuation
// types manually.

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
