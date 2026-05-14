// Stage 04: Records and sealed types demo
// Compile and run: javac *.java && java Demo
// Requires Java 17+ for sealed interfaces and record patterns.

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
    // Stage-closure map (first = what Stage 05 closes next):
    //   Stage 5 closes: lifecycle ordering — Capture constructible without Authorization
    //   Stage 6 closes: right auth method for risk level; boundary constraints
    //   Stage 7 closes: protocol variant selection for runtime risk assessment

    static void badDemo_LifecycleStillUnchecked() {
        section("BAD DEMO — Lifecycle Order Not Enforced (Alice and Charlie's bug)");
        // (Stage 5 closes: phantom generics make Payment<Captured> unreachable without Payment<Authorized>)
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
