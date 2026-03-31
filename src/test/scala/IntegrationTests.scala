import munit.FunSuite
import protocol.*
import domain.*
import runtime.{Channel, Transport, Logger}
import java.time.LocalDate
import java.util.UUID
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration

class IntegrationTests extends FunSuite:

  // ── helpers ────────────────────────────────────────────────────────────────

  val flight = Flight("LH404", "JFK", "LHR", LocalDate.of(2026, 6, 15), BigDecimal("450"))

  // ── Full pay path ──────────────────────────────────────────────────────────

  test("full pay path completes without error"):
    import demos.BookingProtocol

    val (clientEnd, serverEnd) = Transport.open[BookingProtocol.Refundable[2]]

    val serverFiber = Future {
      val (_, searching)        = serverEnd.receive()
      val quoting               = searching.send(SearchResult(true, List(flight)))
      val (passengers, pricing) = quoting.receive()
      val quote                 = Quote[2](BigDecimal("450"), passengers.count)
      val holding               = pricing.send(quote)
      val offering              = holding.send(HoldConfirmation(UUID.randomUUID(), 15))
      offering.awaitChoice() match
        case Left(takingPayment) =>
          val (_, paid)    = takingPayment.receive()
          val ticketed     = paid.send(Tickets.issue(passengers, flight))
          ticketed.finish()
        case Right(_) => fail("server: unexpected cancel branch in pay test")
    }

    val clientFiber = Future {
      val searching            = clientEnd.send(SearchCriteria("JFK", "LHR", LocalDate.of(2026, 6, 15), 2))
      val (result, reviewing)  = searching.receive()
      assert(result.available)
      val pricing              = reviewing.send(Passengers.unsafeOf(2))
      val (quote, holding)     = pricing.receive()
      val (_, deciding)        = holding.receive()
      val paying               = deciding.selectLeft()
      val ticketing            = paying.send(PaymentFor[2](quote.total, "tok"))
      val (tickets, done)      = ticketing.receive()
      done.finish()
      tickets
    }

    Await.result(serverFiber, Duration.Inf)
    val tickets = Await.result(clientFiber, Duration.Inf)
    assertEquals(tickets.codes.size, 2)

  // ── Cancellation path ──────────────────────────────────────────────────────

  test("cancel path completes and returns confirmation"):
    import demos.BookingProtocol

    val (clientEnd, serverEnd) = Transport.open[BookingProtocol.Refundable[1]]
    val holdId = UUID.randomUUID()

    val serverFiber = Future {
      val (_, searching)        = serverEnd.receive()
      val quoting               = searching.send(SearchResult(true, List(flight)))
      val (passengers, pricing) = quoting.receive()
      val holding               = pricing.send(Quote[1](BigDecimal("450"), passengers.count))
      val offering              = holding.send(HoldConfirmation(holdId, 15))
      offering.awaitChoice() match
        case Right(cancelling) =>
          val cancelled = cancelling.send(CancellationConfirmation(holdId, "Cancelled"))
          cancelled.finish()
        case Left(_) => fail("server: unexpected pay branch in cancel test")
    }

    val clientFiber = Future {
      val searching              = clientEnd.send(SearchCriteria("JFK", "LHR", LocalDate.of(2026, 6, 15), 1))
      val (_, reviewing)         = searching.receive()
      val pricing                = reviewing.send(Passengers.unsafeOf(1))
      val (_, holding)           = pricing.receive()
      val (_, deciding)          = holding.receive()
      val cancelling             = deciding.selectRight()
      val (cancellation, done)   = cancelling.receive()
      done.finish()
      cancellation
    }

    Await.result(serverFiber, Duration.Inf)
    val cancellation = Await.result(clientFiber, Duration.Inf)
    assertEquals(cancellation.holdId, holdId)

  // ── NoAvailability path ────────────────────────────────────────────────────

  test("no-availability path ends cleanly"):
    import demos.BookingProtocol

    val (clientEnd, serverEnd) = Transport.open[BookingProtocol.NoAvailability]

    val serverFiber = Future {
      val (_, searching) = serverEnd.receive()
      val done           = searching.send(SearchResult(false, Nil))
      done.finish()
    }

    val clientFiber = Future {
      val searching      = clientEnd.send(SearchCriteria("JFK", "NRT", LocalDate.now(), 1))
      val (result, done) = searching.receive()
      done.finish()
      result
    }

    Await.result(serverFiber, Duration.Inf)
    val result = Await.result(clientFiber, Duration.Inf)
    assertEquals(result.available, false)
