// Stage 01: Simple Java types demo
// Compile and run: javac *.java && java Demo

import java.util.List;

public class Demo {

    // ─── Shared fixture orders ────────────────────────────────────────────────

    static Order lowRiskCardOrder() {
        return new Order("ord-low", "cust-01",
            List.of(new OrderLine("BOOK-TDD-001", 4500, 1)),
            PaymentMethod.CARD);
    }

    static Order mediumRiskCardOrder() {
        return new Order("ord-medium", "cust-02",
            List.of(
                new OrderLine("LAPTOP-15",  12000, 1),
                new OrderLine("MOUSE-PRO",  3500,  2)
            ),
            PaymentMethod.CARD);
    }

    static Order highRiskInvoiceOrder() {
        return new Order("ord-high", "cust-03",
            List.of(new OrderLine("B2B-SERVER-RACK", 120000, 1)),
            PaymentMethod.INVOICE);
    }

    // ─── Output helpers ───────────────────────────────────────────────────────

    static void section(String title) {
        String bar = "═".repeat(72);
        System.out.println("\n" + bar + "\n  " + title + "\n" + bar);
    }
    static void note(String msg) { System.out.println("  [INFO]  " + msg); }
    static void outcome(String msg) {
        System.out.println("  > " + msg);
        System.out.println("═".repeat(72));
    }

    // ─── Good demos ───────────────────────────────────────────────────────────

    static void demo1() {
        section("DEMO 1 — Low-Risk Card Payment");
        Order order = lowRiskCardOrder();
        List<AuditEntry> log = AuditEntry.newLog();
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order: " + order + ", risk: " + risk);
        Capture cap = PaymentService.processLowRisk(order, log);
        note("Capture: " + cap);
        note("Audit: " + log);
        if (order.getPaymentMethod().supportsRefund()) {
            Refund r = PaymentService.refund(cap);
            note("Refund: " + r);
        }
        outcome("Low-risk: direct authorize → capture → refund. Shape errors now caught.");
    }

    static void demo2() {
        section("DEMO 2 — Medium-Risk Card Payment With 3DS");
        Order order = mediumRiskCardOrder();
        List<AuditEntry> log = AuditEntry.newLog();
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order: " + order + ", risk: " + risk);
        Capture cap = PaymentService.processMediumRisk(order, "3ds-ord-medium", "proof-001", log);
        note("Capture: " + cap);
        note("Audit: " + log);
        outcome("Medium-risk: 3DS challenge → authorize → capture.");
    }

    static void demo3() {
        section("DEMO 3 — High-Risk Invoice With Manual Review");
        Order order = highRiskInvoiceOrder();
        List<AuditEntry> log = AuditEntry.newLog();
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order: " + order + ", risk: " + risk);
        Capture cap = PaymentService.processHighRisk(order, "ops-reviewer", log);
        note("Capture: " + cap);
        note("Audit: " + log);
        note("Supports refund: " + order.getPaymentMethod().supportsRefund());
        outcome("High-risk: manual review → authorize → capture, no refund branch.");
    }

    // ─── Bad examples — bugs that STILL COMPILE here ─────────────────────────
    //
    // Stage-closure map (first = what Stage 02 closes next):
    //   Stage 2 closes: error/null paths from constructors unhandled at call site
    //   Stage 4 closes: risk branch exhaustiveness — medium-risk silently skipped
    //   Stage 5 closes: lifecycle ordering — capture before authorize still compiles
    //   Stage 6 closes: right auth method for risk level; boundary constraints
    //   Stage 7 closes: protocol variant selection for runtime risk assessment

    static void badDemo_CaptureBeforeAuthorize() {
        section("GAIN — Capture Before Authorize is Now a Compile Error");
        // In JS stage this compiled fine. Here:
        //   PaymentService.capture(order)           -- TYPE ERROR: Order is not Authorization
        //   PaymentService.capture(new Order(...))  -- TYPE ERROR
        // The argument types are now nominal, so this class of mistake is gone.
        note("capture(order) would be a compile error — Order is not Authorization.");
        note("Gain of stage 01: wrong-shape arguments to lifecycle functions are gone.");
        outcome("GAIN: shape confusion is a compile error. Next gap: error/null paths from constructors are unhandled.");
    }

    static void badDemo_Skip3DS() {
        section("BAD DEMO — Medium-Risk Order Skips 3DS (still possible)");
        // (Stage 4 closes: sealed RiskDecision forces exhaustive handling of every risk variant)
        Order order = mediumRiskCardOrder();
        List<AuditEntry> log = AuditEntry.newLog();
        // A developer who forgets to check the risk decision can skip the 3DS step.
        // Nothing in the type system stops this.
        RiskDecision risk = PaymentService.assessRisk(order);
        // Suppose the dev writes: if (risk == LOW) { processLowRisk } else { processLowRisk }
        // That is the exact bug RiskDecision as an enum does NOT prevent.
        Capture cap = PaymentService.processLowRisk(order, log); // wrong call for medium-risk!
        note("Risk was: " + risk + " but used processLowRisk — 3DS silently skipped.");
        note("Audit: " + log + " — no 3ds-challenged entry.");
        outcome("BUG: risk result not wired into the required next step — medium-risk processed as low-risk.");
    }

    static void badDemo_InvalidInput() {
        section("BAD DEMO — Invalid Input (zero quantity throws at runtime)");
        // (Stage 6 closes: PositiveInt refined type makes zero quantity a compile error for literals)
        try {
            new OrderLine("WIDGET", 1000, 0); // throws IllegalArgumentException
        } catch (IllegalArgumentException e) {
            note("Runtime error: " + e.getMessage());
            note("This is still a runtime check, not a compile-time proof.");
        }
        outcome("BUG: boundary validation is a runtime exception, not a compile-time constraint.");
    }

    public static void main(String[] args) {
        demo1();
        demo2();
        demo3();
        badDemo_CaptureBeforeAuthorize();
        badDemo_Skip3DS();
        badDemo_InvalidInput();
    }
}
