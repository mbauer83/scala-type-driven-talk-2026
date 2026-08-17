// Stage 04: Sealed interface — PaymentMethod is now an honest sum type.
// The compiler enforces exhaustive handling in switch expressions.
// No "default" clause can silently swallow an unexpected variant.

public sealed interface PaymentMethod permits PaymentMethod.Card, PaymentMethod.Wallet, PaymentMethod.Invoice {

    record Card(String token) implements PaymentMethod {}
    record Wallet(String token) implements PaymentMethod {}
    record Invoice(String reference) implements PaymentMethod {}

    default RefundMechanism refundMechanism() {
        return switch (this) {
            case Card    c -> new RefundMechanism.InstantReversal();
            case Wallet  w -> new RefundMechanism.InstantReversal();
            case Invoice i -> new RefundMechanism.CreditNoteRequired();
        };
    }

    default String label() {
        return switch (this) {
            case Card    c -> "card(" + c.token() + ")";
            case Wallet  w -> "wallet(" + w.token() + ")";
            case Invoice i -> "invoice(" + i.reference() + ")";
        };
    }
}
