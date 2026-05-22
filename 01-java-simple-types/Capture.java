public class Capture {
    private final String captureId;
    private final String orderId;
    private final int    capturedAmountCents;

    private Capture(String captureId, String orderId, int capturedAmountCents) {
        this.captureId           = captureId;
        this.orderId             = orderId;
        this.capturedAmountCents = capturedAmountCents;
    }

    static Capture from(Authorization auth) {
        return new Capture(
            "cap-" + auth.getAuthCode(),
            auth.getOrderId(),
            auth.getAuthorizedAmountCents()
        );
    }

    public String getCaptureId()           { return captureId; }
    public String getOrderId()             { return orderId; }
    public int    getCapturedAmountCents() { return capturedAmountCents; }

    @Override public String toString() {
        return "Capture(id=" + captureId + ", order=" + orderId + ", amount=" + capturedAmountCents + "c)";
    }
}
