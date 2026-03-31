package rules

import cats.Functor

// ─── LAYER 3 — Booking Policy DSL (Fix + Higher-Kinded Types) ────────────────
//
// A booking *policy* is a tree of constraints.  Instead of writing a monolithic
// recursive data type, we factor out the recursion using the fixpoint combinator
// Fix[F] and a *base functor* PolicyF[A].
//
// This separation makes it possible to define multiple interpretations (folds)
// over exactly the same structure without ever rewriting the recursion.

/**
 * Base functor for the Policy DSL.
 *
 * A = the type of recursive sub-expressions (will be Fix[PolicyF] when used).
 */
enum PolicyF[+A]:
  /** Booking may be cancelled for a refund. */
  case Refundable(next: A)

  /** No refund permitted once reserved. */
  case NonRefundable(next: A)

  /** Booking requires a minimum stay of `days` nights. */
  case MinStay(days: Int, next: A)

  /** Passengers must present a valid government-issued ID. */
  case RequiresIdentification(next: A)

  /**
   * Both sub-policies must hold simultaneously.
   * Demonstrates HKT tree structure — two recursive positions.
   */
  case Both(left: A, right: A)

  /** No further constraints. */
  case NoConstraint

// ─── Functor instance (cats) ──────────────────────────────────────────────────

given Functor[PolicyF] with
  def map[A, B](fa: PolicyF[A])(f: A => B): PolicyF[B] = fa match
    case PolicyF.Refundable(a)              => PolicyF.Refundable(f(a))
    case PolicyF.NonRefundable(a)           => PolicyF.NonRefundable(f(a))
    case PolicyF.MinStay(days, a)           => PolicyF.MinStay(days, f(a))
    case PolicyF.RequiresIdentification(a)  => PolicyF.RequiresIdentification(f(a))
    case PolicyF.Both(la, ra)               => PolicyF.Both(f(la), f(ra))
    case PolicyF.NoConstraint               => PolicyF.NoConstraint

// ─── Fixpoint combinator ──────────────────────────────────────────────────────

/**
 * Fix[F] is the least fixed point of functor F.
 * A value of type Fix[PolicyF] is a fully recursive policy tree.
 *
 * Construction:   Fix(PolicyF.Refundable(Fix(PolicyF.NoConstraint)))
 * Destruction:    fix.unfix   — one level unwrapped
 */
case class Fix[F[_]](unfix: F[Fix[F]])

/** Convenience alias */
type Policy = Fix[PolicyF]

// ─── Catamorphism (interpret) ─────────────────────────────────────────────────

/**
 * Generic fold over any fixed-point structure.
 *
 * `algebra` collapses one layer of F[A] into an A.
 * `interpret` applies it recursively bottom-up, replacing Fix[F] with A.
 *
 * This is the single recursion primitive.  All interpretations are written
 * as algebras and passed to this function — they never recurse themselves.
 */
def interpret[F[_]: Functor, A](algebra: F[A] => A)(fix: Fix[F]): A =
  algebra(Functor[F].map(fix.unfix)(interpret(algebra)))

// ─── Smart constructors for readable DSL ──────────────────────────────────────

object Policy:
  def refundable(next: Policy): Policy               = Fix(PolicyF.Refundable(next))
  def nonRefundable(next: Policy): Policy            = Fix(PolicyF.NonRefundable(next))
  def minStay(days: Int)(next: Policy): Policy       = Fix(PolicyF.MinStay(days, next))
  def requiresIdentification(next: Policy): Policy   = Fix(PolicyF.RequiresIdentification(next))
  def both(l: Policy, r: Policy): Policy             = Fix(PolicyF.Both(l, r))
  val noConstraint: Policy                           = Fix(PolicyF.NoConstraint)
