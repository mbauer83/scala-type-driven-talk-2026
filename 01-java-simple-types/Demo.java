// ─── Stage 01: Java 1–4 — nominal types ──────────────────────────────────────
// Compile and run: javac *.java && java Demo
//
// ELIMINATED — compiler now proves these; their runtime tests can be deleted:
//
//   ✗ Wrong-shape arguments (Order passed where Authorization expected, etc.)
//       PaymentService.java:37  authorize(Order, String) : Authorization
//       PaymentService.java:46  capture(Authorization)   : Capture
//       PaymentService.java:54  refund(Capture)          : Refund
//       Named types make swapped/wrong arguments a compile error.
//       removes tests: "capture(order) should be rejected", "refund(auth) should be rejected"
//
//   ✗ Field-name typos and wrong-field access
//       Order.java:18-21, Authorization.java:7-13 — named accessor methods
//       replace stringly-keyed property bags; typos are compile errors.
//       removes tests: "wrong field name should fail"
//
//   ✗ Fabricated lifecycle values — constructing Authorization or Capture with arbitrary fields
//       Authorization.java:8   private constructor; only Authorization.from(Order, ...) produces one
//       Capture.java:8         private constructor; only Capture.from(Authorization) produces one
//       Refund.java:8          private constructor; only Refund.from(Capture) produces one
//       Smart-constructor pattern: fabrication is blocked; each value's fields are consistent
//       with the prior step. As a consequence, capture() requires a real prior authorize() call.
//       Foreshadows opaque types and refined types at stage 06.
//       removes tests: "fabricated authorization should be rejected", "fabricated capture should be rejected"
//
// REMAINING GAPS — still compilable here (closed by later stages):
//
//   ✗ Invalid inputs throw at runtime, not compile time  [closed at stage 02]
//       OrderLine.java:10    — quantity ≤ 0 throws IllegalArgumentException
//       Order.java:11        — empty lines throws IllegalArgumentException
//       No typed error container; callers have no way to statically handle failure.
//
//   ✗ Wrong method called for the assessed risk level   [closed at stage 04]
//       PaymentService.java:21  assessRisk() returns a plain enum (RiskDecision)
//       PaymentService.java:65  processLowRisk() can be called even for MEDIUM risk
//       The returned value is not connected to the required flow by any type.
//
//   ✗ Any valid Authorization accepted by capture — no per-flow binding
//       PaymentService.java:46  capture(Authorization) — any Authorization works, not just this flow's
//       Two concurrent flows' authorizations can be exchanged without a type error.
//       Java phantom types do not close this; the lifecycle state is in the class name, not a type
//       parameter, and there is no way to link a state value to a specific flow.
//
//   ✗ Refund on invoice is a runtime Boolean check       [closed at stage 04]
//       PaymentMethod.java:4  supportsRefund() — a runtime flag, not a type distinction
//       Calling refund() on an Invoice payment compiles and throws/returns false.
//
//   ✗ Audit entries omittable on any branch              [closed at stage 06]
//       PaymentService.java:65-91  helpers append audit, but callers can bypass them.
//
// ─────────────────────────────────────────────────────────────────────────────

import java.util.Arrays;
import java.util.List;

// Java 1–4 style: raw List without type parameter — no generics in this stage.
@SuppressWarnings({"rawtypes", "unchecked"})
public class Demo {

    // ─── Shared fixture orders ────────────────────────────────────────────────

    static Order lowRiskCardOrder() {
        return new Order("ord-low", "cust-01",
            Arrays.asList(new OrderLine("BOOK-TDD-001", 4500, 1)),
            PaymentMethod.CARD);
    }

    static Order mediumRiskCardOrder() {
        return new Order("ord-medium", "cust-02",
            Arrays.asList(
                new OrderLine("LAPTOP-15",  12000, 1),
                new OrderLine("MOUSE-PRO",  3500,  2)
            ),
            PaymentMethod.CARD);
    }

    static Order highRiskInvoiceOrder() {
        return new Order("ord-high", "cust-03",
            Arrays.asList(new OrderLine("B2B-SERVER-RACK", 120000, 1)),
            PaymentMethod.INVOICE);
    }

    // ─── Output helpers ───────────────────────────────────────────────────────

    static String bar() {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < 72; i++) sb.append('═');
        return sb.toString();
    }
    static void section(String title) {
        String b = bar();
        System.out.println("\n" + b + "\n  " + title + "\n" + b);
    }
    static void note(String msg) { System.out.println("  [INFO]  " + msg); }
    static void outcome(String msg) {
        System.out.println("  > " + msg);
        System.out.println(bar());
    }

    // ─── Good demos ───────────────────────────────────────────────────────────

    static void demo1() {
        section("DEMO 1 — Low-Risk Card Payment");
        Order order = lowRiskCardOrder();
        List log = AuditEntry.newLog();
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
        List log = AuditEntry.newLog();
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
        List log = AuditEntry.newLog();
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
    // Stage-closure map (first = what closed at stage 02 next):
    //   closed at stage 2: error/null paths from constructors unhandled at call site
    //   closed at stage 4: risk branch exhaustiveness — medium-risk silently skipped
    //   closed at stage 5: lifecycle state unified in Payment<S> with explicit type parameter
    //   closed at stage 6: right auth method for risk level; boundary constraints; opaque types
    //   closed at stage 7: protocol variant selection for runtime risk assessment

    static void gainDemo_SmartConstructors() {
        section("GAIN — Nominal Types and Smart Constructors");
        // Nominal typing: wrong-shaped argument is a compile error
        //  capture(order)              -- TYPE ERROR: Order is not Authorization
        //
        // Smart-constructor pattern: private constructors prevent fabrication
        //   -- COMPILE ERROR: constructor is private --
        //   new Authorization("some-order-id", "some-fake-auth-code", 999999999, "fake approval");     
        //   new Capture("my-capture-id", "order-id", 999999999);
        //
        // Consequence: capture() requires a real Authorization from authorize() —
        // you cannot skip steps, because you cannot fabricate the required value.
        // This is the same pattern as opaque types / refined types, applied manually in Java.
        note("capture(order) — TYPE ERROR: Order is not Authorization. (nominal typing)");
        note("new Authorization(...) — COMPILE ERROR: constructor is private. (smart constructor)");
        note("Fabrication blocked: the only path to Capture is through a real Authorization.");
        outcome("GAIN: shape errors from nominal types; fabrication blocked by smart constructors.");
    }

    static void buggyDemo_Skip3DS() {
        section("BAD DEMO — Medium-Risk Order Skips 3DS (still possible)");
        // (closed at stage 4: sealed RiskDecision forces exhaustive handling of every risk variant)
        Order order = mediumRiskCardOrder();
        List log = AuditEntry.newLog();
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

    static void buggyDemo_InvalidInput() {
        section("BAD DEMO — Invalid Input (zero quantity throws at runtime)");
        // (closed at stage 6: PositiveInt refined type makes zero quantity a compile error for literals)
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
        gainDemo_SmartConstructors();
        buggyDemo_Skip3DS();
        buggyDemo_InvalidInput();
    }
}
