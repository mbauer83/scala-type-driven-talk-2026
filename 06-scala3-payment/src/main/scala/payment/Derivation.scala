package payment

import protocol.*

// ─── Stage 06: Protocol derivation ────────────────────────────────────────────
//
// This is the key difference from Java typestate — and the key ceiling below Idris 2.
//
// WHAT SCALA CAN DO:
//   - Define protocol shapes as compile-time types.
//   - Enforce duality: (Channel[P], Channel[Dual[P]]) — mismatched pairs are compile errors.
//   - Select from a fixed menu of pre-declared protocol variants at runtime.
//   - Enforce that client and server agree on the chosen variant.
//   - Encode approval witnesses indexed by risk (Approval[R]).
//
// WHAT SCALA CANNOT DO (the remaining gap):
//   - Compute the *protocol type* directly from a runtime value.
//     In Idris: `protocolDerivedFrom : Order -> SessionType` returns a SessionType
//     whose TYPE depends on the runtime order value.
//     In Scala: we must pre-declare all variants and select among them at runtime.
//   - The set of possible protocols is open-ended in Idris; in Scala it is a closed enum.
//
// This is the bridge: a closed enum of runtime protocol variants, each fully type-checked.

// ─── Protocol shapes — all defined from the CLIENT's perspective ─────────────
//
// Client sends Order first, then receives results.
// Server gets Channel[Dual[P]], so its operations are the exact inverse.

// Low-risk client: send Order → receive Snapshot → receive Auth → receive Capture → choose[refund | done]
type LowRiskProtocol =
  Send[Order,
  Receive[RiskSnapshot,
  Receive[AuthorizedPayment[LowRisk],
  Receive[CapturedPayment,
  Choose[Receive[RefundedPayment, End], End]]]]]

// Medium-risk client: send Order → receive Snapshot → receive Challenge → send Proof → receive Auth → receive Capture → choose
type MediumRiskProtocol =
  Send[Order,
  Receive[RiskSnapshot,
  Receive[ThreeDSChallenge,
  Send[ThreeDSProof,
  Receive[AuthorizedPayment[MediumRisk],
  Receive[CapturedPayment,
  Choose[Receive[RefundedPayment, End], End]]]]]]]

// High-risk client: send Order → receive Snapshot → receive ReviewRequest → send Approval → receive Auth → receive Capture
type HighRiskProtocol =
  Send[Order,
  Receive[RiskSnapshot,
  Receive[ManualReviewRequest,
  Send[ManualReviewApproval,
  Receive[AuthorizedPayment[HighRisk],
  Receive[CapturedPayment, End]]]]]]

// ─── Runtime protocol variant ─────────────────────────────────────────────────
// The runtime selector. All variants are closed; the compiler verifies each one.

sealed trait ProtocolVariant
object ProtocolVariant:
  case object LowRefund    extends ProtocolVariant
  case object LowNoRefund  extends ProtocolVariant
  case object MediumRefund extends ProtocolVariant
  case object HighNoRefund extends ProtocolVariant

  def fromSnapshot(snapshot: RiskSnapshot): ProtocolVariant =
    (snapshot.level, snapshot.refundPermitted) match
      case ("low",    true)  => LowRefund
      case ("low",    false) => LowNoRefund
      case ("medium", _)     => MediumRefund
      case _                 => HighNoRefund

// ─── Duality proofs (compile-time checks) ─────────────────────────────────────

private object DualityChecks:
  // Server's view of each protocol — computed by the compiler, verified at compile time.
  // If either side's type is wrong this file will not compile.
  summon[Dual[LowRiskProtocol] =:=
    Receive[Order,
    Send[RiskSnapshot,
    Send[AuthorizedPayment[LowRisk],
    Send[CapturedPayment,
    Offer[Send[RefundedPayment, End], End]]]]]]

  summon[Dual[MediumRiskProtocol] =:=
    Receive[Order,
    Send[RiskSnapshot,
    Send[ThreeDSChallenge,
    Receive[ThreeDSProof,
    Send[AuthorizedPayment[MediumRisk],
    Send[CapturedPayment,
    Offer[Send[RefundedPayment, End], End]]]]]]]]

  summon[Dual[HighRiskProtocol] =:=
    Receive[Order,
    Send[RiskSnapshot,
    Send[ManualReviewRequest,
    Receive[ManualReviewApproval,
    Send[AuthorizedPayment[HighRisk],
    Send[CapturedPayment, End]]]]]]]
