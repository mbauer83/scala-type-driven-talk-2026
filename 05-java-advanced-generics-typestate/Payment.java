import java.util.ArrayList;
import java.util.List;

// Stage 05: Payment<S extends PaymentState> — a phantom-typed payment object.
//
// The state parameter S is a phantom: it carries no runtime data.
// What it does: it restricts which static methods accept which payments.
//
// Legal lifecycle:
//   Payment<Initiated>  = Payment.initiate(order)
//   Payment<Authorized> = Payment.authorizeAuto(initiated)
//                       | Payment.authorize3DS(initiated, proof)
//                       | Payment.authorizeReview(initiated, reviewer)
//   Payment<Captured>   = Payment.capture(authorized)
//   Payment<Refunded>   = Payment.refund(captured)
//
// Attempting payment.capture(initiated) or payment.refund(authorized)
// is now a compile-time type error, not a runtime surprise.

public final class Payment<S extends PaymentState> {

    private final String       orderId;
    private final int          amountCents;
    private final List<String> auditTrail;
    private final String       transactionId;

    private Payment(String orderId, int amountCents, String transactionId, List<String> auditTrail) {
        this.orderId       = orderId;
        this.amountCents   = amountCents;
        this.transactionId = transactionId;
        this.auditTrail    = new ArrayList<>(auditTrail);
    }

    public String       getOrderId()       { return orderId; }
    public int          getAmountCents()   { return amountCents; }
    public String       getTransactionId() { return transactionId; }
    public List<String> getAuditTrail()    { return List.copyOf(auditTrail); }

    // ─── State machine — static factory methods enforce the allowed transitions ───

    /** Entry point: the only way to obtain Payment<Initiated>. */
    public static Payment<PaymentState.Initiated> initiate(Order order) {
        List<String> trail = new ArrayList<>();
        trail.add("initiated:" + order.orderId());
        return new Payment<>(order.orderId(), order.totalCents(), "txn-" + order.orderId(), trail);
    }

    /** Low-risk path: no external challenge needed. */
    public static Payment<PaymentState.Authorized> authorizeAuto(
            Payment<PaymentState.Initiated> payment) {
        List<String> trail = new ArrayList<>(payment.auditTrail);
        trail.add("authorized:auto-approved");
        return new Payment<>(payment.orderId, payment.amountCents,
            "auth-" + payment.orderId, trail);
    }

    /** Medium-risk path: caller must supply a 3DS proof value. */
    public static Payment<PaymentState.Authorized> authorize3DS(
            Payment<PaymentState.Initiated> payment, ThreeDSProof proof) {
        List<String> trail = new ArrayList<>(payment.auditTrail);
        trail.add("authorized:3ds:" + proof.challengeId() + " shift=" + proof.liabilityShift());
        return new Payment<>(payment.orderId, payment.amountCents,
            "auth-" + payment.orderId, trail);
    }

    /** High-risk path: caller must supply a manual review approval. */
    public static Payment<PaymentState.Authorized> authorizeReview(
            Payment<PaymentState.Initiated> payment, ManualReviewApproval approval) {
        List<String> trail = new ArrayList<>(payment.auditTrail);
        trail.add("authorized:manual-review:" + approval.reviewer());
        return new Payment<>(payment.orderId, payment.amountCents,
            "auth-" + payment.orderId, trail);
    }

    /** Capture: ONLY accepts Payment<Authorized>. capture(initiated) = compile error. */
    public static Payment<PaymentState.Captured> capture(
            Payment<PaymentState.Authorized> authorized) {
        List<String> trail = new ArrayList<>(authorized.auditTrail);
        trail.add("captured:" + authorized.amountCents + "c");
        return new Payment<>(authorized.orderId, authorized.amountCents,
            "cap-" + authorized.orderId, trail);
    }

    /** Refund: ONLY accepts Payment<Captured>. refund(authorized) = compile error. */
    public static Result<Payment<PaymentState.Refunded>> refund(
            Payment<PaymentState.Captured> captured, boolean refundPermitted) {
        if (!refundPermitted)
            return Result.err("Refund not permitted for this payment method");
        List<String> trail = new ArrayList<>(captured.auditTrail);
        trail.add("refunded:" + captured.amountCents + "c");
        return Result.ok(new Payment<>(captured.orderId, captured.amountCents,
            "refund-" + captured.orderId, trail));
    }

    @Override public String toString() {
        return "Payment[" + transactionId + ", order=" + orderId
            + ", amount=" + amountCents + "c, audit=" + auditTrail + "]";
    }
}
