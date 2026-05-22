// ─── Stage 04: Java 17 — records and sealed types ────────────────────────────
// Compile and run: javac *.java && java Demo  (requires Java 17+)
//
// ELIMINATED — compiler now proves these; their runtime tests can be deleted:
//
//   ✗ Forgetting a risk branch — Bob's silent fall-through bug  [was stage 03]
//       RiskDecision.java:9   sealed interface RiskDecision permits Low, Medium, High
//       PaymentService.java:59  switch(risk) — compiler rejects missing cases
//       Omitting the Medium branch is now a compile error, not a silent default.
//       removes tests: "medium-risk branch must be handled"
//
//   ✗ Refund on an invoice path reaching the wrong branch  [was stage 03]
//       PaymentMethod.java:5   sealed interface PaymentMethod permits Card, Wallet, Invoice
//       PaymentService.java:45  switch(method) in refund() — Invoice case is explicit and required
//       No "default" can silently permit a refund on an invoice order.
//       removes tests: "invoice cannot be refunded"
//
// CODE REMOVED — records eliminate boilerplate:
//
//   - Constructor, getters, equals, hashCode, toString in Order, OrderLine, Authorization,
//     Capture, Refund → all replaced by record declarations
//     (Order.java:1, PaymentService.java:33-35)
//
// REMAINING GAPS — still compilable here (closed by later stages):
//
//   ✗ Lifecycle ordering: Capture constructible without Authorization  [closed at stage 05]
//       PaymentService.java:33  record Capture(...) — plain record; anyone can construct one
//       PaymentService.java:41  capture(Authorization) accepts any Authorization instance
//       Demo: badDemo_LifecycleStillUnchecked()
//
//   ✗ Medium branch required, but 3DS inside it is not enforced  [closed at stage 06]
//       PaymentService.java:69  Medium case must exist, but its body is unchecked
//       A developer can write the Medium case and still skip the 3DS step inside it.
//
// ─────────────────────────────────────────────────────────────────────────────

import java.util.List;

public class Demo {

    static Result<Order> lowRiskCardOrder() {
        return OrderLine.of("BOOK-TDD-001", 4500, 1)
            .flatMap(l -> Order.of("ord-low", "cust-01", List.of(l), new PaymentMethod.Card("tok_low")));
    }

    static Result<Order> mediumRiskCardOrder() {
        return OrderLine.of("LAPTOP-15", 12000, 1).flatMap(l1 ->
            OrderLine.of("MOUSE-PRO", 3500, 2).flatMap(l2 ->
                Order.of("ord-medium", "cust-02", List.of(l1, l2), new PaymentMethod.Card("tok_3ds"))));
    }

    static Result<Order> highRiskInvoiceOrder() {
        return OrderLine.of("B2B-SERVER-RACK", 120000, 1)
            .flatMap(l -> Order.of("ord-high", "cust-03", List.of(l), new PaymentMethod.Invoice("PO-7788")));
    }

    static void section(String t) { System.out.println("\n" + "═".repeat(72) + "\n  " + t + "\n" + "═".repeat(72)); }
    static void note(String m)    { System.out.println("  [INFO]  " + m); }
    static void outcome(String m) { System.out.println("  > " + m + "\n" + "═".repeat(72)); }

    static void demo1() {
        section("DEMO 1 — Low-Risk Card Payment");
        lowRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = PaymentService.assessRisk(order);
            note("Risk: " + risk.label() + ", order total: " + order.totalCents() + "c");
            PaymentService.Capture cap = PaymentService.processOrder(order, log);
            note("Capture: " + cap);
            Result<PaymentService.Refund> r = PaymentService.refund(cap, order.paymentMethod());
            note("Refund: " + r);
            note("Audit: " + log);
            return cap;
        });
        outcome("Sealed RiskDecision: compiler forces all three variants to be handled.");
    }

    static void demo2() {
        section("DEMO 2 — Medium-Risk Card Payment With 3DS");
        mediumRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = PaymentService.assessRisk(order);
            note("Risk: " + risk.label() + ", order total: " + order.totalCents() + "c");
            PaymentService.Capture cap = PaymentService.processOrder(order, log);
            note("Capture: " + cap);
            note("Audit: " + log);
            return cap;
        });
        outcome("Medium-risk branch is required by the compiler — Bob's silent fall-through is gone.");
    }

    static void demo3() {
        section("DEMO 3 — High-Risk Invoice With Manual Review");
        highRiskInvoiceOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = PaymentService.assessRisk(order);
            note("Risk: " + risk.label() + ", order total: " + order.totalCents() + "c");
            PaymentService.Capture cap = PaymentService.processOrder(order, log);
            note("Capture: " + cap);
            Result<PaymentService.Refund> r = PaymentService.refund(cap, order.paymentMethod());
            note("Refund attempt: " + r);
            note("Audit: " + log);
            return cap;
        });
        outcome("Invoice refund rejected by exhaustive switch — no default to forget.");
    }

    static void demo4() {
        section("DEMO 4 — Exhaustive Pattern Match Compiler Guarantee");
        // This switch must handle all three variants of RiskDecision.
        // Removing any case → compile error.
        // Try removing the Medium case to see the error message.
        RiskDecision decision = new RiskDecision.Medium();
        String label = switch (decision) {
            case RiskDecision.Low    l -> "low-risk fast path";
            case RiskDecision.Medium m -> "medium-risk 3DS path";   // Bob is forced to write this
            case RiskDecision.High   h -> "high-risk review path";
        };
        note("Exhaustive result for Medium: " + label);
        outcome("Sealed RiskDecision + switch expression = compile-error on forgotten branches.");
    }

    // ─── Bad examples — bugs that STILL COMPILE here ─────────────────────────
    //
    // Stage-closure map (first = what closed at stage 05 next):
    //   closed at stage 5: lifecycle ordering — Capture constructible without Authorization
    //   closed at stage 6: right auth method for risk level; boundary constraints
    //   closed at stage 7: protocol variant selection for runtime risk assessment

    static void badDemo_LifecycleStillUnchecked() {
        section("BAD DEMO — Lifecycle Order Not Enforced (Alice and Charlie's bug)");
        // (closed at stage 5: phantom generics make Payment<Captured> unreachable without Payment<Authorized>)
        lowRiskCardOrder().map(order -> {
            // Authorization and Capture are still plain records — anyone can make one.
            // Nothing in the type system prevents constructing a Capture without an Authorization.
            PaymentService.Capture fakeCapture = new PaymentService.Capture(
                "cap-fake", order.orderId(), order.totalCents());
            note("Constructed Capture without Authorization: " + fakeCapture);
            note("Type: " + fakeCapture.getClass().getSimpleName() + " — no typestate attached.");
            return fakeCapture;
        });
        outcome("BUG: Capture is a plain record — constructible without Authorization.");
    }

    public static void main(String[] args) {
        demo1();
        demo2();
        demo3();
        demo4();
        badDemo_LifecycleStillUnchecked();
    }
}
