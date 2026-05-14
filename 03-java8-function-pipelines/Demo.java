// Stage 03: Function pipeline demo
// Compile and run: javac *.java && java Demo

import java.util.List;

public class Demo {

    static Result<Order> lowRiskCardOrder() {
        return OrderLine.of("BOOK-TDD-001", 4500, 1)
            .flatMap(l -> Order.of("ord-low", "cust-01", List.of(l), PaymentMethod.CARD));
    }

    static Result<Order> mediumRiskCardOrder() {
        return OrderLine.of("LAPTOP-15", 12000, 1).flatMap(l1 ->
            OrderLine.of("MOUSE-PRO", 3500, 2).flatMap(l2 ->
                Order.of("ord-medium", "cust-02", List.of(l1, l2), PaymentMethod.CARD)));
    }

    static Result<Order> highRiskInvoiceOrder() {
        return OrderLine.of("B2B-SERVER-RACK", 120000, 1)
            .flatMap(l -> Order.of("ord-high", "cust-03", List.of(l), PaymentMethod.INVOICE));
    }

    static final RiskRule riskEngine = RiskRule.productionRiskEngine();

    static void section(String t) { System.out.println("\n" + "═".repeat(72) + "\n  " + t + "\n" + "═".repeat(72)); }
    static void note(String m)    { System.out.println("  [INFO]  " + m); }
    static void outcome(String m) { System.out.println("  > " + m + "\n" + "═".repeat(72)); }

    static void demo1() {
        section("DEMO 1 — Low-Risk Card Payment");
        lowRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = riskEngine.apply(order);
            note("Risk: " + risk);

            // Function pipeline: steps composed as values
            PaymentStep<Order, Capture> lowRiskFlow =
                PaymentStep.authorizeStep("auto-approved")
                    .andThen(PaymentStep.captureStep());

            Capture cap = lowRiskFlow.execute(order, log);
            note("Capture: " + cap);

            Result<Refund> r = PaymentStep.refundStep(order.getPaymentMethod()).execute(cap, log);
            note("Refund: " + r);
            note("Audit: " + log);
            return cap;
        });
        outcome("Rule logic is an explicit, composable value — testable in isolation.");
    }

    static void demo2() {
        section("DEMO 2 — Medium-Risk Card Payment With 3DS");
        mediumRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = riskEngine.apply(order);
            note("Risk: " + risk);

            // 3DS step as an explicit value
            String proof = PaymentStep.threeDSStep().execute("3ds-ord-medium", log);
            note("3DS proof: " + proof);

            PaymentStep<Order, Capture> flow =
                PaymentStep.authorizeStep("3ds:" + proof)
                    .andThen(PaymentStep.captureStep());

            Capture cap = flow.execute(order, log);
            note("Capture: " + cap);
            note("Audit: " + log);
            return cap;
        });
        outcome("3DS step is explicit; still not enforced by types if forgotten.");
    }

    static void demo3() {
        section("DEMO 3 — High-Risk Invoice With Manual Review");
        highRiskInvoiceOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = riskEngine.apply(order);
            note("Risk: " + risk);

            String reviewer = PaymentStep.manualReviewStep().execute("ops-reviewer", log);

            PaymentStep<Order, Capture> flow =
                PaymentStep.authorizeStep("manual-review:" + reviewer)
                    .andThen(PaymentStep.captureStep());

            Capture cap = flow.execute(order, log);
            note("Capture: " + cap);
            Result<Refund> r = PaymentStep.refundStep(order.getPaymentMethod()).execute(cap, log);
            note("Refund attempt: " + r + " (invoice — correctly rejected)");
            note("Audit: " + log);
            return cap;
        });
        outcome("High-risk: manual review step explicit, refund still rejected by Result.");
    }

    // ─── Bad examples — bugs that STILL COMPILE here ─────────────────────────
    //
    // Stage-closure map (first = what Stage 04 closes next):
    //   Stage 4 closes: risk branch exhaustiveness — wrong pipeline selected silently
    //   Stage 5 closes: lifecycle ordering
    //   Stage 6 closes: right auth method for risk level; boundary constraints
    //   Stage 7 closes: protocol variant selection for runtime risk assessment

    static void badDemo_RuleStillNotWiredToStep() {
        section("BAD DEMO — Risk Decision Not Wired to Required Step (Bob's bug)");
        // (Stage 4 closes: sealed RiskDecision exhaustive switch forces correct pipeline selection)
        mediumRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = riskEngine.apply(order);
            note("Assessed risk: " + risk);

            // Developer forgets to check risk and uses the wrong pipeline.
            // riskEngine.apply() returns MEDIUM but we never use it to select the flow.
            PaymentStep<Order, Capture> buggyFlow =
                PaymentStep.authorizeStep("auto-approved") // no 3DS step!
                    .andThen(PaymentStep.captureStep());

            Capture cap = buggyFlow.execute(order, log);
            note("Captured without 3DS: " + cap);
            note("Audit: " + log + " — no 3ds-challenged entry!");
            return cap;
        });
        outcome("BUG: pipeline doesn't enforce 3DS for medium risk — wrong step selected silently.");
    }

    public static void main(String[] args) {
        demo1();
        demo2();
        demo3();
        badDemo_RuleStillNotWiredToStep();
    }
}
