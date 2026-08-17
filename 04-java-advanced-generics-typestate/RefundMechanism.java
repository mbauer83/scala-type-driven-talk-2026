// Stage 05: RefundMechanism — settlement process as a sealed type.
// Same as Stage 04: refundability is about payment METHOD settlement, not risk level.
// Card/Wallet → InstantReversal; Invoice → CreditNoteRequired (credit-note accounting).

public sealed interface RefundMechanism permits RefundMechanism.InstantReversal, RefundMechanism.CreditNoteRequired {
    record InstantReversal() implements RefundMechanism {}
    record CreditNoteRequired() implements RefundMechanism {}
}
