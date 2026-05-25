import java.util.List;

public class Order {
    private final String           orderId;
    private final String           customerId;
    private final List<OrderLine>  lines;
    private final PaymentMethod    paymentMethod;

    private Order(String orderId, String customerId, List<OrderLine> lines, PaymentMethod paymentMethod) {
        this.orderId       = orderId;
        this.customerId    = customerId;
        this.lines         = List.copyOf(lines);
        this.paymentMethod = paymentMethod;
    }

    public static Order of(String orderId, String customerId, List<OrderLine> lines, PaymentMethod paymentMethod) {
        if (lines == null || lines.isEmpty())
            throw new IllegalArgumentException("Order must have at least one line");
        return new Order(orderId, customerId, lines, paymentMethod);
    }

    public String           getOrderId()       { return orderId; }
    public String           getCustomerId()    { return customerId; }
    public List<OrderLine>  getLines()         { return lines; }
    public PaymentMethod    getPaymentMethod() { return paymentMethod; }

    public int getTotalCents() {
        return lines.stream().mapToInt(OrderLine::getTotalCents).sum();
    }

    @Override public String toString() {
        return "Order(" + orderId + ", total=" + getTotalCents() + "c, method=" + paymentMethod + ")";
    }
}
