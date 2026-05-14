// Stage 02: Generics demo
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

    static void section(String t) { System.out.println("\n" + "═".repeat(72) + "\n  " + t + "\n" + "═".repeat(72)); }
    static void note(String m)    { System.out.println("  [INFO]  " + m); }
    static void outcome(String m) { System.out.println("  > " + m + "\n" + "═".repeat(72)); }

    static void demo1() {
        section("DEMO 1 — Low-Risk Card Payment");
        lowRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = PaymentService.assessRisk(order);
            note("Order: " + order + ", risk: " + risk);
            Authorization auth = PaymentService.authorize(order, "auto-approved");
            log.append("authorized:" + auth.getAuthCode());
            Capture cap = PaymentService.capture(auth);
            log.append("captured:" + cap.getCaptureId());
            note("Capture: " + cap);
            Result<Refund> r = PaymentService.refund(cap, order);
            note("Refund: " + r);
            note("Audit: " + log);
            return cap;
        });
        outcome("Generics: Result<T> forces error handling at construction; reusable Validator<T>.");
    }

    static void demo2() {
        section("DEMO 2 — Medium-Risk Card Payment With 3DS");
        mediumRiskCardOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = PaymentService.assessRisk(order);
            note("Order: " + order + ", risk: " + risk);
            log.append("3ds-challenged:3ds-ord-medium");
            log.append("3ds-verified:proof-001");
            Authorization auth = PaymentService.authorize(order, "3ds:proof-001");
            log.append("authorized:" + auth.getAuthCode());
            Capture cap = PaymentService.capture(auth);
            log.append("captured:" + cap.getCaptureId());
            note("Capture: " + cap);
            note("Audit: " + log);
            return cap;
        });
        outcome("Medium-risk: 3DS → authorize → capture.");
    }

    static void demo3() {
        section("DEMO 3 — High-Risk Invoice With Manual Review");
        highRiskInvoiceOrder().map(order -> {
            AuditTrail<String> log = AuditTrail.stringLog();
            RiskDecision risk = PaymentService.assessRisk(order);
            note("Order: " + order + ", risk: " + risk);
            log.append("manual-review-approved:ops-reviewer");
            Authorization auth = PaymentService.authorize(order, "manual-review:ops-reviewer");
            log.append("authorized:" + auth.getAuthCode());
            Capture cap = PaymentService.capture(auth);
            log.append("captured:" + cap.getCaptureId());
            note("Capture: " + cap);
            Result<Refund> r = PaymentService.refund(cap, order);
            note("Refund attempt: " + r + " (invoice — correctly rejected)");
            note("Audit: " + log);
            return cap;
        });
        outcome("High-risk: invoice refund now rejected by Result<Refund>.");
    }

    static void demo4() {
        section("DEMO 4 — Invalid Input Handled via Result<T>");
        Result<OrderLine> zeroQty = OrderLine.of("BUGGY", 1000, 0);
        note("OrderLine.of qty=0 -> " + zeroQty);
        Result<Order> emptyOrder = Order.of("ord-empty", "cust-x", List.of(), PaymentMethod.CARD);
        note("Order.of empty lines -> " + emptyOrder);
        outcome("Bad inputs produce Result.Err — no exceptions, callers must handle.");
    }

    // ─── Bad examples — bugs that STILL COMPILE here ─────────────────────────
    //
    // Stage-closure map (first = what Stage 04 closes next):
    //   Stage 4 closes: risk branch exhaustiveness — medium-risk silently skipped
    //   Stage 5 closes: lifecycle ordering — any Authorization accepted by capture
    //   Stage 6 closes: right auth method for risk level; boundary constraints
    //   Stage 7 closes: protocol variant selection for runtime risk assessment

    static void badDemo_LifecycleStillUnchecked() {
        section("BAD DEMO — Lifecycle Still Not Checked");
        // (Stage 5 closes: phantom generics make Payment<Authorized> the only valid capture input)
        lowRiskCardOrder().map(order -> {
            // Nothing stops us calling capture before authorize.
            // We'd need to construct a fake Authorization manually.
            // In practice the issue is that capture() accepts ANY Authorization,
            // not specifically one derived from THIS order's lifecycle.
            Authorization fakeAuth = new Authorization(
                "ord-other", "auth-other", 9999, "fake");
            Capture cap = PaymentService.capture(fakeAuth); // no type error!
            note("Captured with wrong auth: " + cap);
            note("Amount: " + cap.getCapturedAmountCents() + "c — wrong order's amount.");
            return cap;
        });
        outcome("BUG: any Authorization is accepted by capture — not bound to the order's lifecycle.");
    }

    public static void main(String[] args) {
        demo1();
        demo2();
        demo3();
        demo4();
        badDemo_LifecycleStillUnchecked();
    }
}
