public record OrderLine(String sku, int unitPriceCents, int quantity) {
    public OrderLine { if (quantity <= 0) throw new IllegalArgumentException("Quantity must be positive"); }
    public int totalCents() { return unitPriceCents * quantity; }
    public static Result<OrderLine, PaymentError> of(String sku, int priceCents, int qty) {
        if (qty <= 0) return Result.err(new PaymentError.NonPositiveQuantity(qty));
        return Result.ok(new OrderLine(sku, priceCents, qty));
    }
}
