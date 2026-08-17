// Stage 04: OrderLine is now a record — immutable by construction.

public record OrderLine(String sku, int unitPriceCents, int quantity) {

    public OrderLine {
        if (quantity <= 0)
            throw new IllegalArgumentException("Quantity must be positive, got " + quantity);
        if (unitPriceCents < 0)
            throw new IllegalArgumentException("Unit price cannot be negative");
    }

    public int totalCents() { return unitPriceCents * quantity; }

    public static Result<OrderLine> of(String sku, int priceCents, int qty) {
        if (qty <= 0)       return Result.err("Quantity must be positive, got " + qty);
        if (priceCents < 0) return Result.err("Unit price cannot be negative");
        return Result.ok(new OrderLine(sku, priceCents, qty));
    }
}
