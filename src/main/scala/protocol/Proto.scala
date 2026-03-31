package protocol

/**
 * LAYER 1 — Protocol Algebra (types only)
 *
 * A protocol `P <: Protocol` describes the *shape* of a communication session.
 * No values ever live here; types carry all the information.
 *
 * The four constructors cover the full session-type fragment:
 *   Send[A, Next]    — this end emits an A, then follows Next
 *   Receive[A, Next] — this end receives an A, then follows Next
 *   Choose[L, R]     — this end picks the Left or Right branch (internal choice)
 *   Offer[L, R]      — this end waits for the other side to choose (external choice)
 *   End              — the session is complete
 */
sealed trait Protocol

/** Terminate the session cleanly. */
sealed abstract class End extends Protocol
object End extends End

/** This end sends a value of type A, then continues with Next. */
final class Send[A, Next <: Protocol] extends Protocol

/** This end receives a value of type A, then continues with Next. */
final class Receive[A, Next <: Protocol] extends Protocol

/**
 * Internal choice: *this* end picks Left or Right.
 * Its dual is Offer[Dual[L], Dual[R]].
 */
final class Choose[L <: Protocol, R <: Protocol] extends Protocol

/**
 * External choice: the *other* end picked; this end handles Left or Right.
 * Its dual is Choose[Dual[L], Dual[R]].
 */
final class Offer[L <: Protocol, R <: Protocol] extends Protocol
