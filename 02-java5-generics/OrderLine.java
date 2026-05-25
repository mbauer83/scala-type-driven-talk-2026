public class OrderLine {
    private final String sku;
    private final int    unitPriceCents;
    private final int    quantity;

    private OrderLine(String sku, int unitPriceCents, int quantity) {
        this.sku            = sku;
        this.unitPriceCents = unitPriceCents;
        this.quantity       = quantity;
    }

    public static OrderLine of(String sku, int unitPriceCents, int quantity) {
        if (quantity <= 0)
            throw new IllegalArgumentException("Quantity must be positive, got " + quantity);
        if (unitPriceCents < 0)
            throw new IllegalArgumentException("Unit price cannot be negative, got " + unitPriceCents);
        return new OrderLine(sku, unitPriceCents, quantity);
    }

    public String getSku()            { return sku; }
    public int    getUnitPriceCents() { return unitPriceCents; }
    public int    getQuantity()       { return quantity; }
    public int    getTotalCents()     { return unitPriceCents * quantity; }

    @Override public String toString() {
        return "OrderLine(" + sku + ", unit=" + unitPriceCents + "c, qty=" + quantity + ", total=" + getTotalCents() + "c)";
    }
}
