package demos

import protocol.*
import runtime.{Transport, Channel, Logger}
import payment.*
import io.github.iltotore.iron.*
import io.github.iltotore.iron.constraint.numeric.*

// ─── Stage 06: Scala 3 payment demo ─────────────────────────────────────────
// Run: sbt run

object PaymentDemo:

  // ─── Fixture orders ─────────────────────────────────────────────────────────

  val lowRiskOrder: Either[String, Order] =
    for
      line  <- OrderLine.of("BOOK-TDD-001", 4500, 1)
      order <- Order.of("ord-low", "cust-01", List(line), PaymentMethod.Card("tok_low"))
    yield order

  val mediumRiskOrder: Either[String, Order] =
    for
      l1    <- OrderLine.of("LAPTOP-15",  12000, 1)
      l2    <- OrderLine.of("MOUSE-PRO",  3500,  2)
      order <- Order.of("ord-medium", "cust-02", List(l1, l2), PaymentMethod.Card("tok_3ds"))
    yield order

  val highRiskOrder: Either[String, Order] =
    for
      line  <- OrderLine.of("B2B-SERVER-RACK", 120000, 1)
      order <- Order.of("ord-high", "cust-03", List(line), PaymentMethod.Invoice("PO-7788"))
    yield order

  // ─── Server handlers ────────────────────────────────────────────────────────
  // Each server handler is typed to the DUAL of the client's protocol.
  // Sending when the protocol says Receive is a compile error.

  def serverLowRisk(ch: Channel[Dual[LowRiskProtocol]]): Unit =
    val (order, ch1)      = ch.receive()
    val snapshot          = riskSnapshotFor(order)
    val ch2               = ch1.send(snapshot)
    val authorized        = authorize(order, AutoApproved)
    val ch3               = ch2.send(authorized)
    val captured          = capture(authorized)
    val ch4               = ch3.send(captured)
    ch4.awaitChoice() match
      case Left(refunding)  => refunding.send(refund(captured).toOption.get).finish()
      case Right(done)      => done.finish()

  def serverMediumRisk(ch: Channel[Dual[MediumRiskProtocol]]): Unit =
    val (order, ch1)      = ch.receive()
    val snapshot          = riskSnapshotFor(order)
    val ch2               = ch1.send(snapshot)
    val challenge         = ThreeDSChallenge(s"3ds-${order.orderId}", "soft")
    val ch3               = ch2.send(challenge)
    val (proof, ch4)      = ch3.receive()
    val authorized        = authorize(order, ThreeDSApproved(proof))
    val ch5               = ch4.send(authorized)
    val captured          = capture(authorized)
    val ch6               = ch5.send(captured)
    ch6.awaitChoice() match
      case Left(refunding)  => refunding.send(refund(captured).toOption.get).finish()
      case Right(done)      => done.finish()

  def serverHighRisk(ch: Channel[Dual[HighRiskProtocol]]): Unit =
    val (order, ch1)      = ch.receive()
    val snapshot          = riskSnapshotFor(order)
    val ch2               = ch1.send(snapshot)
    val reviewReq         = ManualReviewRequest("manual-review", "high-risk order")
    val ch3               = ch2.send(reviewReq)
    val (approval, ch4)   = ch3.receive()
    val authorized        = authorize(order, ReviewerApproved(approval))
    val ch5               = ch4.send(authorized)
    val captured          = capture(authorized)
    ch5.send(captured).finish()

  // ─── Client handlers ────────────────────────────────────────────────────────

  def clientLowRisk(order: Order, refundRequested: Boolean, ch: Channel[LowRiskProtocol]): Unit =
    val snapshot          = riskSnapshotFor(order)
    Logger.info(s"Policy:  ${Interpretations.describe(policyFromOrder(order))}")
    Logger.info(s"Snapshot: $snapshot")
    val ch1               = ch.send(order)
    val (_, ch2)          = ch1.receive()   // RiskSnapshot
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
    val snapshot          = riskSnapshotFor(order)
    Logger.info(s"Policy:  ${Interpretations.describe(policyFromOrder(order))}")
    Logger.info(s"Snapshot: $snapshot")
    val ch1               = ch.send(order)
    val (_, ch2)          = ch1.receive()   // RiskSnapshot
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
    val snapshot          = riskSnapshotFor(order)
    Logger.info(s"Policy:  ${Interpretations.describe(policyFromOrder(order))}")
    Logger.info(s"Snapshot: $snapshot")
    val ch1               = ch.send(order)
    val (_, ch2)          = ch1.receive()   // RiskSnapshot
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
    val t = new Thread(() => serverLowRisk(serverCh)); t.start()
    clientLowRisk(order, refundRequested, clientCh)
    t.join()

  def runMediumRisk(order: Order, refundRequested: Boolean): Unit =
    val (clientCh, serverCh) = Transport.open[MediumRiskProtocol]
    val t = new Thread(() => serverMediumRisk(serverCh)); t.start()
    clientMediumRisk(order, refundRequested, clientCh)
    t.join()

  def runHighRisk(order: Order): Unit =
    val (clientCh, serverCh) = Transport.open[HighRiskProtocol]
    val t = new Thread(() => serverHighRisk(serverCh)); t.start()
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
    Logger.section("DEMO 4 — Boundary Validation: Refined Types vs Runtime Checks")
    Logger.info(s"OrderLine.of qty=0 → ${OrderLine.of("BUGGY", 1000, 0)}")
    Logger.info(s"Order.of empty     → ${Order.of("ord-x", "cust-x", Nil, PaymentMethod.Card("t"))}")
    Logger.info("")
    Logger.info("Iron compile-time literal check:")
    val validQty: PositiveInt = 5.refine[Positive]
    Logger.info(s"  5.refine[Positive] → PositiveInt(${validQty.value})  // checked at COMPILE TIME")
    Logger.info(s"  0.refine[Positive]  ← DOES NOT COMPILE for literal 0 (try it)")
    Logger.info(s"  // 'Assertion failed: 0 should be strictly positive'  — at compile time")
    Logger.info("")
    Logger.info("Java boundary validation: OrderLine(sku, price, 0) compiles, test catches it at runtime.")
    Logger.info("Scala+iron: OrderLine(sku, price, 0) does not compile — no test needed for this class.")
    Logger.outcome("Refined type: predicate lives in the type, checked by the compiler. No runtime test needed.")

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

    Logger.info("── 2. Refined types: PositiveInt = Int :| Positive ──────────────────")
    Logger.info("  BAD:  val qty: PositiveInt = 0.refine[Positive]  // literal 0")
    Logger.info("  ERROR: Assertion failed: 0 should be strictly positive  (compile time)")
    Logger.info("  BAD:  OrderLine(sku, price, rawInt)  // plain Int as PositiveInt")
    Logger.info("  ERROR: Found Int, Required IronType[Int, Positive]")
    Logger.info("  PREVENTS: Alice's bug — a zero-quantity line silently producing a £0 invoice.")
    Logger.info("  Predicate lives in the type; no test needed for this invariant.")
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
