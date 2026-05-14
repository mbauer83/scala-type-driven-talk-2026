import java.util.function.Consumer;
import java.util.function.Function;

// An explicit payment step: transforms a value and appends an audit entry.
// Making steps into values means they can be composed, reused, and tested
// in isolation — but they don't yet enforce any particular execution order.

@FunctionalInterface
public interface PaymentStep<A, B> {

    B execute(A input, AuditTrail<String> log);

    default <C> PaymentStep<A, C> andThen(PaymentStep<B, C> next) {
        return (input, log) -> {
            B intermediate = this.execute(input, log);
            return next.execute(intermediate, log);
        };
    }

    // ─── Named production steps ───────────────────────────────────────────────

    static PaymentStep<Order, Authorization> authorizeStep(String approvalNote) {
        return (order, log) -> {
            Authorization auth = new Authorization(
                order.getOrderId(), "auth-" + order.getOrderId(),
                order.getTotalCents(), approvalNote);
            log.append("authorized:" + auth.getAuthCode());
            return auth;
        };
    }

    static PaymentStep<Authorization, Capture> captureStep() {
        return (auth, log) -> {
            Capture cap = new Capture(
                "cap-" + auth.getAuthCode(), auth.getOrderId(),
                auth.getAuthorizedAmountCents());
            log.append("captured:" + cap.getCaptureId());
            return cap;
        };
    }

    static PaymentStep<Capture, Result<Refund>> refundStep(PaymentMethod method) {
        return (cap, log) -> {
            if (!method.supportsRefund())
                return Result.err("Refund not permitted for " + method);
            Refund r = new Refund("ref-" + cap.getCaptureId(), cap.getCaptureId(), cap.getCapturedAmountCents());
            log.append("refunded:" + r.getRefundId());
            return Result.ok(r);
        };
    }

    static PaymentStep<String, String> threeDSStep() {
        return (challengeId, log) -> {
            String proof = "proof-" + challengeId;
            log.append("3ds-challenged:" + challengeId);
            log.append("3ds-verified:" + proof);
            return proof;
        };
    }

    static PaymentStep<String, String> manualReviewStep() {
        return (reviewer, log) -> {
            log.append("manual-review-approved:reviewer:" + reviewer);
            return reviewer;
        };
    }
}
