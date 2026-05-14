// Stage 04: RiskDecision as a sealed interface — each variant is now a distinct type.
// Exhaustive switch over RiskDecision.Low | Medium | High:
//   - forgetting Medium means a compile error, not a silent default.
//   - Bob's bug of treating MEDIUM like LOW requires writing it explicitly.
//
// What still goes wrong: the compiler forces you to handle Medium,
// but it cannot force the Medium branch to do 3DS before authorizing.

public sealed interface RiskDecision permits RiskDecision.Low, RiskDecision.Medium, RiskDecision.High {

    record Low()    implements RiskDecision {}
    record Medium() implements RiskDecision {}
    record High()   implements RiskDecision {}

    default String label() {
        return switch (this) {
            case Low    l -> "low";
            case Medium m -> "medium";
            case High   h -> "high";
        };
    }

    static RiskDecision max(RiskDecision a, RiskDecision b) {
        // Low < Medium < High
        int ai = switch (a) { case Low l -> 0; case Medium m -> 1; case High h -> 2; };
        int bi = switch (b) { case Low l -> 0; case Medium m -> 1; case High h -> 2; };
        return ai >= bi ? a : b;
    }
}
