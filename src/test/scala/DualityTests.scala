import munit.FunSuite
import protocol.*

/**
 * Duality tests.
 *
 * The summon[] calls in this file are compile-time proofs — if this file
 * compiles, the Dual match type is correct.
 *
 * Runtime tests check that Transport.open produces correctly typed pairs.
 */
class DualityTests extends FunSuite:

  // ── Compile-time proofs (no runtime assertions needed) ─────────────────────

  test("End duals to End"):
    summon[Dual[End] =:= End]

  test("Send duals to Receive"):
    summon[Dual[Send[Int, End]] =:= Receive[Int, End]]

  test("Receive duals to Send"):
    summon[Dual[Receive[String, End]] =:= Send[String, End]]

  test("Nested duality is correct"):
    summon[Dual[Send[Int, Receive[String, End]]] =:= Receive[Int, Send[String, End]]]

  test("Choose duals to Offer"):
    summon[Dual[Choose[End, Send[Int, End]]] =:= Offer[End, Receive[Int, End]]]

  test("Offer duals to Choose"):
    summon[Dual[Offer[End, Receive[Int, End]]] =:= Choose[End, Send[Int, End]]]

  test("Dual is an involution on End"):
    summon[Dual[Dual[End]] =:= End]

  test("Dual is an involution on Send"):
    summon[Dual[Dual[Send[Int, End]]] =:= Send[Int, End]]

  test("Dual is an involution on Receive"):
    summon[Dual[Dual[Receive[Boolean, End]]] =:= Receive[Boolean, End]]

  test("Dual is an involution on Choose"):
    summon[Dual[Dual[Choose[End, Send[Int, End]]]] =:= Choose[End, Send[Int, End]]]

  // ── Runtime: Transport.open produces dual channel pair ────────────────────

  test("Transport.open returns channels of correct dual types"):
    import runtime.Transport
    type P = Send[Int, Receive[String, End]]
    val (clientEnd, serverEnd) = Transport.open[P]
    // If this compiles, the types are correct:
    //   clientEnd : Channel[Send[Int, Receive[String, End]]]
    //   serverEnd : Channel[Receive[Int, Send[String, End]]]  (= Dual[P])
    summon[clientEnd.type <:< runtime.Channel[P]]
    summon[serverEnd.type <:< runtime.Channel[Dual[P]]]
