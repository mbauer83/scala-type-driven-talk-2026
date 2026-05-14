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
            order.getOrderId(),
            "auth-" + order.getOrderId(),
            order.getTotalCents(),
            approvalNote
        );
    }

    public static Capture capture(Authorization auth) {
        return new Capture(
            "cap-" + auth.getAuthCode(),
            auth.getOrderId(),
            auth.getAuthorizedAmountCents()
        );
    }

    public static Refund refund(Capture cap) {
        return new Refund(
            "ref-" + cap.getCaptureId(),
            cap.getCaptureId(),
            cap.getCapturedAmountCents()
        );
    }

    // ─── Full flow helpers ────────────────────────────────────────────────────
    // These encode the correct protocol, but nothing forces the caller to use them.

    public static Capture processLowRisk(Order order, List<AuditEntry> log) {
        Authorization auth = authorize(order, "auto-approved");
        AuditEntry.append(log, "authorized", auth.getAuthCode());
        Capture cap = capture(auth);
        AuditEntry.append(log, "captured", cap.getCaptureId());
        return cap;
    }

    public static Capture processMediumRisk(Order order, String challengeId, String proofId, List<AuditEntry> log) {
        AuditEntry.append(log, "3ds-challenged",  challengeId);
        AuditEntry.append(log, "3ds-verified",    proofId);
        Authorization auth = authorize(order, "3ds:" + proofId);
        AuditEntry.append(log, "authorized", auth.getAuthCode());
        Capture cap = capture(auth);
        AuditEntry.append(log, "captured", cap.getCaptureId());
        return cap;
    }

    public static Capture processHighRisk(Order order, String reviewer, List<AuditEntry> log) {
        AuditEntry.append(log, "manual-review-requested", "queue:high-risk");
        AuditEntry.append(log, "manual-review-approved",  "reviewer:" + reviewer);
        Authorization auth = authorize(order, "manual-review:" + reviewer);
        AuditEntry.append(log, "authorized", auth.getAuthCode());
        Capture cap = capture(auth);
        AuditEntry.append(log, "captured", cap.getCaptureId());
        return cap;
    }
}
