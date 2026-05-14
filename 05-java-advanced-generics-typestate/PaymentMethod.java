public sealed interface PaymentMethod permits PaymentMethod.Card, PaymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(String token) implements PaymentMethod {}
    record Wallet(String token) implements PaymentMethod {}
    record Invoice(String reference) implements PaymentMethod {}
    default boolean supportsRefund() {
        return switch (this) {
            case Card c -> true; case Wallet w -> true; case Invoice i -> false;
        };
    }
    default String label() {
        return switch (this) {
            case Card c -> "card"; case Wallet w -> "wallet"; case Invoice i -> "invoice";
        };
    }
}
