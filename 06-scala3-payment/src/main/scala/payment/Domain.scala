package payment

import io.github.iltotore.iron.*
import io.github.iltotore.iron.constraint.numeric.*

// ─── Stage 06: Scala 3 payment domain ────────────────────────────────────────
//
// Key additions over the Java typestate stage:
//   - Risk phantom types: LowRisk, MediumRisk, HighRisk as sealed traits.
//   - Approval[R <: Risk] indexed by the phantom risk type.
//   - authorize() requires Approval[R] where R matches the assessed risk.
//   - Refined type: PositiveInt = Int :| Positive (predicate lives in the type).
//   - Opaque nominal IDs: AuthCode, CaptureId, RefundId (structural identity).
//   - Typestate: Authorized, Captured, Refunded are separate types.
//   - Smart constructors return Either[String, T], forcing error handling.
//
// Ceiling that remains (what Idris 2 removes):
//   - The protocol selected for a session is chosen at runtime from a fixed menu.
//   - Computing a protocol TYPE from a runtime risk value requires dependent types.

// ─── Risk phantom types ───────────────────────────────────────────────────────

sealed trait Risk
sealed trait LowRisk    extends Risk
sealed trait MediumRisk extends Risk
sealed trait HighRisk   extends Risk

// ─── Approval — evidence indexed by risk level ────────────────────────────────
//
// Approval[LowRisk]    can only be constructed as AutoApproved.
// Approval[MediumRisk] requires a ThreeDSProof.
// Approval[HighRisk]   requires a ManualReviewApproval.
//
// authorize() is parameterized by R: it requires an Approval[R].
// The compiler ensures you cannot pass AutoApproved to a high-risk authorization.

sealed trait Approval[+R <: Risk]

case object AutoApproved extends Approval[LowRisk]

final case class ThreeDSProof(challengeId: String, liabilityShift: Boolean)
final case class ThreeDSApproved(proof: ThreeDSProof) extends Approval[MediumRisk]

final case class ManualReviewApproval(reviewer: String, note: String)
final case class ReviewerApproved(approval: ManualReviewApproval) extends Approval[HighRisk]

// ─── Refined value type ───────────────────────────────────────────────────────
//
// PositiveInt is a REFINED type: the predicate `Positive` (n > 0) is part of
// the type itself, not just enforced at construction time.
// `Int :| Positive` is `IronType[Int, Positive]` — an opaque type that carries
// the constraint. The compiler distinguishes it from plain Int.
//
// Note: iron's IronType.value extension doesn't resolve with Scala 3.8.3;
// we provide our own. IronType[A, C] is defined as `= A` in iron, so the
// cast is always safe — this is iron's own zero-cost guarantee.

type PositiveInt = Int :| Positive
extension (p: PositiveInt) inline def value: Int = p.asInstanceOf[Int]

// ─── Opaque nominal ID types ──────────────────────────────────────────────────
//
// Opaque types are about structural identity, not value constraints.
// AuthCode, CaptureId, and RefundId are all Strings underneath, but the
// compiler treats them as distinct types — you cannot accidentally pass a
// CaptureId where an AuthCode is expected, even though both are String.
// Zero boxing cost at runtime.

opaque type AuthCode  = String
opaque type CaptureId = String
opaque type RefundId  = String

object AuthCode:
  def of(s: String): AuthCode = s

object CaptureId:
  def of(s: String): CaptureId = s

object RefundId:
  def of(s: String): RefundId = s

extension (c: AuthCode)  def authCodeStr: String  = c
extension (c: CaptureId) def captureIdStr: String = c
extension (r: RefundId)  def refundIdStr: String  = r

// ─── Domain types ─────────────────────────────────────────────────────────────

sealed trait PaymentMethod:
  def supportsRefund: Boolean = this match
    case PaymentMethod.Invoice(_) => false
    case _                        => true
  def label: String = this match
    case PaymentMethod.Card(t)    => s"card($t)"
    case PaymentMethod.Wallet(t)  => s"wallet($t)"
    case PaymentMethod.Invoice(r) => s"invoice($r)"

object PaymentMethod:
  final case class Card(token: String)        extends PaymentMethod
  final case class Wallet(token: String)      extends PaymentMethod
  final case class Invoice(reference: String) extends PaymentMethod

final case class OrderLine(sku: String, unitPriceCents: Int, quantity: PositiveInt):
  def totalCents: Int = unitPriceCents * quantity.value

object OrderLine:
  def of(sku: String, unitPriceCents: Int, quantity: Int): Either[String, OrderLine] =
    quantity
      .refineEither[Positive]
      .map(q => OrderLine(sku, unitPriceCents, q))
      .left.map(_ => s"quantity must be positive, got $quantity")

final case class Order private (
  orderId:       String,
  customerId:    String,
  lines:         List[OrderLine],
  paymentMethod: PaymentMethod,
):
  def totalCents: Int = lines.map(_.totalCents).sum

object Order:
  def of(
    orderId: String, customerId: String,
    lines: List[OrderLine], paymentMethod: PaymentMethod,
  ): Either[String, Order] =
    if lines.isEmpty then Left("Order must have at least one line")
    else Right(Order(orderId, customerId, lines, paymentMethod))

// ─── Risk assessment ──────────────────────────────────────────────────────────

final case class RiskSnapshot(
  level:                String,
  requires3DS:          Boolean,
  requiresManualReview: Boolean,
  refundPermitted:      Boolean,
  captureWindowHours:   Int,
):
  override def toString: String =
    s"RiskSnapshot(level=$level, 3ds=$requires3DS, manual=$requiresManualReview, refund=$refundPermitted, window=${captureWindowHours}h)"

final case class ThreeDSChallenge(challengeId: String, amountBand: String):
  override def toString: String = s"ThreeDSChallenge($challengeId, band=$amountBand)"

final case class ManualReviewRequest(queue: String, reason: String):
  override def toString: String = s"ManualReviewRequest(queue=$queue, reason=$reason)"

// ─── Typestate payment objects ────────────────────────────────────────────────
//
// Separate types (not just phantom parameters) for each lifecycle stage.
// The opaque nominal IDs prevent mixing up authCode with captureId at compile time.

final case class AuthorizedPayment[R <: Risk](
  order:      Order,
  authCode:   AuthCode,
  approval:   Approval[R],
  auditTrail: List[String],
):
  override def toString: String =
    s"AuthorizedPayment(order=${order.orderId}, auth=${authCode.authCodeStr}, trail=$auditTrail)"

final case class CapturedPayment(
  order:      Order,
  captureId:  CaptureId,
  auditTrail: List[String],
):
  override def toString: String =
    s"CapturedPayment(order=${order.orderId}, cap=${captureId.captureIdStr}, trail=$auditTrail)"

final case class RefundedPayment(
  order:      Order,
  refundId:   RefundId,
  auditTrail: List[String],
):
  override def toString: String =
    s"RefundedPayment(order=${order.orderId}, refund=${refundId.refundIdStr}, trail=$auditTrail)"

// ─── Typed lifecycle transitions ──────────────────────────────────────────────

def authorize[R <: Risk](order: Order, approval: Approval[R]): AuthorizedPayment[R] =
  val note = approval match
    case AutoApproved        => "auto-approved"
    case ThreeDSApproved(p)  => s"3ds:${p.challengeId} shift=${p.liabilityShift}"
    case ReviewerApproved(a) => s"manual-review:${a.reviewer}"
  AuthorizedPayment(
    order      = order,
    authCode   = AuthCode.of(s"auth-${order.orderId}"),
    approval   = approval,
    auditTrail = List(s"initiated:${order.orderId}", s"authorized:$note"),
  )

def capture(auth: AuthorizedPayment[?]): CapturedPayment =
  CapturedPayment(
    order      = auth.order,
    captureId  = CaptureId.of(s"cap-${auth.order.orderId}"),
    auditTrail = auth.auditTrail :+ s"captured:${auth.order.totalCents}c",
  )

def refund(cap: CapturedPayment): Either[String, RefundedPayment] =
  if !cap.order.paymentMethod.supportsRefund then
    Left(s"Refund not permitted for ${cap.order.paymentMethod.label}")
  else
    Right(RefundedPayment(
      order      = cap.order,
      refundId   = RefundId.of(s"refund-${cap.order.orderId}"),
      auditTrail = cap.auditTrail :+ s"refunded:${cap.order.totalCents}c",
    ))
