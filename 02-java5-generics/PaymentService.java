// Stage 02: Generics in the service layer.
//
// New gains:
//   - Result<T> forces callers to handle validation errors.
//   - Generic AuditTrail<E> removes raw-type usage.
//   - Validator<T> is composable and reusable.
//
// What still goes wrong:
//   - Lifecycle ordering (capture before auth) — no type-level constraint.
//   - Medium-risk order can skip 3DS.
//   - Refund on invoice path is still possible.
//   - Audit trail is mutable and can be forgotten on any branch.

public class PaymentService {

    public static RiskDecision assessRisk(Order order) {
        int total = order.getTotalCents();
        return switch (order.getPaymentMethod()) {
            case INVOICE -> RiskDecision.HIGH;
            case WALLET  -> total <= 20000 ? RiskDecision.LOW : RiskDecision.MEDIUM;
            case CARD    -> {
                if (total <= 15000)      yield RiskDecision.LOW;
                else if (total <= 80000) yield RiskDecision.MEDIUM;
                else                     yield RiskDecision.HIGH;
            }
        };
    }

    public static Authorization authorize(Order order, String approvalNote) {
        return new Authorization(
            order.getOrderId(), "auth-" + order.getOrderId(),
            order.getTotalCents(), approvalNote);
    }

    public static Capture capture(Authorization auth) {
        return new Capture(
            "cap-" + auth.getAuthCode(), auth.getOrderId(),
            auth.getAuthorizedAmountCents());
    }

    public static Result<Refund> refund(Capture cap, Order order) {
        if (!order.getPaymentMethod().supportsRefund())
            return Result.err("Refund not permitted for " + order.getPaymentMethod());
        return Result.ok(new Refund(
            "ref-" + cap.getCaptureId(), cap.getCaptureId(),
            cap.getCapturedAmountCents()));
    }

    // Generic validation helpers using Validator<T>

    static final Validator<Integer> positiveQuantity =
        Validator.check(q -> q > 0, "Quantity must be positive");

    static Result<OrderLine> validateOrderLine(String sku, int priceCents, int qty) {
        return positiveQuantity.validate(qty)
            .flatMap(q -> OrderLine.of(sku, priceCents, q));
    }
}
