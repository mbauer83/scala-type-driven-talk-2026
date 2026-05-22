import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

// Java 1–4 style: raw List without type parameter — no generics in this stage.
@SuppressWarnings({"rawtypes", "unchecked"})
public class Order {
    private final String        orderId;
    private final String        customerId;
    private final List          lines;
    private final PaymentMethod paymentMethod;

    public Order(String orderId, String customerId, List lines, PaymentMethod paymentMethod) {
        if (lines == null || lines.isEmpty())
            throw new IllegalArgumentException("Order must have at least one line");
        this.orderId       = orderId;
        this.customerId    = customerId;
        this.lines         = Collections.unmodifiableList(new ArrayList(lines));
        this.paymentMethod = paymentMethod;
    }

    public String              getOrderId()       { return orderId; }
    public String              getCustomerId()    { return customerId; }
    public List                getLines()         { return lines; }
    public PaymentMethod       getPaymentMethod() { return paymentMethod; }

    public int getTotalCents() {
        int total = 0;
        for (Object line : lines)
            total += ((OrderLine) line).getTotalCents();
        return total;
    }

    @Override public String toString() {
        return "Order(" + orderId + ", total=" + getTotalCents() + "c, method=" + paymentMethod + ")";
    }
}
