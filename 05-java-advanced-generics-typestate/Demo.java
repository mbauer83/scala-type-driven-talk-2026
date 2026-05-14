// Stage 05: Typestate via phantom generics demo
// Compile and run: javac *.java && java Demo
// Requires Java 17+.

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
        section("DEMO 1 — Low-Risk: Direct Authorize → Capture → Refund");
        lowRiskCardOrder().map(order -> {
            RiskDecision risk = RiskService.assess(order);
            note("Risk: " + risk.label());

            Payment<PaymentState.Initiated>  initiated   = Payment.initiate(order);
            Payment<PaymentState.Authorized> authorized  = Payment.authorizeAuto(initiated);
            Payment<PaymentState.Captured>   captured    = Payment.capture(authorized);
            note("Captured: " + captured);

            boolean refundOk = order.paymentMethod().supportsRefund();
            Result<Payment<PaymentState.Refunded>> refunded = Payment.refund(captured, refundOk);
            note("Refund: " + refunded);
            note("Audit: " + captured.getAuditTrail());
            return captured;
        });
        outcome("Typestate: capture(initiated) and refund(authorized) are compile errors.");
    }

    static void demo2() {
        section("DEMO 2 — Medium-Risk: 3DS Challenge → Authorize → Capture");
        mediumRiskCardOrder().map(order -> {
            RiskDecision risk = RiskService.assess(order);
            note("Risk: " + risk.label());

            Payment<PaymentState.Initiated> initiated = Payment.initiate(order);

            // 3DS challenge: we must construct a ThreeDSProof to call authorize3DS.
            // There is no way to get Payment<Authorized> on the 3DS path without a proof.
            ThreeDSProof proof = new ThreeDSProof("3ds-" + order.orderId(), true);
            Payment<PaymentState.Authorized> authorized = Payment.authorize3DS(initiated, proof);
            Payment<PaymentState.Captured>   captured   = Payment.capture(authorized);
            note("Captured: " + captured);
            note("Audit: " + captured.getAuditTrail());

            // What still goes wrong: a developer can call authorizeAuto(initiated) here
            // instead of authorize3DS. The risk level is not encoded in the type
            // of Payment<Initiated>, so the compiler cannot prevent the wrong call.
            return captured;
        });
        outcome("3DS proof required to call authorize3DS — but wrong method can still be chosen.");
    }

    static void demo3() {
        section("DEMO 3 — High-Risk: Manual Review → Authorize → Capture");
        highRiskInvoiceOrder().map(order -> {
            RiskDecision risk = RiskService.assess(order);
            note("Risk: " + risk.label());

            Payment<PaymentState.Initiated> initiated = Payment.initiate(order);
            ManualReviewApproval approval = new ManualReviewApproval("ops-reviewer", "KYC matched");
            Payment<PaymentState.Authorized> authorized = Payment.authorizeReview(initiated, approval);
            Payment<PaymentState.Captured>   captured   = Payment.capture(authorized);
            note("Captured: " + captured);

            boolean refundOk = order.paymentMethod().supportsRefund(); // false for invoice
            Result<Payment<PaymentState.Refunded>> refunded = Payment.refund(captured, refundOk);
            note("Refund attempt: " + refunded + " — invoice, correctly rejected");
            note("Audit: " + captured.getAuditTrail());
            return captured;
        });
        outcome("Manual review approval required; invoice refund rejected.");
    }

    static void demo4_TypestateCompileErrors() {
        section("DEMO 4 — What Would Be Compile Errors");
        note("The following lines, if uncommented, would fail to compile:");
        note("");
        note("  Payment<PaymentState.Initiated> init = Payment.initiate(order);");
        note("  Payment.capture(init);");
        note("  // Error: capture(Payment<Authorized>) — cannot apply to Payment<Initiated>");
        note("");
        note("  Payment<PaymentState.Authorized> auth = Payment.authorizeAuto(init);");
        note("  Payment.refund(auth, true);");
        note("  // Error: refund(Payment<Captured>) — cannot apply to Payment<Authorized>");
        note("");
        note("  Payment.authorizeAuto(Payment.authorizeAuto(init));");
        note("  // Error: authorizeAuto(Payment<Initiated>) — cannot apply to Payment<Authorized>");
        outcome("Lifecycle ordering is encoded in type parameters: capture-before-auth is gone.");
    }

    // ─── Bad examples — bugs that STILL COMPILE here ─────────────────────────
    //
    // Stage-closure map (first = what Stage 06 closes next):
    //   Stage 6 closes: right auth method for risk level — phantom indexing on Approval[R]
    //                   makes authorize(mediumOrder, AutoApproved) a type error
    //   Stage 6 closes: boundary constraints — PositiveInt refined type
    //   Stage 7 closes: protocol variant selection for runtime risk assessment

    static void badDemo_WrongApprovalMethodStillPossible() {
        section("BAD DEMO — Wrong Approval Method Still Compiles (remaining gap)");
        // (Stage 6 closes: Approval[R] phantom indexing — AutoApproved cannot satisfy Approval[MediumRisk])
        mediumRiskCardOrder().map(order -> {
            RiskDecision risk = RiskService.assess(order);
            note("Assessed risk: " + risk.label() + " (should require 3DS)");

            Payment<PaymentState.Initiated> initiated = Payment.initiate(order);
            // A developer assesses MEDIUM risk but calls authorizeAuto instead of authorize3DS.
            // This still compiles. The type of Payment<Initiated> does not know
            // which approval method is required — that depends on the runtime risk value.
            Payment<PaymentState.Authorized> authorized = Payment.authorizeAuto(initiated);
            note("Authorized via auto-approval even though risk is MEDIUM: " + authorized);
            note("Audit: " + authorized.getAuditTrail() + " — no 3DS entry!");
            return authorized;
        });
        outcome("BUG: risk level not encoded in Payment<Initiated> — wrong approval method compiles.");
    }

    public static void main(String[] args) {
        demo1();
        demo2();
        demo3();
        demo4_TypestateCompileErrors();
        badDemo_WrongApprovalMethodStillPossible();
    }
}
