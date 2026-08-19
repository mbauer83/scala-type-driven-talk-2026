import java.util.List;

public record Order(String orderId, String customerId, List<OrderLine> lines, PaymentMethod paymentMethod) {

    public Order {
        if (lines == null || lines.isEmpty())
            throw new IllegalArgumentException("Order must have at least one line");
        lines = List.copyOf(lines);
    }

    public static Result<Order, PaymentError> of(String orderId, String customerId, List<OrderLine> lines, PaymentMethod pm) {
        if (lines == null || lines.isEmpty())
            return Result.err(new PaymentError.EmptyOrder());
        return Result.ok(new Order(orderId, customerId, lines, pm));
    }

    public int totalCents() {
        return lines().stream().mapToInt(OrderLine::totalCents).sum();
    }
}
