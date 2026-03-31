package domain

import java.time.LocalDate
import java.util.UUID

// ─── Raw domain data (no type-level invariants) ───────────────────────────────

case class SearchCriteria(origin: String, destination: String, date: LocalDate, passengerCount: Int)

case class Flight(flightNumber: String, origin: String, destination: String, date: LocalDate, basePrice: BigDecimal)

case class SearchResult(available: Boolean, flights: List[Flight])

case class HoldConfirmation(holdId: UUID, expiresMinutes: Int)

case class CancellationConfirmation(holdId: UUID, message: String)

// ─── Dependent domain types — parameterised by passenger count N ──────────────
//
// The type parameter N <: Int is a *singleton literal type*, e.g. 2, 3, …
// This lets the protocol enforce:
//   • The Quote is for N passengers.
//   • The Payment must match that same N.
//   • The issued Tickets number exactly N.
//
// Attempts to pay a 2-passenger Quote with a 3-passenger Payment are a
// *type error*, caught before the program runs.

/** A fare quote for exactly N passengers. */
final case class Quote[N <: Int](perPersonAmount: BigDecimal, passengers: Int):
  def total: BigDecimal = perPersonAmount * passengers

/** Validated passenger count — value equals the type literal N. */
final case class Passengers[N <: Int] private (count: Int)

object Passengers:
  /**
   * Smart constructor: accepts a literal-typed singleton N so the returned
   * object's phantom type matches the runtime value.
   *
   * Example:
   *   Passengers.of(2)  // : Either[String, Passengers[2]]
   *   Passengers.of(0)  // : Left("Passenger count must be 1–9, got 0")
   */
  def of[N <: Int & Singleton](n: N): Either[String, Passengers[N]] =
    if n >= 1 && n <= 9 then Right(new Passengers[N](n))
    else Left(s"Passenger count must be 1–9, got $n")

  /** Unsafe variant for use in tests / internal code where invariant is known. */
  def unsafeOf[N <: Int & Singleton](n: N): Passengers[N] =
    new Passengers[N](n)

/** Payment for exactly N passengers (amount must cover the Quote[N]). */
final case class PaymentFor[N <: Int](amount: BigDecimal, cardToken: String)

object PaymentFor:
  /**
   * Validate that the payment amount exactly matches the quote.
   * Both are indexed by the same N, preventing accidental mismatch.
   */
  def validate[N <: Int](payment: PaymentFor[N], quote: Quote[N]): Either[String, PaymentFor[N]] =
    if payment.amount == quote.total then Right(payment)
    else Left(s"Payment ${payment.amount} does not match quote total ${quote.total}")

/** N issued flight tickets (one per passenger). */
final case class Tickets[N <: Int](codes: List[String]):
  require(codes.nonEmpty, "Tickets list must not be empty")

object Tickets:
  def issue[N <: Int](pax: Passengers[N], flight: Flight): Tickets[N] =
    Tickets(List.tabulate(pax.count)(i => s"${flight.flightNumber}-${('A' + i).toChar}"))
