public enum RiskDecision {
    LOW, MEDIUM, HIGH;

    public static RiskDecision max(RiskDecision a, RiskDecision b) {
        return a.ordinal() >= b.ordinal() ? a : b;
    }
}
