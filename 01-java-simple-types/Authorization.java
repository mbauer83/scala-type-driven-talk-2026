public class Authorization {
    private final String orderId;
    private final String authCode;
    private final int    authorizedAmountCents;
    private final String approvalNote;

    private Authorization(String orderId, String authCode, int authorizedAmountCents, String approvalNote) {
        this.orderId               = orderId;
        this.authCode              = authCode;
        this.authorizedAmountCents = authorizedAmountCents;
        this.approvalNote          = approvalNote;
    }

    static Authorization from(Order order, String approvalNote) {
        return new Authorization(
            order.getOrderId(),
            "auth-" + order.getOrderId(),
            order.getTotalCents(),
            approvalNote
        );
    }

    public String getOrderId()               { return orderId; }
    public String getAuthCode()              { return authCode; }
    public int    getAuthorizedAmountCents() { return authorizedAmountCents; }
    public String getApprovalNote()          { return approvalNote; }

    @Override public String toString() {
        return "Authorization(order=" + orderId + ", auth=" + authCode
            + ", amount=" + authorizedAmountCents + "c, note=" + approvalNote + ")";
    }
}
