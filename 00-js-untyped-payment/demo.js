// ─── Stage 00: JavaScript demo ────────────────────────────────────────────────
// Run with: node demo.js

const { orderTotal, assessRisk, supportsRefund, authorize, capture, refund, processOrder } = require("./payment");

// ─── Shared fixture orders ────────────────────────────────────────────────────

const lowRiskCardOrder = {
  id: "ord-low",
  customerId: "cust-01",
  lines: [{ sku: "BOOK-TDD-001", unitPrice: 4500, quantity: 1 }],
  paymentMethod: { type: "card", token: "tok_low" },
};

const mediumRiskCardOrder = {
  id: "ord-medium",
  customerId: "cust-02",
  lines: [
    { sku: "LAPTOP-15", unitPrice: 12000, quantity: 1 },
    { sku: "MOUSE-PRO", unitPrice: 3500,  quantity: 2 },
  ],
  paymentMethod: { type: "card", token: "tok_3ds" },
};

const highRiskInvoiceOrder = {
  id: "ord-high",
  customerId: "cust-03",
  lines: [{ sku: "B2B-SERVER-RACK", unitPrice: 120000, quantity: 1 }],
  paymentMethod: { type: "invoice", reference: "PO-7788" },
};

// ─── Output helpers ───────────────────────────────────────────────────────────

const bar = "═".repeat(72);
function section(title) { console.log("\n" + bar + "\n  " + title + "\n" + bar); }
function note(msg)       { console.log("  [INFO]  " + msg); }
function outcome(msg)    { console.log("  > " + msg + "\n" + bar); }

// ─── Good demos ───────────────────────────────────────────────────────────────

function demo1() {
  section("DEMO 1 — Low-Risk Card Payment");
  const log = [];
  const risk = assessRisk(lowRiskCardOrder);
  note("Order total: " + orderTotal(lowRiskCardOrder) + "c, risk: " + risk);
  const result = processOrder(lowRiskCardOrder, log);
  note("Audit: " + JSON.stringify(log));
  note("Result: " + JSON.stringify(result));
  const cap = result.cap;
  if (supportsRefund(lowRiskCardOrder.paymentMethod)) {
    const r = refund(cap);
    note("Refund: " + JSON.stringify(r));
  }
  outcome("Low-risk: direct authorize → capture → optional refund");
}

function demo2() {
  section("DEMO 2 — Medium-Risk Card Payment With 3DS");
  const log = [];
  const risk = assessRisk(mediumRiskCardOrder);
  note("Order total: " + orderTotal(mediumRiskCardOrder) + "c, risk: " + risk);
  const result = processOrder(mediumRiskCardOrder, log);
  note("Audit: " + JSON.stringify(log));
  note("Result: " + JSON.stringify(result));
  outcome("Medium-risk: 3DS challenge → authorize → capture");
}

function demo3() {
  section("DEMO 3 — High-Risk Invoice With Manual Review");
  const log = [];
  const risk = assessRisk(highRiskInvoiceOrder);
  note("Order total: " + orderTotal(highRiskInvoiceOrder) + "c, risk: " + risk);
  const result = processOrder(highRiskInvoiceOrder, log);
  note("Audit: " + JSON.stringify(log));
  note("Result: " + JSON.stringify(result));
  note("Supports refund: " + supportsRefund(highRiskInvoiceOrder.paymentMethod));
  outcome("High-risk: manual review → authorize → capture, no refund branch");
}

// ─── Bad demos — bugs that compile and run with no error ─────────────────────
//
// Stage-closure map (first = what Stage 01 closes next):
//   Stage 1 closes: wrong-shape arguments to lifecycle functions
//   Stage 2 closes: error/null paths from constructors unhandled at call site
//   Stage 4 closes: risk branch exhaustiveness; refund eligibility structural
//   Stage 5 closes: lifecycle ordering; amount derived from authorized payment
//   Stage 6 closes: right auth method for risk level; boundary constraints
//   Stage 7 closes: protocol variant selection

function buggyDemo_CaptureBeforeAuthorize() {
  section("BAD DEMO — Capture Before Authorize (Bug: wrong object passed)");
  // (Stage 1 closes: nominal types make capture(order) a compile error)
  // Nothing in the language stops us from calling capture() directly on an order.
  // The function just silently reads undefined fields.
  const cap = capture(lowRiskCardOrder);
  note("capture(order) returned: " + JSON.stringify(cap));
  note("capturedAmount is: " + cap.capturedAmount + " (undefined — wrong object shape)");
  note("No error thrown. This 'succeeds' at runtime.");
  outcome("BUG: capture(order) reads undefined fields and silently succeeds — wrong shape, no error.");
}

function buggyDemo_Skip3DS() {
  section("BAD DEMO — Medium-Risk Order Skips 3DS (Bob's bug)");
  // (Stage 4 closes: sealed RiskDecision forces exhaustive handling of medium-risk branch)
  function buggyProcess(order) {
    const risk = assessRisk(order);
    if (risk === "low") {
      return authorize(order, "auto-approved"); // correct for low
    } else {
      // "medium" falls through to the same branch as "high" — no 3DS step!
      return authorize(order, "auto-approved-wrong"); // BUG: should require 3DS proof
    }
  }
  const auth = buggyProcess(mediumRiskCardOrder);
  note("Medium-risk order authorized without 3DS: " + JSON.stringify(auth));
  note("approvalNote: '" + auth.approvalNote + "' — no challenge was completed");
  outcome("BUG: risk decision not threaded into required step — medium-risk authorized without 3DS.");
}

function buggyDemo_RefundOnInvoice() {
  section("BAD DEMO — Refund on Invoice Order (no-refund path violated)");
  // (Stage 4 closes: sealed PaymentMethod + exhaustive switch enforces refund eligibility)
  const log = [];
  const result = processOrder(highRiskInvoiceOrder, log);
  const cap = result.cap;
  // Nothing prevents calling refund() on a capture from an invoice order.
  const r = refund(cap);
  note("refund() called on invoice capture: " + JSON.stringify(r));
  note("supportsRefund(invoice) = " + supportsRefund(highRiskInvoiceOrder.paymentMethod));
  note("... but nothing enforced it in the type system.");
  outcome("BUG: refund eligibility is a runtime comment, not a structural constraint.");
}

function buggyDemo_WrongAmount() {
  section("BAD DEMO — Wrong Amount Captured");
  // (Stage 5 closes: typestate makes capture derive amount from the authorized payment)
  // Developer grabs the first line's unit price instead of the authorized amount.
  const auth = authorize(lowRiskCardOrder, "auto-approved");
  const badCap = {
    captureId:      "cap-" + auth.authCode,
    capturedAmount: lowRiskCardOrder.lines[0].unitPrice, // wrong field! should be auth.authorizedAmount
  };
  note("auth.authorizedAmount: " + auth.authorizedAmount);
  note("badCap.capturedAmount: " + badCap.capturedAmount + " (used wrong field — unit price only)");
  outcome("BUG: nothing requires the captured amount to come from the authorized payment.");
}

// ─── Run all demos ────────────────────────────────────────────────────────────

demo1();
demo2();
demo3();
buggyDemo_CaptureBeforeAuthorize();
buggyDemo_Skip3DS();
buggyDemo_RefundOnInvoice();
buggyDemo_WrongAmount();
