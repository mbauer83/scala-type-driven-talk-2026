import java.util.List;
public record Order(String orderId, String customerId, List<OrderLine> lines, PaymentMethod paymentMethod) {
    public Order { if (lines == null || lines.isEmpty()) throw new IllegalArgumentException("Order must have at least one line"); lines = List.copyOf(lines); }
    public static Result<Order> of(String id, String cid, List<OrderLine> lines, PaymentMethod pm) {
        if (lines == null || lines.isEmpty()) return Result.err("Order must have at least one line");
        return Result.ok(new Order(id, cid, lines, pm));
    }
    public int totalCents() { return lines().stream().mapToInt(OrderLine::totalCents).sum(); }
}
