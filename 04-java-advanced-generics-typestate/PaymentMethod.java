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
            case Card c -> "card"; case Wallet w -> "wallet"; case Invoice i -> "invoice";
        };
    }
}
