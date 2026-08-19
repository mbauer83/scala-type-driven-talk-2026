// The error channel of Result<T, E>, as a sum of products — the same shape the
// success side has. A failure is a value you can switch on, not a string you
// have to parse or print.
public sealed interface PaymentError {

    record EmptyOrder()                     implements PaymentError {}
    record NonPositiveQuantity(int got)     implements PaymentError {}
    record NegativeUnitPrice(int cents)     implements PaymentError {}
    record CreditNoteRequired(String captureId) implements PaymentError {}

    /** For logging and demo output only — the switch above is how you HANDLE one. */
    default String describe() {
        return switch (this) {
            case EmptyOrder e            -> "order must have at least one line";
            case NonPositiveQuantity q   -> "quantity must be positive, got " + q.got();
            case NegativeUnitPrice p     -> "unit price cannot be negative, got " + p.cents();
            case CreditNoteRequired c    -> "invoice: credit note required for " + c.captureId();
        };
    }
}
