public record OrderLine(String sku, int unitPriceCents, int quantity) {
    public OrderLine { if (quantity <= 0) throw new IllegalArgumentException("Quantity must be positive"); }
    public int totalCents() { return unitPriceCents * quantity; }
    public static Result<OrderLine> of(String sku, int priceCents, int qty) {
        if (qty <= 0) return Result.err("Quantity must be positive, got " + qty);
        return Result.ok(new OrderLine(sku, priceCents, qty));
    }
}
