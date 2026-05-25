// ─── Stage 06: Scala 3 — session types, phantom evidence, refined values ─────
// Run: sbt run
//
// ELIMINATED — compiler now proves these; their runtime tests can be deleted:
//
//   ✗ Wrong approval type for the assessed risk level — Bob's residual bug  [was stage 05]
//       Domain.scala:37   sealed trait Approval[+R <: Risk] — phantom-indexed approval
//       Domain.scala:178  authorize[R <: Risk](order, Approval[R]) — R must match
//       AutoApproved (: Approval[LowRisk]) cannot satisfy Approval[MediumRisk]; compile error.
//       removes tests: "wrong approval type should be rejected"
//
//   ✗ Client/server protocol drift — Danielle's bug  [was stage 05]
//       Derivation.scala:31   LowRiskProtocol, MediumRiskProtocol, HighRiskProtocol
//       Chan.scala            Channel[P] — send/receive constrained by protocol position
//       Sending the wrong message type or in the wrong order is a compile error.
//       removes tests: "protocol messages in correct order"
//
//   ✗ Client and server disagreeing on the protocol shape  [was stage 05]
//       Derivation.scala:79   summon[Dual[LowRiskProtocol]    =:= ...]
//       Derivation.scala:86   summon[Dual[MediumRiskProtocol] =:= ...]
//       Derivation.scala:95   summon[Dual[HighRiskProtocol]   =:= ...]
//       These proofs are checked at every build; a mismatched server does not compile.
//       removes tests: "client and server agree on protocol"
//
//   ✗ Empty identifier silently grouping records under a single key  [was stage 05]
//       Domain.scala      type NonEmptyString = String :| MinLength[1]
//       Domain.scala      OrderId.of / CustomerId.of refine via refineEither
//       The literal "" cannot be lifted into OrderId / CustomerId; a runtime
//       empty string is rejected at the boundary, not deep in the lifecycle.
//       removes tests: "empty identifier rejected"
//
//   ✗ Closing a channel before the protocol is complete  [was stage 05]
//       Chan.scala        finish() requires implicit proof that P =:= End
//       Calling finish() mid-conversation is a compile error.
//
// CODE REMOVED — type-level machinery replaces defensive duplication:
//
//   - Three separate approval-type checks → one authorize[R <: Risk] signature (Domain.scala:178)
//   - Protocol consistency assertions     → one Dual match type (Dual.scala) applied to all variants
//   - Repeated policy interpretations     → one interpret[F[_], A] catamorphism (Rules.scala:41)
//
// REMAINING GAPS — still compilable here (closed by stage 07):
//
//   ✗ Runtime risk value cannot directly compute the protocol type  [closed at stage 07]
//       Derivation.scala:60  sealed trait ProtocolVariant — a closed enum bridges runtime→type
//       The compiler cannot derive LowRiskProtocol vs MediumRiskProtocol from a runtime Order.
//       In Idris 2: protocolDerivedFrom : Order -> SessionType computes the type directly.
//       The bridge (ProtocolVariant ADT) is the ceiling Scala cannot remove.
//
// ─────────────────────────────────────────────────────────────────────────────

package demos

import protocol.*
import runtime.{Transport, Channel, Logger}
import payment.*
import io.github.iltotore.iron.*
import io.github.iltotore.iron.constraint.collection.*

// ─── Stage 06: Scala 3 payment demo ─────────────────────────────────────────
// Run: sbt run

object PaymentDemo:

  // ─── Fixture orders ─────────────────────────────────────────────────────────

  val lowRiskOrder: Either[String, Order] =
    Order.of(
      "ord-low", "cust-01",
      List(OrderLine.of("BOOK-TDD-001", 4500, 1)),
      PaymentMethod.Card("tok_low"),
    )

  val mediumRiskOrder: Either[String, Order] =
    Order.of(
      "ord-medium", "cust-02",
      List(
        OrderLine.of("LAPTOP-15", 12000, 1),
        OrderLine.of("MOUSE-PRO",  3500, 2),
      ),
      PaymentMethod.Card("tok_3ds"),
    )

  val highRiskOrder: Either[String, Order] =
    Order.of(
      "ord-high", "cust-03",
      List(OrderLine.of("B2B-SERVER-RACK", 120000, 1)),
      PaymentMethod.Invoice("PO-7788"),
    )

  // ─── Server handlers ────────────────────────────────────────────────────────
  // Each server handler is typed to the DUAL of the client's protocol.
  // Sending when the protocol says Receive is a compile error.

  // Honest limitation: Scala 3 lacks linear types.
  // The type system prevents wrong-order sends and wrong message types.
  // It does NOT enforce that finish() must be called — a dropped channel is
  // not a compile error. Handlers return Channel[End] (not Unit) to signal
  // intent and centralise finish() naturally, but "must use exactly once" is
  // not enforced here. Full linear enforcement requires Idris 2's UniqueType
  // or Haskell's %1 -> syntax. This is an honest ceiling of this encoding.
  def serverLowRisk(ch: Channel[Dual[LowRiskProtocol]]): Channel[End] =
    val (order, ch1)      = ch.receive()
    val snapshot          = riskSnapshotFor(order)
    val ch2               = ch1.send(snapshot)
    val authorized        = authorize(order, AutoApproved)
    val ch3               = ch2.send(authorized)
    val captured          = capture(authorized)
    val ch4               = ch3.send(captured)
    ch4.awaitChoice() match
      case Left(refunding)  => refunding.send(refund(captured).toOption.get)
      case Right(done)      => done

  def serverMediumRisk(ch: Channel[Dual[MediumRiskProtocol]]): Channel[End] =
    val (order, ch1)      = ch.receive()
    val snapshot          = riskSnapshotFor(order)
    val ch2               = ch1.send(snapshot)
    val challenge         = ThreeDSChallenge(s"3ds-${order.orderId.orderIdStr}", "soft")
    val ch3               = ch2.send(challenge)
    val (proof, ch4)      = ch3.receive()
    val authorized        = authorize(order, ThreeDSApproved(proof))
    val ch5               = ch4.send(authorized)
    val captured          = capture(authorized)
    val ch6               = ch5.send(captured)
    ch6.awaitChoice() match
      case Left(refunding)  => refunding.send(refund(captured).toOption.get)
      case Right(done)      => done

  def serverHighRisk(ch: Channel[Dual[HighRiskProtocol]]): Channel[End] =
    val (order, ch1)      = ch.receive()
    val snapshot          = riskSnapshotFor(order)
    val ch2               = ch1.send(snapshot)
    val reviewReq         = ManualReviewRequest("manual-review", "high-risk order")
    val ch3               = ch2.send(reviewReq)
    val (approval, ch4)   = ch3.receive()
    val authorized        = authorize(order, ReviewerApproved(approval))
    val ch5               = ch4.send(authorized)
    val captured          = capture(authorized)
    ch5.send(captured)

  // ─── Client handlers ────────────────────────────────────────────────────────

  def clientLowRisk(order: Order, refundRequested: Boolean, ch: Channel[LowRiskProtocol]): Unit =
    Logger.info(s"Policy:  ${Interpretations.describe(policyFromOrder(order))}")
    val ch1               = ch.send(order)
    val (snapshot, ch2)   = ch1.receive()   // RiskSnapshot from server
    Logger.info(s"Snapshot: $snapshot")
    val (auth, ch3)       = ch2.receive()   // AuthorizedPayment[LowRisk]
    Logger.info(s"Auth: $auth")
    val (cap, ch4)        = ch3.receive()   // CapturedPayment
    Logger.info(s"Cap:  $cap")
    if refundRequested then
      val ch5 = ch4.selectLeft()
      val (refunded, done) = ch5.receive()
      Logger.info(s"Refunded: $refunded")
      done.finish()
    else
      ch4.selectRight().finish()

  def clientMediumRisk(order: Order, refundRequested: Boolean, ch: Channel[MediumRiskProtocol]): Unit =
    Logger.info(s"Policy:  ${Interpretations.describe(policyFromOrder(order))}")
    val ch1               = ch.send(order)
    val (snapshot, ch2)   = ch1.receive()   // RiskSnapshot from server
    Logger.info(s"Snapshot: $snapshot")
    val (challenge, ch3)  = ch2.receive()   // ThreeDSChallenge
    Logger.info(s"Challenge received: $challenge")
    val proof             = ThreeDSProof(challenge.challengeId, liabilityShift = true)
    val ch4               = ch3.send(proof)
    val (auth, ch5)       = ch4.receive()   // AuthorizedPayment[MediumRisk]
    Logger.info(s"Auth: $auth")
    val (cap, ch6)        = ch5.receive()   // CapturedPayment
    Logger.info(s"Cap:  $cap")
    if refundRequested then
      val ch7 = ch6.selectLeft()
      val (refunded, done) = ch7.receive()
      Logger.info(s"Refunded: $refunded")
      done.finish()
    else
      ch6.selectRight().finish()

  def clientHighRisk(order: Order, ch: Channel[HighRiskProtocol]): Unit =
    Logger.info(s"Policy:  ${Interpretations.describe(policyFromOrder(order))}")
    val ch1               = ch.send(order)
    val (snapshot, ch2)   = ch1.receive()   // RiskSnapshot from server
    Logger.info(s"Snapshot: $snapshot")
    val (reviewReq, ch3)  = ch2.receive()   // ManualReviewRequest
    Logger.info(s"Manual review request: $reviewReq")
    val reviewApproval    = ManualReviewApproval("ops-reviewer", "KYC and invoice matched")
    val ch4               = ch3.send(reviewApproval)
    val (auth, ch5)       = ch4.receive()   // AuthorizedPayment[HighRisk]
    Logger.info(s"Auth: $auth")
    val (cap, done)       = ch5.receive()   // CapturedPayment
    Logger.info(s"Cap:  $cap")
    done.finish()

  // ─── Scenario runner ─────────────────────────────────────────────────────────

  def runLowRisk(order: Order, refundRequested: Boolean): Unit =
    val (clientCh, serverCh) = Transport.open[LowRiskProtocol]
    val t = new Thread(() => serverLowRisk(serverCh).finish()); t.start()
    clientLowRisk(order, refundRequested, clientCh)
    t.join()

  def runMediumRisk(order: Order, refundRequested: Boolean): Unit =
    val (clientCh, serverCh) = Transport.open[MediumRiskProtocol]
    val t = new Thread(() => serverMediumRisk(serverCh).finish()); t.start()
    clientMediumRisk(order, refundRequested, clientCh)
    t.join()

  def runHighRisk(order: Order): Unit =
    val (clientCh, serverCh) = Transport.open[HighRiskProtocol]
    val t = new Thread(() => serverHighRisk(serverCh).finish()); t.start()
    clientHighRisk(order, clientCh)
    t.join()

  // ─── Demos ──────────────────────────────────────────────────────────────────

  def demo1(): Unit =
    Logger.section("DEMO 1 — Low-Risk Card Payment (Approval[LowRisk] required)")
    lowRiskOrder match
      case Left(err)    => Logger.info(s"Order failed: $err")
      case Right(order) =>
        Logger.info(s"Order total: ${order.totalCents}c")
        runLowRisk(order, refundRequested = false)
        Logger.outcome("Low-risk: Approval[LowRisk] enforces AutoApproved; protocol is compile-checked.")

  def demo2(): Unit =
    Logger.section("DEMO 2 — Medium-Risk Card Payment With 3DS (Approval[MediumRisk] required)")
    mediumRiskOrder match
      case Left(err)    => Logger.info(s"Order failed: $err")
      case Right(order) =>
        Logger.info(s"Order total: ${order.totalCents}c")
        runMediumRisk(order, refundRequested = true)
        Logger.outcome("Medium-risk: ThreeDSApproved(proof) required; AutoApproved is a compile error here.")

  def demo3(): Unit =
    Logger.section("DEMO 3 — High-Risk Invoice With Manual Review (Approval[HighRisk] required)")
    highRiskOrder match
      case Left(err)    => Logger.info(s"Order failed: $err")
      case Right(order) =>
        Logger.info(s"Order total: ${order.totalCents}c")
        runHighRisk(order)
        Logger.outcome("High-risk: ReviewerApproved required; invoice has no refund branch in protocol.")

  def demo4(): Unit =
    Logger.section("DEMO 4 — Boundary Refinement: NonEmptyString-Refined Identifiers")
    Logger.info(s"Order.of empty orderId    → ${Order.of("", "cust-x", List(OrderLine.of("X", 1000, 1)), PaymentMethod.Card("t"))}")
    Logger.info(s"Order.of empty customerId → ${Order.of("ord-x", "", List(OrderLine.of("X", 1000, 1)), PaymentMethod.Card("t"))}")
    Logger.info(s"Order.of empty lines      → ${Order.of("ord-x", "cust-x", Nil, PaymentMethod.Card("t"))}")
    Logger.info("")
    Logger.info("Iron compile-time literal check:")
    val validId: NonEmptyString = "ord-001".refineUnsafe[MinLength[1]]
    Logger.info(s"  \"ord-001\".refineUnsafe[MinLength[1]] → NonEmptyString(${validId.value})  // OK at COMPILE TIME")
    Logger.info(s"  \"\".refineUnsafe[MinLength[1]]        ← DOES NOT COMPILE for literal \"\" (try it)")
    Logger.info(s"  // 'Assertion failed: Should have a min length of 1' — at compile time")
    Logger.info("")
    Logger.info("Java boundary validation: an empty orderId may slip through; rejected only at the DB layer.")
    Logger.info("Scala+iron: OrderId.of(\"\") returns Left at the entry boundary; downstream code never sees it.")
    Logger.outcome("Refined type: the non-empty predicate lives in the type. Empty IDs are rejected at the boundary.")

  def demo5(): Unit =
    Logger.section("DEMO 5 — Policy DSL: Same Tree, Multiple Interpretations")
    for order <- lowRiskOrder do
      val policy = policyFromOrder(order)
      Logger.info(s"Low-risk  policy: ${Interpretations.describe(policy)}")
      Logger.info(s"Low-risk  analysis: ${Interpretations.analyze(policy)}")
    for order <- mediumRiskOrder do
      val policy = policyFromOrder(order)
      Logger.info(s"Medium-risk policy: ${Interpretations.describe(policy)}")
      Logger.info(s"Medium-risk analysis: ${Interpretations.analyze(policy)}")
    for order <- highRiskOrder do
      val policy = policyFromOrder(order)
      Logger.info(s"High-risk policy: ${Interpretations.describe(policy)}")
      Logger.info(s"High-risk analysis: ${Interpretations.analyze(policy)}")
    Logger.outcome("One Policy tree → human description, analysis, protocol selection. No repeated recursion.")

  def demo6_Ceiling(): Unit =
    Logger.section("DEMO 6 — The Scala Ceiling: Runtime-to-Type Bridge")
    Logger.info("In Scala, protocol variants are pre-declared at compile time:")
    Logger.info("  type LowRiskProtocol    = Receive[Order, Send[RiskSnapshot, ...]]")
    Logger.info("  type MediumRiskProtocol = Receive[Order, Send[RiskSnapshot, Send[ThreeDSChallenge, ...]]]")
    Logger.info("  type HighRiskProtocol   = Receive[Order, Send[RiskSnapshot, Send[ManualReviewRequest, ...]]]")
    Logger.info("")
    Logger.info("Selection happens at runtime: risk result → pick from the fixed menu.")
    Logger.info("")
    Logger.info("In Idris 2:")
    Logger.info("  protocolDerivedFrom : Order -> SessionType")
    Logger.info("  The protocol TYPE is computed from the runtime order value directly.")
    Logger.info("  No pre-declared menu is needed. The type system checks the result.")
    Logger.info("")
    Logger.info("Scala's remaining bridge: ProtocolVariant is a closed ADT that stands in")
    Logger.info("  for what Idris can express as a dependent function type.")
    Logger.outcome("The ceiling is visible. Idris 2 removes it by letting types depend on values.")

  def demo7_Scala3Features(): Unit =
    Logger.section("DEMO 7 — What Each Feature Prevents")
    Logger.info("Format: [feature] → [bad code] → [compiler error] → [bug class eliminated]")
    Logger.info("")

    Logger.info("── 1. Phantom type indexing: Approval[R <: Risk] ────────────────────")
    Logger.info("  BAD:  authorize(mediumRiskOrder, AutoApproved)")
    Logger.info("  ERROR: Found Approval[LowRisk], Required Approval[MediumRisk]")
    Logger.info("  PREVENTS: Bob's bug — auto-approving a medium-risk order, skipping 3DS.")
    Logger.info("  The approval constructor IS the 3DS proof. Skipping it is unrepresentable.")
    Logger.info("")

    Logger.info("── 2. Refined types: NonEmptyString = String :| MinLength[1] ────────")
    Logger.info("  BAD:  val id: NonEmptyString = \"\".refineUnsafe[MinLength[1]]  // literal \"\"")
    Logger.info("  ERROR: Assertion failed: Should have a min length of 1  (compile time)")
    Logger.info("  BAD:  val oid: OrderId = rawString  // plain String as OrderId")
    Logger.info("  ERROR: Found String, Required OrderId  (refinement + opacity)")
    Logger.info("  PREVENTS: an empty orderId slipping past the boundary and silently grouping")
    Logger.info("  all empty-ID records under a single key downstream. The predicate lives in the")
    Logger.info("  type; no defensive test on every consumer is needed.")
    Logger.info("")

    Logger.info("── 3. Path-dependent types: CanSend[P]#Msg ──────────────────────────")
    Logger.info("  BAD:  ch.send(\"not an Order\")  // on Channel[Send[Order, ...]]")
    Logger.info("  ERROR: Found String, Required CanSend[Send[Order,...]].Msg (= Order)")
    Logger.info("  BAD:  ch.send(someOrder)       // on Channel[Receive[Order, ...]]")
    Logger.info("  ERROR: No given instance of CanSend[Receive[Order, ...]]")
    Logger.info("  PREVENTS: sending the wrong payload or sending on a receive-step channel.")
    Logger.info("  The message type is derived from the protocol — not a parameter you can get wrong.")
    Logger.info("")

    Logger.info("── 4. Compiler-derived evidence: =:= and finish() ───────────────────")
    Logger.info("  BAD:  ch.finish()  // while ch: Channel[Send[RiskSnapshot, End]]")
    Logger.info("  ERROR: Cannot prove that Send[RiskSnapshot, End] =:= End")
    Logger.info("  PREVENTS: closing a channel mid-conversation — protocol truncation.")
    Logger.info("  The compiler constructs the proof; there is no runtime guard to forget.")
    Logger.info("")
    Logger.info("  AS A TEST: summon[Dual[LowRiskProtocol] =:= Receive[Order, ...]]")
    Logger.info("  This compiles or it does not. No test method, no test runner needed.")
    Logger.info("  Client/server contract is a proof obligation discharged at every build.")
    Logger.info("")

    Logger.info("── 5. Match types + duality: Dual[P] ────────────────────────────────")
    Logger.info("  BAD:  def badServer(ch: Channel[Dual[LowRiskProtocol]]): Unit =")
    Logger.info("          ch.send(someOrder)   // wrong: Dual says receive first")
    Logger.info("  ERROR: No given instance of CanSend[Receive[Order, ...]]")
    Logger.info("  PREVENTS: Danielle's bug — server and client drift out of sync.")
    Logger.info("  Dual[P] is computed by the compiler; a mismatched server does not compile.")
    Logger.info("  Duality is one application of match types — the mechanism is general.")
    Logger.info("")

    Logger.info("── 6. Opaque types: AuthCode, CaptureId, RefundId ───────────────────")
    Logger.info("  opaque type AuthCode = String; opaque type CaptureId = String")
    Logger.info("  BAD:  val id: CaptureId = someAuthCode  // both String underneath")
    Logger.info("  ERROR: Found AuthCode, Required CaptureId")
    Logger.info("  PREVENTS: lifecycle identifier confusion — no audit ID in a capture field.")
    Logger.info("  Zero runtime cost. The compiler enforces the distinction.")
    Logger.info("")

    Logger.info("── 7. Higher-kinded types: interpret[F[_]: Functor, A] ───────────────")
    Logger.info("  def interpret[F[_]: Functor, A](algebra: F[A] => A)(fix: Fix[F]): A")
    Logger.info("  One Policy tree. describe and analyze use the same catamorphism.")
    for order <- lowRiskOrder do
      val policy = policyFromOrder(order)
      Logger.info(s"  describe → ${Interpretations.describe(policy)}")
      Logger.info(s"  analyze  → ${Interpretations.analyze(policy)}")
    Logger.info("  PREVENTS: divergent duplicate traversals — two functions that should agree")
    Logger.info("  but drift apart. One fold; the compiler verifies both interpretations fit.")

    Logger.outcome(
      "Seven features. Each one eliminates a class of invalid construction or test."
    )

  def main(args: Array[String]): Unit =
    demo1()
    demo2()
    demo3()
    demo4()
    demo5()
    demo6_Ceiling()
    demo7_Scala3Features()
