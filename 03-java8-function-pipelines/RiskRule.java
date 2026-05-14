import java.util.function.Function;
import java.util.function.Predicate;

// Stage 03: Function values — risk rules are now explicit values that can be
// named, composed, tested individually, and documented.
// The logic is still evaluated at runtime; the type system has no knowledge of
// which rules apply to which protocol steps.

@FunctionalInterface
public interface RiskRule {

    RiskDecision apply(Order order);

    // Compose: use the higher-risk result when two rules disagree.
    default RiskRule maxWith(RiskRule other) {
        return order -> {
            RiskDecision a = this.apply(order);
            RiskDecision b = other.apply(order);
            return RiskDecision.max(a, b);
        };
    }

    // Named production rules
    static RiskRule invoiceAlwaysHigh() {
        return order -> order.getPaymentMethod() == PaymentMethod.INVOICE
            ? RiskDecision.HIGH : RiskDecision.LOW;
    }

    static RiskRule cardAmountThreshold() {
        return order -> {
            if (order.getPaymentMethod() != PaymentMethod.CARD) return RiskDecision.LOW;
            int total = order.getTotalCents();
            if (total <= 15000) return RiskDecision.LOW;
            if (total <= 80000) return RiskDecision.MEDIUM;
            return RiskDecision.HIGH;
        };
    }

    static RiskRule walletAmountThreshold() {
        return order -> {
            if (order.getPaymentMethod() != PaymentMethod.WALLET) return RiskDecision.LOW;
            return order.getTotalCents() <= 20000 ? RiskDecision.LOW : RiskDecision.MEDIUM;
        };
    }

    // The composed production rule
    static RiskRule productionRiskEngine() {
        return invoiceAlwaysHigh()
            .maxWith(cardAmountThreshold())
            .maxWith(walletAmountThreshold());
    }
}
