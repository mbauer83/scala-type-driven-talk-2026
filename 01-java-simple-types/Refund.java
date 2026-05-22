public class Refund {
    private final String refundId;
    private final String captureId;
    private final int    refundedAmountCents;

    private Refund(String refundId, String captureId, int refundedAmountCents) {
        this.refundId            = refundId;
        this.captureId           = captureId;
        this.refundedAmountCents = refundedAmountCents;
    }

    static Refund from(Capture cap) {
        return new Refund(
            "ref-" + cap.getCaptureId(),
            cap.getCaptureId(),
            cap.getCapturedAmountCents()
        );
    }

    public String getRefundId()             { return refundId; }
    public String getCaptureId()            { return captureId; }
    public int    getRefundedAmountCents()  { return refundedAmountCents; }

    @Override public String toString() {
        return "Refund(id=" + refundId + ", capture=" + captureId + ", amount=" + refundedAmountCents + "c)";
    }
}
