public class RiskService {

    public static RiskDecision assess(Order order) {
        int total = order.totalCents();
        return switch (order.paymentMethod()) {
            case PaymentMethod.Invoice i -> new RiskDecision.High();
            case PaymentMethod.Wallet  w -> total <= 20000 ? new RiskDecision.Low() : new RiskDecision.Medium();
            case PaymentMethod.Card    c -> {
                if (total <= 15000)      yield new RiskDecision.Low();
                else if (total <= 80000) yield new RiskDecision.Medium();
                else                     yield new RiskDecision.High();
            }
        };
    }
}
