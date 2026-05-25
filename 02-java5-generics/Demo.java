// ─── Stage 02: Java generics — parametric polymorphism ────────────────────────
// Compile and run: javac *.java && java Demo
//
// Lambda-cube position: λ2 (System F — first axis: terms quantified over types).
// Proof-theoretic gain: ∀-quantification; write Validator<T> once, provably correct
// for every type T you instantiate it with. Parametricity is the proof.
//
// ELIMINATED — compiler now proves these; their runtime tests can be deleted:
//
//   ✗ Collections of the wrong element type (unchecked inserts / casts)  [was stage 01]
//       Order.java:6        List<OrderLine> — typed line collection
//       Inserting a Capture into a List<OrderLine> is a compile error.
//       removes tests: "collection has correct element type"
//
//   ✗ Per-type validation boilerplate — duplicated null-check / guard patterns  [was stage 01]
//       Validator.java:9    Validator<T> — generic predicate + error message
//       Validator.java:14   andThen — validator composition
//       One interface; compose for any domain type. Write once, use everywhere.
//       removes tests: "validator composes correctly for each type"
//
//   ✗ Untyped audit log — any entry type silently accepted  [was stage 01]
//       AuditTrail.java:7   AuditTrail<E> — generic audit log
//       AuditTrail<String> rejects a Capture entry at compile time.
//       removes tests: "audit log type-safe"
//
// CODE REMOVED — genericity replaces duplication:
//
//   - Per-type validation boilerplate → Validator<T> (Validator.java:9)
//       One interface; compose with andThen (Validator.java:14) for any domain type.
//
// REMAINING GAPS — still compilable here (closed by later stages):
//
//   ✗ Forgotten risk branch: non-exhaustive if/else on RiskDecision   [closed at stage 04]
//       The enum is nominally typed since stage 01, but neither stage 01 nor
//       stage 02 force every branching site to handle every variant. Add a new
//       tier (or simply omit one), and the compiler stays silent.
//       Demo: buggyDemo_ForgottenBranch()
//
//   ✗ Refund on invoice is a runtime boolean check               [closed at stage 04]
//       PaymentMethod.java:4  supportsRefund() — boolean, not a type distinction.
//       Stage 04 replaces this with a sealed RefundMechanism type.
//
//   ✗ Lifecycle ordering: any Authorization accepted by capture  [closed at stage 05]
//       PaymentService.java:33  capture(Authorization) — not bound to a specific lifecycle.
//       Any Authorization from any flow compiles as a valid capture argument.
//
// ─────────────────────────────────────────────────────────────────────────────

import java.util.List;

public class Demo {

    static Order lowRiskCardOrder() {
        OrderLine line = OrderLine.of("BOOK-TDD-001", 4500, 1);
        return Order.of("ord-low", "cust-01", List.of(line), PaymentMethod.CARD);
    }

    static Order mediumRiskCardOrder() {
        OrderLine l1 = OrderLine.of("LAPTOP-15", 12000, 1);
        OrderLine l2 = OrderLine.of("MOUSE-PRO", 3500, 2);
        return Order.of("ord-medium", "cust-02", List.of(l1, l2), PaymentMethod.CARD);
    }

    static Order highRiskInvoiceOrder() {
        OrderLine line = OrderLine.of("B2B-SERVER-RACK", 120000, 1);
        return Order.of("ord-high", "cust-03", List.of(line), PaymentMethod.INVOICE);
    }

    static void section(String t) { System.out.println("\n" + "═".repeat(72) + "\n  " + t + "\n" + "═".repeat(72)); }
    static void note(String m)    { System.out.println("  [INFO]  " + m); }
    static void outcome(String m) { System.out.println("  > " + m + "\n" + "═".repeat(72)); }

    static void demo1() {
        section("DEMO 1 — Low-Risk Card Payment");
        Order order = lowRiskCardOrder();
        AuditTrail<String> log = AuditTrail.stringLog();  // AuditTrail<String>, not raw List
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order: " + order + ", risk: " + risk);
        Authorization auth = PaymentService.authorize(order, "auto-approved");
        log.append("authorized:" + auth.getAuthCode());
        Capture cap = PaymentService.capture(auth);
        log.append("captured:" + cap.getCaptureId());
        note("Capture: " + cap);
        Refund ref = PaymentService.refund(cap, order);
        note("Refund: " + ref);
        note("Audit: " + log);
        outcome("AuditTrail<String> and typed List<OrderLine>: wrong element type is a compile error.");
    }

    static void demo2() {
        section("DEMO 2 — Medium-Risk Card Payment With 3DS");
        Order order = mediumRiskCardOrder();
        AuditTrail<String> log = AuditTrail.stringLog();
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order: " + order + ", risk: " + risk);
        log.append("3ds-challenged:3ds-" + order.getOrderId());
        log.append("3ds-verified:proof-001");
        Authorization auth = PaymentService.authorize(order, "3ds:proof-001");
        log.append("authorized:" + auth.getAuthCode());
        Capture cap = PaymentService.capture(auth);
        log.append("captured:" + cap.getCaptureId());
        note("Capture: " + cap);
        note("Audit: " + log);
        outcome("Medium-risk: 3DS → authorize → capture. Risk enum returned but not forced to act on.");
    }

    static void demo3() {
        section("DEMO 3 — High-Risk Invoice With Manual Review");
        Order order = highRiskInvoiceOrder();
        AuditTrail<String> log = AuditTrail.stringLog();
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order: " + order + ", risk: " + risk);
        log.append("manual-review-approved:ops-reviewer");
        Authorization auth = PaymentService.authorize(order, "manual-review:ops-reviewer");
        log.append("authorized:" + auth.getAuthCode());
        Capture cap = PaymentService.capture(auth);
        log.append("captured:" + cap.getCaptureId());
        note("Capture: " + cap);
        try {
            Refund ref = PaymentService.refund(cap, order);
            note("Refund: " + ref);
        } catch (IllegalArgumentException e) {
            note("Refund rejected: " + e.getMessage() + " — expected for invoice.");
        }
        note("Audit: " + log);
        outcome("Invoice refund: caught at runtime. Stage 04's RefundMechanism makes it compile-time.");
    }

    static void demo4() {
        section("DEMO 4 — Validator<T>: Generic Composable Validation");
        // One generic interface; compose for any domain type.
        Validator<Integer> positive  = Validator.check(q -> q > 0,   "must be positive");
        Validator<Integer> notHuge   = Validator.check(q -> q < 1000, "must be under 1000");
        Validator<Integer> combined  = positive.andThen(notHuge);   // composition!

        note("Validator<Integer> positive.validate(5)   → " + positive.validate(5));
        note("Validator<Integer> notHuge.validate(5)    → " + notHuge.validate(5));
        note("combined.validate(5)                      → " + combined.validate(5));
        try { combined.validate(-1); } catch (IllegalArgumentException e) { note("combined.validate(-1) throws: " + e.getMessage()); }
        try { combined.validate(9999); } catch (IllegalArgumentException e) { note("combined.validate(9999) throws: " + e.getMessage()); }

        note("");
        note("Same Validator<T> interface works for any type. No per-type duplication.");
        note("PaymentService uses: Validator<Integer> positiveQuantity = check(q -> q > 0, ...)");
        note("                     Validator<Integer> strictPositiveQuantity = positiveQuantity.andThen(nonZeroQuantity)");
        outcome("Parametric polymorphism: write Validator<T> once, instantiate for every domain type.");
    }


    // ─── Bad examples — bugs that STILL COMPILE here ─────────────────────────
    //
    // Stage-closure map:
    //   closed at stage 4: risk branch exhaustiveness — non-exhaustive if/else silently misclassifies
    //   closed at stage 4: refund-on-invoice — runtime boolean check, not a type distinction
    //   closed at stage 5: lifecycle ordering — any Authorization accepted by capture
    //   closed at stage 6: right auth method for risk level; boundary constraints
    //   closed at stage 7: protocol variant selection for runtime risk assessment

    // The risk-handling path picked for an order, derived from RiskDecision.
    // The bug lives here: the if/else chain is not exhaustivity-checked,
    // and MEDIUM silently falls through to the fast path.
    static String pickAuthPath(RiskDecision risk) {
        if (risk == RiskDecision.LOW)  return "fast-path:auto-approved";
        if (risk == RiskDecision.HIGH) return "manual-review-required";
        // MEDIUM is not handled. There is no compile-time obligation to handle it.
        // Whatever falls through gets the fast path. 3DS is skipped.
        return "fast-path:auto-approved";
    }

    static void buggyDemo_ForgottenBranch() {
        section("BAD DEMO — Forgotten Risk Branch: Non-Exhaustive if/else");
        // (closed at stage 4: sealed types + exhaustive switch make a missing variant a compile error)
        //
        // RiskDecision has been a proper Java enum since stage 01 — it is nominally typed.
        // What neither stage 01 nor stage 02 give us is exhaustivity-checking of branching
        // over that enum. A developer writes the if/else once when there are two outcomes;
        // a third variant gets added later; every branching site stays silent.
        Order order = mediumRiskCardOrder();
        RiskDecision risk = PaymentService.assessRisk(order);
        note("Order:                 " + order);
        note("Assessed risk:         " + risk + "  (should require 3DS)");
        note("");

        String path = pickAuthPath(risk);
        note("Path chosen:           " + path);
        note("");

        // The MEDIUM order takes the fast path. 3DS never happens.
        Authorization auth = PaymentService.authorize(order, path);
        note("Authorized (no 3DS):   " + auth);
        note("");
        note("No compile error. No test catches this until production triggers the new tier.");
        outcome("BUG: non-exhaustive if/else over RiskDecision silently misclassifies MEDIUM.");
    }

    public static void main(String[] args) {
        demo1();
        demo2();
        demo3();
        demo4();
        buggyDemo_ForgottenBranch();
    }
}
