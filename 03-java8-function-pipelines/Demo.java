
// ─── Stage 03: Java 8 — function pipelines ───────────────────────────────────
// Note: Stage 3 has no live demo slot in the talk. Stage 4 opens with a 30-second
// acknowledgment of function pipelines before moving into ADTs and sealed types.
// This file exists as reference material only.
// Compile and run: javac *.java && java Demo
//
// Lambda-cube position: λ2 (System F — same position as Stage 2, no new proof class).
// Proof-theoretic gain: implication as function composition; rules as explicit proof objects.
// Architectural improvement over Stage 2; the type-safety frontier moves at Stage 4.
//
// ELIMINATED — no new compile-time error classes over stage 02.
//   This stage is an architectural improvement, not a safety boundary.
//   The type system gains nothing new here; the CODE gains explicit structure.
//
// CODE REMOVED — function values replace duplicated imperative logic:
//
//   - Risk rule logic scattered across service methods
//       → RiskRule.escalatedBy  (RiskRule.java:15)   — compose two rules into one
//       → RiskRule.productionRiskEngine (RiskRule.java:47) — assembled once, reused everywhere
//
//   - Manual step sequencing repeated in each flow
//       → PaymentStep.andThen   (PaymentStep.java:13) — compose A→B and B→C into A→C
//       → authorizeStep, captureStep, threeDSStep, manualReviewStep
//                               (PaymentStep.java:22-66) — named, testable in isolation
//
//   - Audit-append calls scattered at each call site
//       → each named PaymentStep appends its own entry; callers do not touch the log
//
// REMAINING GAPS — still compilable here (closed by later stages):
//
//   ✗ Risk result not wired to the required pipeline step  [closed at stage 04]
//       RiskRule.java:47  productionRiskEngine() returns a RiskDecision value
//       Nothing prevents passing that value to the wrong PaymentStep composition.
//       Demo: buggyDemo_RuleStillNotWiredToStep()
//
//   ✗ Lifecycle ordering: steps can be composed in the wrong order  [closed at stage 05]
//       PaymentStep.java:13  andThen is unconstrained — captureStep().andThen(authorizeStep())
//       compiles even though capture must follow authorize, not precede it.
//
//   ✗ Refund on invoice is a runtime Result.err, not a type distinction  [closed at stage 04]
//       PaymentStep.java:42  refundStep checks method.supportsRefund() at runtime.
//
// ─────────────────────────────────────────────────────────────────────────────

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
    // Stage-closure map (first = what closed at stage 04 next):
    //   closed at stage 4: risk branch exhaustiveness — wrong pipeline selected silently
    //   closed at stage 5: lifecycle ordering
    //   closed at stage 6: right auth method for risk level; boundary constraints
    //   closed at stage 7: protocol variant selection for runtime risk assessment

    static void buggyDemo_RuleStillNotWiredToStep() {
        section("BAD DEMO — Risk Decision Not Wired to Required Step (Bob's bug)");
        // (closed at stage 4: sealed RiskDecision exhaustive switch forces correct pipeline selection)
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
        buggyDemo_RuleStillNotWiredToStep();
    }
}
