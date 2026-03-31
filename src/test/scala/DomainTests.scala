import munit.FunSuite
import domain.*

class DomainTests extends FunSuite:

  // ── Passengers validation ──────────────────────────────────────────────────

  test("Passengers.of accepts valid count 1"):
    assertEquals(Passengers.of(1), Right(Passengers.unsafeOf(1)))

  test("Passengers.of accepts valid count 9"):
    assertEquals(Passengers.of(9), Right(Passengers.unsafeOf(9)))

  test("Passengers.of rejects 0"):
    assert(Passengers.of(0).isLeft)

  test("Passengers.of rejects 10"):
    assert(Passengers.of(10).isLeft)

  test("Passengers.of rejects negative"):
    assert(Passengers.of(-1).isLeft)

  // ── PaymentFor validation ──────────────────────────────────────────────────

  test("PaymentFor.validate accepts correct amount"):
    val quote:   Quote[2]      = Quote[2](BigDecimal("300.00"), 2)
    val payment: PaymentFor[2] = PaymentFor[2](BigDecimal("600.00"), "tok")
    assertEquals(PaymentFor.validate(payment, quote), Right(payment))

  test("PaymentFor.validate rejects wrong amount"):
    val quote:   Quote[2]      = Quote[2](BigDecimal("300.00"), 2)
    val payment: PaymentFor[2] = PaymentFor[2](BigDecimal("500.00"), "tok")
    assert(PaymentFor.validate(payment, quote).isLeft)

  // ── Tickets.issue ──────────────────────────────────────────────────────────

  test("Tickets.issue generates correct number of codes"):
    import java.time.LocalDate
    val flight     = Flight("LH404", "JFK", "LHR", LocalDate.now(), BigDecimal("450"))
    val passengers = Passengers.unsafeOf(3)
    val tickets    = Tickets.issue(passengers, flight)
    assertEquals(tickets.codes.size, 3)

  test("Tickets.issue codes are prefixed with flight number"):
    import java.time.LocalDate
    val flight     = Flight("BA100", "LHR", "JFK", LocalDate.now(), BigDecimal("400"))
    val passengers = Passengers.unsafeOf(2)
    val tickets    = Tickets.issue(passengers, flight)
    assert(tickets.codes.forall(_.startsWith("BA100")))

  // ── Compile-time: type mismatch between N values is a type error ───────────
  // The following MUST NOT compile (uncommenting it should fail):
  //
  //   val quote:   Quote[2]      = Quote[2](300, 2)
  //   val payment: PaymentFor[3] = PaymentFor[3](600, "tok")
  //   PaymentFor.validate(payment, quote)  // ERROR: found PaymentFor[3], required PaymentFor[2]
  //
  // This is a STATIC guarantee — the compiler enforces passenger-count
  // consistency between quote and payment before the program runs.
