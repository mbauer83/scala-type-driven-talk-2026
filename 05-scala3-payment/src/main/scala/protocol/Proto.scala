package protocol

// Protocol algebra for the payment examples.
// A protocol P describes the *shape* of a session: who sends what to whom, in which order.
// No values live here; types carry all the information.

sealed trait Protocol

sealed abstract class End extends Protocol
object End extends End

final class Send[A, Next <: Protocol] extends Protocol
final class Receive[A, Next <: Protocol] extends Protocol
final class Choose[L <: Protocol, R <: Protocol] extends Protocol
final class Offer[L <: Protocol, R <: Protocol] extends Protocol
