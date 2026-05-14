public class OrderLine {
    private final String sku; private final int unitPriceCents; private final int quantity;
    private OrderLine(String sku, int unitPriceCents, int quantity) {
        this.sku = sku; this.unitPriceCents = unitPriceCents; this.quantity = quantity;
    }
    public static Result<OrderLine> of(String sku, int priceCents, int qty) {
        if (qty <= 0) return Result.err("Quantity must be positive, got " + qty);
        return Result.ok(new OrderLine(sku, priceCents, qty));
    }
    public String getSku()            { return sku; }
    public int    getUnitPriceCents() { return unitPriceCents; }
    public int    getQuantity()       { return quantity; }
    public int    getTotalCents()     { return unitPriceCents * quantity; }
    @Override public String toString() {
        return "OrderLine(" + sku + ", unit=" + unitPriceCents + "c, qty=" + quantity + ", total=" + getTotalCents() + "c)";
    }
}
