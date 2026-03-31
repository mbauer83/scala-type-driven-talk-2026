package demos

import protocol.*
import domain.*
import runtime.{Channel, Transport, Logger}
import derivation.{Capability, ProtocolVariant}
import rules.{Policy, Interpretations}
import java.time.LocalDate
import java.util.UUID
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration

object BookingDemo:
  def main(args: Array[String]): Unit = runAll()

  def runAll(): Unit =
    demo1_HappyPath()
    demo2_Cancellation()
    demo3_NoAvailability()
    demo4_InvalidPassengers()
    demo5_PaymentMismatch()
    demo6_PolicyDerivation()

  // ─── Shared sample data ────────────────────────────────────────────────────

  val frankfurtLondonFlight = Flight("LH404", "JFK", "LHR", LocalDate.of(2026, 6, 15), BigDecimal("450.00"))
  val searchNewYorkToLondon = SearchCriteria("JFK", "LHR", LocalDate.of(2026, 6, 15), passengerCount = 2)

  // ══════════════════════════════════════════════════════════════════════════
  // Demo 1 — Happy path: search → quote → reserve → pay → issue tickets
  // ══════════════════════════════════════════════════════════════════════════

  def demo1_HappyPath(): Unit =
    Logger.header("DEMO 1 — Happy Path  (search → quote → pay → tickets)")

    val (clientEnd, serverEnd) = Transport.open[BookingProtocol.Refundable[2]]

    val serverFiber = Future { serverHandleRefundable(serverEnd) }
    val clientFiber = Future { clientPayBooking(clientEnd) }

    Await.result(serverFiber, Duration.Inf)
    val tickets = Await.result(clientFiber, Duration.Inf)
    Logger.footer(s"Tickets issued: ${tickets.codes.mkString(", ")}")

  def clientPayBooking(booking: Channel[BookingProtocol.Refundable[2]]): Tickets[2] =
    val searching            = booking.send(searchNewYorkToLondon)
    val (result, reviewing)  = searching.receive()
    assert(result.available, "Expected flights to be available")

    val passengers: Passengers[2] = Passengers.unsafeOf(2)
    val pricing                   = reviewing.send(passengers)

    val (quote, holding)    = pricing.receive()
    Logger.info(s"Quote received: £${quote.total} for ${passengers.count} passengers")

    val (hold, deciding)    = holding.receive()
    Logger.info(s"Hold confirmed: ${hold.holdId} (${hold.expiresMinutes} min)")

    val paying              = deciding.selectLeft()
    val payment             = PaymentFor[2](quote.total, "tok_visa_4242")
    val ticketing           = paying.send(payment)

    val (tickets, done)     = ticketing.receive()
    done.finish()
    tickets

  def serverHandleRefundable[N <: Int](session: Channel[Dual[BookingProtocol.Refundable[N]]]): Unit =
    val (criteria, searching)   = session.receive()

    val flights = List(frankfurtLondonFlight).filter(f =>
      f.origin == criteria.origin && f.destination == criteria.destination)
    val result = SearchResult(available = flights.nonEmpty, flights = flights)
    val quoting = searching.send(result)

    if !result.available then
      Logger.error("SERVER", "No availability — protocol would branch here (see Demo 3)")
      return

    val (passengers, pricing) = quoting.receive()

    val quote   = Quote[N](perPersonAmount = BigDecimal("450.00"), passengers = passengers.count)
    val holding = pricing.send(quote)

    val hold     = HoldConfirmation(UUID.randomUUID(), expiresMinutes = 15)
    val offering = holding.send(hold)

    offering.awaitChoice() match
      case Left(takingPayment) =>
        val (payment, paid) = takingPayment.receive()
        PaymentFor.validate(payment, quote) match
          case Right(_) =>
            val tickets  = Tickets.issue(passengers, flights.head)
            val ticketed = paid.send(tickets)
            ticketed.finish()
          case Left(err) =>
            Logger.error("SERVER", s"Payment validation failed: $err")

      case Right(cancelling) =>
        val cancellation = CancellationConfirmation(hold.holdId, "Booking cancelled — no charge")
        val cancelled    = cancelling.send(cancellation)
        cancelled.finish()

  // ══════════════════════════════════════════════════════════════════════════
  // Demo 2 — Cancellation: search → quote → reserve → CANCEL
  // ══════════════════════════════════════════════════════════════════════════

  def demo2_Cancellation(): Unit =
    Logger.header("DEMO 2 — Cancellation  (search → quote → cancel)")

    val (clientEnd, serverEnd) = Transport.open[BookingProtocol.Refundable[1]]

    val serverFiber = Future { serverHandleRefundable(serverEnd) }
    val clientFiber = Future {
      val criteria = SearchCriteria("JFK", "LHR", LocalDate.of(2026, 6, 15), 1)

      val searching           = clientEnd.send(criteria)
      val (_, reviewing)      = searching.receive()
      val pricing             = reviewing.send(Passengers.unsafeOf(1))
      val (_, holding)        = pricing.receive()
      val (_, deciding)       = holding.receive()

      // Choose RIGHT branch (cancel)
      val cancelling             = deciding.selectRight()
      val (cancellation, done)   = cancelling.receive()
      done.finish()
      cancellation
    }

    Await.result(serverFiber, Duration.Inf)
    val cancellation = Await.result(clientFiber, Duration.Inf)
    Logger.footer(s"Cancelled: ${cancellation.message}")

  // ══════════════════════════════════════════════════════════════════════════
  // Demo 3 — No availability: server sends empty result, session ends
  // ══════════════════════════════════════════════════════════════════════════

  def demo3_NoAvailability(): Unit =
    Logger.header("DEMO 3 — No Availability  (search → no flights → End)")

    val (clientEnd, serverEnd) = Transport.open[BookingProtocol.NoAvailability]

    val serverFiber = Future {
      val (_, searching) = serverEnd.receive()
      // No flights on this route
      val done = searching.send(SearchResult(available = false, flights = Nil))
      done.finish()
    }

    val clientFiber = Future {
      val searching       = clientEnd.send(SearchCriteria("JFK", "NRT", LocalDate.of(2026, 6, 15), 1))
      val (result, done)  = searching.receive()
      done.finish()
      result
    }

    Await.result(serverFiber, Duration.Inf)
    val result = Await.result(clientFiber, Duration.Inf)
    Logger.footer(s"Search returned: available=${result.available}, flights=${result.flights.size}")

  // ══════════════════════════════════════════════════════════════════════════
  // Demo 4 — Invalid passengers: validation rejects count, no session started
  // ══════════════════════════════════════════════════════════════════════════

  def demo4_InvalidPassengers(): Unit =
    Logger.header("DEMO 4 — Invalid Passengers  (runtime validation at domain boundary)")

    // Attempting to validate 0 passengers returns a Left — the session
    // is never started, so no illegal protocol state is reachable.
    val result0 = Passengers.of(0)
    val result1 = Passengers.of(10)
    val result2 = Passengers.of(2)

    Logger.info(s"Passengers.of(0)  = $result0")
    Logger.info(s"Passengers.of(10) = $result1")
    Logger.info(s"Passengers.of(2)  = $result2")
    Logger.footer("Domain validation prevents entering the protocol with bad data")

  // ══════════════════════════════════════════════════════════════════════════
  // Demo 5 — Payment mismatch: domain-layer rejection
  // ══════════════════════════════════════════════════════════════════════════

  def demo5_PaymentMismatch(): Unit =
    Logger.header("DEMO 5 — Payment Mismatch  (dependent type enforcement)")

    val quote: Quote[2]          = Quote[2](perPersonAmount = BigDecimal("450.00"), passengers = 2)
    val correctPayment: PaymentFor[2] = PaymentFor[2](BigDecimal("900.00"), "tok_ok")
    val shortPayment:   PaymentFor[2] = PaymentFor[2](BigDecimal("500.00"), "tok_bad") // wrong amount
    // NOTE: you CANNOT create PaymentFor[3] and pass it to validate[2] —
    // that would be a *compile error* (type mismatch N=3 vs N=2).
    // The only way to get the type wrong at the value level is wrong amount.

    Logger.info(s"Quote total: £${quote.total}")
    Logger.info(s"Validate correct payment: ${PaymentFor.validate(correctPayment, quote)}")
    Logger.info(s"Validate short   payment: ${PaymentFor.validate(shortPayment,   quote)}")
    Logger.footer("PaymentFor[3] vs Quote[2] is caught by the compiler, not at runtime")

  // ══════════════════════════════════════════════════════════════════════════
  // Demo 6 — Protocol derivation from Policy DSL
  // ══════════════════════════════════════════════════════════════════════════

  def demo6_PolicyDerivation(): Unit =
    Logger.header("DEMO 6 — Protocol Derivation from Policy DSL")

    import rules.Policy
    import Interpretations.*

    // Build two sample booking policies using the DSL
    val flexiblePolicy: Policy =
      Policy.refundable(Policy.minStay(2)(Policy.requiresIdentification(Policy.noConstraint)))

    val strictPolicy: Policy =
      Policy.both(
        Policy.nonRefundable(Policy.noConstraint),
        Policy.minStay(5)(Policy.noConstraint)
      )

    // Multiple interpretations of the SAME structure — no re-traversal
    Logger.info("─── Flexible fare ───────────────────────────────")
    Logger.info(s"  Policy:   ${describe(flexiblePolicy)}")
    Logger.info(s"  Analysis: ${analyze(flexiblePolicy)}")

    Logger.info("─── Strict fare ─────────────────────────────────")
    Logger.info(s"  Policy:   ${describe(strictPolicy)}")
    Logger.info(s"  Analysis: ${analyze(strictPolicy)}")

    // Derive capabilities and select protocol variant
    val flexibleCaps = Capability.deriveFrom(flexiblePolicy)
    val strictCaps   = Capability.deriveFrom(strictPolicy)

    Logger.info("─── Protocol selection from capabilities ─────────")
    Logger.info(s"  Flexible caps:   $flexibleCaps")
    Logger.info(s"  → variant:       ${ProtocolVariant.selectFrom(flexibleCaps)}")
    Logger.info(s"  Strict caps:     $strictCaps")
    Logger.info(s"  → variant:       ${ProtocolVariant.selectFrom(strictCaps)}")

    // Run the appropriate protocol variant
    ProtocolVariant.selectFrom(flexibleCaps) match
      case ProtocolVariant.Refundable =>
        Logger.info("  Executing refundable (full Cancel|Pay) protocol…")
        val (clientEnd, serverEnd) = Transport.open[BookingProtocol.Refundable[2]]
        val serverFiber = Future { serverHandleRefundable(serverEnd) }
        val clientFiber = Future { clientPayBooking(clientEnd) }
        Await.result(serverFiber, Duration.Inf)
        val tickets = Await.result(clientFiber, Duration.Inf)
        Logger.footer(s"Derived protocol completed — tickets: ${tickets.codes.mkString(", ")}")

      case ProtocolVariant.NonRefundable =>
        Logger.info("  Executing non-refundable protocol…")
        Logger.footer("(non-refundable path; no cancel branch in protocol)")
