public class Refund {
    private final String refundId; private final String captureId; private final int refundedAmountCents;
    public Refund(String refundId, String captureId, int refundedAmountCents) {
        this.refundId = refundId; this.captureId = captureId; this.refundedAmountCents = refundedAmountCents;
    }
    public String getRefundId()            { return refundId; }
    public String getCaptureId()           { return captureId; }
    public int    getRefundedAmountCents() { return refundedAmountCents; }
    public String toString() { return "Refund(id=" + refundId + ", capture=" + captureId + ", amount=" + refundedAmountCents + "c)"; }
}
