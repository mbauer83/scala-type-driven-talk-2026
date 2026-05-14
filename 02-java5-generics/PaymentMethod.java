public enum PaymentMethod {
    CARD, WALLET, INVOICE;
    public boolean supportsRefund() { return this != INVOICE; }
}
