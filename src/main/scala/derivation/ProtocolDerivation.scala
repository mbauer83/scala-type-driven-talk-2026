package derivation

import rules.{Policy, PolicyF, Fix, interpret, Interpretations, given}
import protocol.*

// ─── LAYER 4 (bridge) — Protocol Derivation from Policies ─────────────────────
//
// Policies live at runtime (they come from a database, config, etc.).
// Protocols live at compile time (they are types).
//
// The bridge works like this:
//   1. Fold the Policy tree into a set of Capabilities (runtime values).
//   2. Use those capabilities to select which of several pre-defined
//      protocol *variants* to execute.
//
// This is the maximum we can do in a language without full dependent types:
// the *structure* of the protocol is fixed at compile time (both variants
// are type-checked), and the *choice* of variant is made at runtime.

// ─── Capabilities ─────────────────────────────────────────────────────────────

enum Capability:
  case Cancellable             // booking may be cancelled
  case MinimumStayApplies      // a minimum-stay constraint is in effect
  case IdentificationRequired  // passenger must present government ID

object Capability:
  /** Derive the full capability set from a Policy via a single catamorphism. */
  val deriveFrom: Policy => Set[Capability] =
    interpret[PolicyF, Set[Capability]]:
      case PolicyF.Refundable(caps)             => caps + Capability.Cancellable
      case PolicyF.NonRefundable(caps)          => caps - Capability.Cancellable
      case PolicyF.MinStay(_, caps)             => caps + Capability.MinimumStayApplies
      case PolicyF.RequiresIdentification(caps) => caps + Capability.IdentificationRequired
      case PolicyF.Both(l, r)                   =>
        // Cancellable requires BOTH branches to permit it (conjunction).
        // MinimumStayApplies / IdentificationRequired require EITHER branch to impose it (disjunction).
        val cancellationOk = l.contains(Capability.Cancellable) && r.contains(Capability.Cancellable)
        val rest = (l ++ r) - Capability.Cancellable
        if cancellationOk then rest + Capability.Cancellable else rest
      case PolicyF.NoConstraint                 => Set(Capability.Cancellable)

// ─── Pre-defined protocol shapes ──────────────────────────────────────────────
//
// All shapes are fully type-checked.  Only the selection between them
// happens at runtime.

object ProtocolShapes:
  import domain.*

  /**
   * Full booking protocol for N passengers — search, hold, then pay or cancel.
   *
   *   Client:  Send[SearchCriteria]  → Receive[SearchResult]
   *         → Send[Passengers[N]]   → Receive[Quote[N]]
   *         → Receive[HoldConfirmation]
   *         → Choose[ pay-branch | cancel-branch ]
   *
   * The N parameter propagates through the whole exchange, ensuring the
   * passenger count is consistent from reservation through payment to issuance.
   */
  type RefundableBooking[N <: Int] =
    Send[SearchCriteria,
    Receive[SearchResult,
    Send[Passengers[N],
    Receive[Quote[N],
    Receive[HoldConfirmation,
    Choose[
      // ── Left branch: pay ──────────────────────────────────────────────────
      Send[PaymentFor[N],
      Receive[Tickets[N],
      End]],
      // ── Right branch: cancel ──────────────────────────────────────────────
      Receive[CancellationConfirmation,
      End]
    ]]]]]]

  /** Non-refundable shape: no cancel branch, pay-only. */
  type NonRefundableBooking[N <: Int] =
    Send[SearchCriteria,
    Receive[SearchResult,
    Send[Passengers[N],
    Receive[Quote[N],
    Receive[HoldConfirmation,
    Send[PaymentFor[N],
    Receive[Tickets[N],
    End]]]]]]]

  /** No-availability shape: server immediately says no flights found. */
  type NoAvailabilityBooking =
    Send[SearchCriteria,
    Receive[SearchResult,   // available = false
    End]]

// ─── Runtime protocol selector ────────────────────────────────────────────────

/**
 * A runtime-resolved protocol variant.
 * Sealed so the match is exhaustive and compiler-verified.
 */
sealed trait ProtocolVariant
object ProtocolVariant:
  case object Refundable    extends ProtocolVariant
  case object NonRefundable extends ProtocolVariant

  def selectFrom(caps: Set[Capability]): ProtocolVariant =
    if caps.contains(Capability.Cancellable) then Refundable
    else NonRefundable
