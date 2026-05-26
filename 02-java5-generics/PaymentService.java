// Stage 02: Generics in the service layer.
//
// New gains over Stage 01:
//   - Generic AuditTrail<E> — typed event log, not raw List or String concatenation.
//   - Generic Validator<T> — composable validation; write once, reuse for any domain type.
//   - Typed collections: List<OrderLine> not raw List — wrong element type is a compile error.
//
// What still goes wrong (closed by later stages):
//   - Lifecycle ordering (capture before auth) — no type-level constraint [closed at 05].
//   - Medium-risk can skip 3DS — no exhaustive dispatch required [closed at 04].
//   - Refund on invoice is a runtime boolean check, not a type distinction [closed at 04].

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
        return Authorization.from(order, approvalNote);
    }

    public static Capture capture(Authorization auth) {
        return new Capture(
            "cap-" + auth.getAuthCode(), auth.getOrderId(),
            auth.getAuthorizedAmountCents());
    }

    // Returns the refund on success; throws if the payment method does not support refunds.
    // Gap: refundability is a runtime boolean check on PaymentMethod.supportsRefund().
    // Stage 04 fixes this with a sealed RefundMechanism type that makes it a compile-time distinction.
    public static Refund refund(Capture cap, Order order) {
        if (!order.getPaymentMethod().supportsRefund())
            throw new IllegalArgumentException("Refund not permitted for " + order.getPaymentMethod());
        return new Refund(
            "ref-" + cap.getCaptureId(), cap.getCaptureId(),
            cap.getCapturedAmountCents());
    }

    public static Capture processLowRisk(Order order, AuditTrail<String> log) {
        Authorization auth = authorize(order, "auto-approved");
        log.append("authorized:" + auth.getAuthCode());
        Capture cap = capture(auth);
        log.append("captured:" + cap.getCaptureId());
        return cap;
    }

    public static Capture processMediumRisk(Order order, String challengeId, String proofId, AuditTrail<String> log) {
        log.append("3ds-challenged:" + challengeId);
        log.append("3ds-verified:" + proofId);
        Authorization auth = authorize(order, "3ds:" + proofId);
        log.append("authorized:" + auth.getAuthCode());
        Capture cap = capture(auth);
        log.append("captured:" + cap.getCaptureId());
        return cap;
    }

    public static Capture processHighRisk(Order order, String reviewer, AuditTrail<String> log) {
        log.append("manual-review-approved:" + reviewer);
        Authorization auth = authorize(order, "manual-review:" + reviewer);
        log.append("authorized:" + auth.getAuthCode());
        Capture cap = capture(auth);
        log.append("captured:" + cap.getCaptureId());
        return cap;
    }

    // Reusable Validator<T> instances — one generic interface, composed for any domain type.
    static final Validator<Integer> positiveQuantity =
        Validator.check(q -> q > 0, "Quantity must be positive");

    static final Validator<Integer> nonZeroQuantity =
        Validator.check(q -> q != 0, "Quantity must not be zero");

    static final Validator<Integer> strictPositiveQuantity =
        positiveQuantity.andThen(nonZeroQuantity);
}
