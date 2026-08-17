// Stage 04: RefundMechanism — the settlement process as a sealed type.
//
// Refund availability is about settlement process, not risk level:
//   Card / Wallet → InstantReversal: the charge is reversed directly.
//   Invoice       → CreditNoteRequired: a credit-note is issued in accounts receivable.
//
// As a sealed type, every switch on RefundMechanism must handle both cases.
// Contrast with the boolean supportsRefund() at earlier stages:
//   if (!method.supportsRefund()) ...   ← one branch might be forgotten
//   switch (method.refundMechanism()) { ... } ← compiler enforces both cases
//
// This is ∨-elimination: to use the sum type, you must handle every variant.

public sealed interface RefundMechanism permits RefundMechanism.InstantReversal, RefundMechanism.CreditNoteRequired {
    record InstantReversal() implements RefundMechanism {}
    record CreditNoteRequired() implements RefundMechanism {}
}
