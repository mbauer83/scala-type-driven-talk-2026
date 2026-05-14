package payment

// ─── Stage 06: Payment Policy DSL ────────────────────────────────────────────
//
// The policy is a recursive data structure (a free algebra / fixpoint).
// Multiple interpretations are defined as algebras and folded over the same tree.
// The same fixed-point/HKT pattern, now applied directly to the payment domain.

// ─── Base functor ─────────────────────────────────────────────────────────────

enum PolicyF[+A]:
  case AllowRefund(next: A)
  case Require3DS(next: A)
  case RequireManualReview(next: A)
  case CaptureWithinHours(hours: Int, next: A)
  case AppendAudit(next: A)
  case Both(left: A, right: A)
  case Done

// ─── Minimal Functor typeclass (no external dependencies) ─────────────────────

trait Functor[F[_]]:
  def map[A, B](fa: F[A])(f: A => B): F[B]

given Functor[PolicyF] with
  def map[A, B](fa: PolicyF[A])(f: A => B): PolicyF[B] = fa match
    case PolicyF.AllowRefund(a)          => PolicyF.AllowRefund(f(a))
    case PolicyF.Require3DS(a)           => PolicyF.Require3DS(f(a))
    case PolicyF.RequireManualReview(a)  => PolicyF.RequireManualReview(f(a))
    case PolicyF.CaptureWithinHours(h,a) => PolicyF.CaptureWithinHours(h, f(a))
    case PolicyF.AppendAudit(a)          => PolicyF.AppendAudit(f(a))
    case PolicyF.Both(l, r)              => PolicyF.Both(f(l), f(r))
    case PolicyF.Done                    => PolicyF.Done

// ─── Fixpoint combinator ──────────────────────────────────────────────────────

case class Fix[F[_]](unfix: F[Fix[F]])

type Policy = Fix[PolicyF]

def interpret[F[_]: Functor, A](algebra: F[A] => A)(fix: Fix[F]): A =
  algebra(summon[Functor[F]].map(fix.unfix)(interpret(algebra)))

// ─── Smart constructors ───────────────────────────────────────────────────────

object Policy:
  def allowRefund(next: Policy): Policy         = Fix(PolicyF.AllowRefund(next))
  def require3DS(next: Policy): Policy          = Fix(PolicyF.Require3DS(next))
  def requireManualReview(next: Policy): Policy = Fix(PolicyF.RequireManualReview(next))
  def captureWithin(hours: Int)(next: Policy): Policy = Fix(PolicyF.CaptureWithinHours(hours, next))
  def appendAudit(next: Policy): Policy         = Fix(PolicyF.AppendAudit(next))
  def both(l: Policy, r: Policy): Policy        = Fix(PolicyF.Both(l, r))
  val done: Policy                              = Fix(PolicyF.Done)

// ─── Interpretations ──────────────────────────────────────────────────────────

object Interpretations:

  val describe: Policy => String =
    interpret[PolicyF, String]:
      case PolicyF.AllowRefund(n)         => s"[Refundable] → $n"
      case PolicyF.Require3DS(n)          => s"[Require3DS] → $n"
      case PolicyF.RequireManualReview(n) => s"[RequireManualReview] → $n"
      case PolicyF.CaptureWithinHours(h,n)=> s"[CaptureWithin ${h}h] → $n"
      case PolicyF.AppendAudit(n)         => s"[AppendAudit] → $n"
      case PolicyF.Both(l, r)             => s"($l AND $r)"
      case PolicyF.Done                   => "done"

  final case class Analysis(
    refundPermitted:      Boolean = false,
    requires3DS:          Boolean = false,
    requiresManualReview: Boolean = false,
    captureWindowHours:   Int     = 72,
    auditRequired:        Boolean = false,
  ):
    override def toString: String =
      s"Analysis(refund=$refundPermitted, 3ds=$requires3DS, manual=$requiresManualReview, window=${captureWindowHours}h, audit=$auditRequired)"

  val analyze: Policy => Analysis =
    interpret[PolicyF, Analysis]:
      case PolicyF.AllowRefund(a)          => a.copy(refundPermitted = true)
      case PolicyF.Require3DS(a)           => a.copy(requires3DS = true)
      case PolicyF.RequireManualReview(a)  => a.copy(requiresManualReview = true)
      case PolicyF.CaptureWithinHours(h,a) => a.copy(captureWindowHours = h)
      case PolicyF.AppendAudit(a)          => a.copy(auditRequired = true)
      case PolicyF.Both(l, r)              =>
        Analysis(
          refundPermitted      = l.refundPermitted && r.refundPermitted,
          requires3DS          = l.requires3DS || r.requires3DS,
          requiresManualReview = l.requiresManualReview || r.requiresManualReview,
          captureWindowHours   = math.min(l.captureWindowHours, r.captureWindowHours),
          auditRequired        = l.auditRequired || r.auditRequired,
        )
      case PolicyF.Done => Analysis()

// ─── Order → Policy derivation ────────────────────────────────────────────────

def policyFromOrder(order: Order): Policy =
  import Policy.*
  val captureHours = assessRiskLevel(order) match
    case "low"    => 24
    case "medium" => 12
    case _        => 2
  val base = appendAudit(captureWithin(captureHours)(done))
  val withRefund = if order.paymentMethod.supportsRefund then allowRefund(base) else base
  assessRiskLevel(order) match
    case "low"    => withRefund
    case "medium" => require3DS(withRefund)
    case _        => both(requireManualReview(withRefund), require3DS(withRefund))

private def assessRiskLevel(order: Order): String =
  val total = order.totalCents
  order.paymentMethod match
    case PaymentMethod.Invoice(_) => "high"
    case PaymentMethod.Wallet(_)  => if total <= 20000 then "low" else "medium"
    case PaymentMethod.Card(_)    =>
      if total <= 15000 then "low"
      else if total <= 80000 then "medium"
      else "high"

def riskSnapshotFor(order: Order): RiskSnapshot =
  val analysis = Interpretations.analyze(policyFromOrder(order))
  RiskSnapshot(
    level                = if analysis.requiresManualReview then "high"
                           else if analysis.requires3DS then "medium"
                           else "low",
    requires3DS          = analysis.requires3DS,
    requiresManualReview = analysis.requiresManualReview,
    refundPermitted      = analysis.refundPermitted,
    captureWindowHours   = analysis.captureWindowHours,
  )
