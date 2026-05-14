public sealed interface RiskDecision permits RiskDecision.Low, RiskDecision.Medium, RiskDecision.High {
    record Low()    implements RiskDecision {}
    record Medium() implements RiskDecision {}
    record High()   implements RiskDecision {}
    default String label() {
        return switch (this) { case Low l -> "low"; case Medium m -> "medium"; case High h -> "high"; };
    }
}
