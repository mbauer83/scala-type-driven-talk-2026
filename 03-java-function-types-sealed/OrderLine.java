// Stage 04: OrderLine is now a record — immutable by construction.

public record OrderLine(String sku, int unitPriceCents, int quantity) {

    public OrderLine {
        if (quantity <= 0)
            throw new IllegalArgumentException("Quantity must be positive, got " + quantity);
        if (unitPriceCents < 0)
            throw new IllegalArgumentException("Unit price cannot be negative");
    }

    public int totalCents() { return unitPriceCents * quantity; }

    public static Result<OrderLine, PaymentError> of(String sku, int priceCents, int qty) {
        if (qty <= 0)       return Result.err(new PaymentError.NonPositiveQuantity(qty));
        if (priceCents < 0) return Result.err(new PaymentError.NegativeUnitPrice(priceCents));
        return Result.ok(new OrderLine(sku, priceCents, qty));
    }
}
