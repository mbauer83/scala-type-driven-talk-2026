package rules

import cats.Functor

/**
 * LAYER 3 — Multiple interpretations of the Policy DSL
 *
 * Every interpretation below is a pure algebra  PolicyF[A] => A  passed to
 * `interpret`.  None of them contains any recursion — that is handled once, in
 * `interpret`.  This is the concrete pay-off of Fix + HKT:
 *
 *   • Add a new interpretation → add one `interpret` call, no recursion to write.
 *   • Change the structure     → update PolicyF + Functor, algebras follow.
 *   • Compose interpretations  → product fold, no extra traversal.
 */
object Interpretations:

  // ── 1. Human-readable description ──────────────────────────────────────────

  val describe: Policy => String =
    interpret[PolicyF, String]:
      case PolicyF.Refundable(next)             => s"[Refundable] → $next"
      case PolicyF.NonRefundable(next)          => s"[Non-refundable] → $next"
      case PolicyF.MinStay(days, next)          => s"[Min stay: ${days}d] → $next"
      case PolicyF.RequiresIdentification(next) => s"[Requires identification] → $next"
      case PolicyF.Both(l, r)                   => s"($l  AND  $r)"
      case PolicyF.NoConstraint                 => "✓"

  // ── 2. Can the booking be cancelled? ───────────────────────────────────────

  val permitsCancellation: Policy => Boolean =
    interpret[PolicyF, Boolean]:
      case PolicyF.Refundable(_)             => true
      case PolicyF.NonRefundable(_)          => false
      case PolicyF.MinStay(_, next)          => next   // min-stay doesn't affect refund
      case PolicyF.RequiresIdentification(next) => next
      case PolicyF.Both(l, r)               => l && r // both sub-policies must allow it
      case PolicyF.NoConstraint             => true   // no restriction

  // ── 3. Minimum required stay in nights ─────────────────────────────────────

  val minimumNights: Policy => Int =
    interpret[PolicyF, Int]:
      case PolicyF.Refundable(next)             => next
      case PolicyF.NonRefundable(next)          => next
      case PolicyF.MinStay(days, _)             => days  // this node defines the constraint
      case PolicyF.RequiresIdentification(next) => next
      case PolicyF.Both(l, r)                   => math.max(l, r) // stricter of the two
      case PolicyF.NoConstraint                 => 0

  // ── 4. Requires identity document? ─────────────────────────────────────────

  val requiresIdentification: Policy => Boolean =
    interpret[PolicyF, Boolean]:
      case PolicyF.Refundable(next)             => next
      case PolicyF.NonRefundable(next)          => next
      case PolicyF.MinStay(_, next)             => next
      case PolicyF.RequiresIdentification(_)    => true
      case PolicyF.Both(l, r)                   => l || r
      case PolicyF.NoConstraint                 => false

  // ── 5. COMBINED analysis — single traversal, product result ────────────────
  //
  // We fold into (cancellationPermitted, minimumNights, identificationRequired)
  // in one pass.  No recursion is written three times; the structure is visited once.

  case class Analysis(
    cancellationPermitted: Boolean,
    minimumNights:         Int,
    identificationRequired: Boolean,
  ):
    override def toString =
      s"cancellationPermitted=$cancellationPermitted" +
      s"  minimumNights=${minimumNights}d" +
      s"  identificationRequired=$identificationRequired"

  val analyze: Policy => Analysis =
    interpret[PolicyF, Analysis]:
      case PolicyF.Refundable(a)             => a.copy(cancellationPermitted = true)
      case PolicyF.NonRefundable(a)          => a.copy(cancellationPermitted = false)
      case PolicyF.MinStay(days, a)          => a.copy(minimumNights = days)
      case PolicyF.RequiresIdentification(a) => a.copy(identificationRequired = true)
      case PolicyF.Both(l, r)               =>
        Analysis(
          cancellationPermitted  = l.cancellationPermitted && r.cancellationPermitted,
          minimumNights          = math.max(l.minimumNights, r.minimumNights),
          identificationRequired = l.identificationRequired || r.identificationRequired,
        )
      case PolicyF.NoConstraint =>
        Analysis(cancellationPermitted = true, minimumNights = 0, identificationRequired = false)
