// Stage 01: Simple Java types — nominal structure catches shape confusion,
// but process errors and lifecycle violations survive.

public class OrderLine {
    private final String sku;
    private final int    unitPriceCents;
    private final int    quantity;

    public OrderLine(String sku, int unitPriceCents, int quantity) {
        if (quantity <= 0) throw new IllegalArgumentException("Quantity must be positive, got " + quantity);
        this.sku           = sku;
        this.unitPriceCents = unitPriceCents;
        this.quantity      = quantity;
    }

    public String getSku()            { return sku; }
    public int    getUnitPriceCents() { return unitPriceCents; }
    public int    getQuantity()       { return quantity; }
    public int    getTotalCents()     { return unitPriceCents * quantity; }

    @Override public String toString() {
        return "OrderLine(" + sku + ", unit=" + unitPriceCents + "c, qty=" + quantity + ", total=" + getTotalCents() + "c)";
    }
}
