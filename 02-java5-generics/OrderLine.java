public class OrderLine {
    private final String sku;
    private final int    unitPriceCents;
    private final int    quantity;

    private OrderLine(String sku, int unitPriceCents, int quantity) {
        this.sku            = sku;
        this.unitPriceCents = unitPriceCents;
        this.quantity       = quantity;
    }

    // Stage 02: smart constructor returns Result<OrderLine>, not OrderLine.
    // Callers must handle the error case explicitly.
    public static Result<OrderLine> of(String sku, int unitPriceCents, int quantity) {
        if (quantity <= 0)
            return Result.err("Quantity must be positive, got " + quantity);
        if (unitPriceCents < 0)
            return Result.err("Unit price cannot be negative");
        return Result.ok(new OrderLine(sku, unitPriceCents, quantity));
    }

    public String getSku()            { return sku; }
    public int    getUnitPriceCents() { return unitPriceCents; }
    public int    getQuantity()       { return quantity; }
    public int    getTotalCents()     { return unitPriceCents * quantity; }

    @Override public String toString() {
        return "OrderLine(" + sku + ", unit=" + unitPriceCents + "c, qty=" + quantity + ", total=" + getTotalCents() + "c)";
    }
}
