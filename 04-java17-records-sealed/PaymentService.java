// Stage 04: Sealed types and records.
//
// New gains vs stage 03:
//   - RiskDecision is a sealed interface: missing a case in a switch is a compile error.
//   - Bob's fast-path bug: RiskDecision.Medium cannot silently fall through — the
//     compiler demands you handle it.
//   - Order and OrderLine are records: immutable, no mutable state to corrupt.
//   - PaymentMethod.Invoice and Card/Wallet are distinct types.
//
// What still goes wrong:
//   - Capture before authorize — both are plain classes, any can be passed anywhere.
//   - The medium branch handling the 3DS step is required in code,
//     but not enforced by the type of the RiskDecision.Medium value itself.
//   - Audit trail omission on a branch is still possible.

import java.util.List;

public class PaymentService {

    public static RiskDecision assessRisk(Order order) {
        int total = order.totalCents();
        return switch (order.paymentMethod()) {
            case PaymentMethod.Invoice i -> new RiskDecision.High();
            case PaymentMethod.Wallet  w -> total <= 20000 ? new RiskDecision.Low() : new RiskDecision.Medium();
            case PaymentMethod.Card    c -> {
                if (total <= 15000)      yield new RiskDecision.Low();
                else if (total <= 80000) yield new RiskDecision.Medium();
                else                     yield new RiskDecision.High();
            }
        };
    }

    public static record Authorization(String orderId, String authCode, int authorizedAmountCents, String approvalNote) {}
    public static record Capture(String captureId, String orderId, int capturedAmountCents) {}
    public static record Refund(String refundId, String captureId, int refundedAmountCents) {}

    public static Authorization authorize(Order order, String approvalNote) {
        return new Authorization(order.orderId(), "auth-" + order.orderId(), order.totalCents(), approvalNote);
    }

    public static Capture capture(Authorization auth) {
        return new Capture("cap-" + auth.authCode(), auth.orderId(), auth.authorizedAmountCents());
    }

    public static Result<Refund> refund(Capture cap, PaymentMethod method) {
        return switch (method) {
            case PaymentMethod.Invoice i -> Result.err("Refund not permitted for invoice orders");
            case PaymentMethod.Card    c -> Result.ok(new Refund("ref-" + cap.captureId(), cap.captureId(), cap.capturedAmountCents()));
            case PaymentMethod.Wallet  w -> Result.ok(new Refund("ref-" + cap.captureId(), cap.captureId(), cap.capturedAmountCents()));
        };
    }

    // ─── Exhaustive risk dispatch ─────────────────────────────────────────────
    // Now the compiler requires us to handle all three variants explicitly.
    // You cannot forget Medium without a compile error.

    public static Capture processOrder(Order order, AuditTrail<String> log) {
        RiskDecision risk = assessRisk(order);
        return switch (risk) {

            case RiskDecision.Low l -> {
                Authorization auth = authorize(order, "auto-approved");
                log.append("authorized:" + auth.authCode());
                Capture cap = capture(auth);
                log.append("captured:" + cap.captureId());
                yield cap;
            }

            case RiskDecision.Medium m -> {
                // The compiler forces us to write this branch — but not to do 3DS inside it.
                String challengeId = "3ds-" + order.orderId();
                log.append("3ds-challenged:" + challengeId);
                log.append("3ds-verified:proof-" + challengeId);
                Authorization auth = authorize(order, "3ds:proof-" + challengeId);
                log.append("authorized:" + auth.authCode());
                Capture cap = capture(auth);
                log.append("captured:" + cap.captureId());
                yield cap;
            }

            case RiskDecision.High h -> {
                log.append("manual-review-approved:reviewer:ops-reviewer");
                Authorization auth = authorize(order, "manual-review:ops-reviewer");
                log.append("authorized:" + auth.authCode());
                Capture cap = capture(auth);
                log.append("captured:" + cap.captureId());
                yield cap;
            }
        };
    }
}
