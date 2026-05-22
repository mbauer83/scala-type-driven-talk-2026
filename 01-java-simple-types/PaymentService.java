import java.util.List;

// ─── Stage 01: Simple Java service ───────────────────────────────────────────
//
// What this stage fixes vs JavaScript:
//   - Passing an Order where an Authorization is expected is now a *type error*.
//   - Wrong field names are caught at compile time.
//   - Argument order swaps on domain types are caught.
//
// What still goes wrong here:
//   - authorize() can be called *after* capture — nothing prevents it.
//   - medium-risk orders can silently skip 3DS if the caller forgets to branch.
//   - refund() can be called on a capture from an invoice order.
//   - The audit log can be forgotten on any branch.
//   - The wrong amount can be captured if the caller uses the wrong value.

// Java 1–4 style: raw List without type parameter — no generics in this stage.
@SuppressWarnings({"rawtypes", "unchecked"})
public class PaymentService {

    public static RiskDecision assessRisk(Order order) {
        int total = order.getTotalCents();
        switch (order.getPaymentMethod()) {
            case INVOICE:
                return RiskDecision.HIGH;
            case WALLET:
                return total <= 20000 ? RiskDecision.LOW : RiskDecision.MEDIUM;
            case CARD:
                if (total <= 15000)      return RiskDecision.LOW;
                else if (total <= 80000) return RiskDecision.MEDIUM;
                else                     return RiskDecision.HIGH;
            default:
                throw new IllegalStateException("Unknown payment method: " + order.getPaymentMethod());
        }
    }

    public static Authorization authorize(Order order, String approvalNote) {
        return Authorization.from(order, approvalNote);
    }

    public static Capture capture(Authorization auth) {
        return Capture.from(auth);
    }

    public static Refund refund(Capture cap) {
        return Refund.from(cap);
    }

    // ─── Full flow helpers ────────────────────────────────────────────────────
    // These encode the correct protocol, but nothing forces the caller to use them.

    public static Capture processLowRisk(Order order, List log) {
        Authorization auth = authorize(order, "auto-approved");
        AuditEntry.append(log, "authorized", auth.getAuthCode());
        Capture cap = capture(auth);
        AuditEntry.append(log, "captured", cap.getCaptureId());
        return cap;
    }

    public static Capture processMediumRisk(Order order, String challengeId, String proofId, List log) {
        AuditEntry.append(log, "3ds-challenged",  challengeId);
        AuditEntry.append(log, "3ds-verified",    proofId);
        Authorization auth = authorize(order, "3ds:" + proofId);
        AuditEntry.append(log, "authorized", auth.getAuthCode());
        Capture cap = capture(auth);
        AuditEntry.append(log, "captured", cap.getCaptureId());
        return cap;
    }

    public static Capture processHighRisk(Order order, String reviewer, List log) {
        AuditEntry.append(log, "manual-review-requested", "queue:high-risk");
        AuditEntry.append(log, "manual-review-approved",  "reviewer:" + reviewer);
        Authorization auth = authorize(order, "manual-review:" + reviewer);
        AuditEntry.append(log, "authorized", auth.getAuthCode());
        Capture cap = capture(auth);
        AuditEntry.append(log, "captured", cap.getCaptureId());
        return cap;
    }
}
