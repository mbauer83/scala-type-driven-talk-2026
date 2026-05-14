import java.util.List;
public class Order {
    private final String orderId; private final String customerId;
    private final List<OrderLine> lines; private final PaymentMethod paymentMethod;
    private Order(String orderId, String customerId, List<OrderLine> lines, PaymentMethod paymentMethod) {
        this.orderId = orderId; this.customerId = customerId;
        this.lines = List.copyOf(lines); this.paymentMethod = paymentMethod;
    }
    public static Result<Order> of(String orderId, String customerId, List<OrderLine> lines, PaymentMethod pm) {
        if (lines == null || lines.isEmpty()) return Result.err("Order must have at least one line");
        return Result.ok(new Order(orderId, customerId, lines, pm));
    }
    public String getOrderId()       { return orderId; }
    public String getCustomerId()    { return customerId; }
    public List<OrderLine> getLines()         { return lines; }
    public PaymentMethod getPaymentMethod()   { return paymentMethod; }
    public int getTotalCents() { return lines.stream().mapToInt(OrderLine::getTotalCents).sum(); }
    @Override public String toString() {
        return "Order(" + orderId + ", total=" + getTotalCents() + "c, method=" + paymentMethod + ")";
    }
}
