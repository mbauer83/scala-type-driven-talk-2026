// ─── Stage 00: JavaScript — no types, no static guarantees ───────────────────
//
// This is the baseline. Everything is a plain object. Nothing stops you from
// passing the wrong thing, calling steps out of order, or forgetting a branch.
//
// The same scenarios run across all eight stages. Here they all work — or
// appear to — because JavaScript cannot express that any of this is wrong.

// ─── Domain helpers ───────────────────────────────────────────────────────────

function orderTotal(order) {
  return order.lines.reduce((sum, line) => sum + line.unitPrice * line.quantity, 0);
}

function assessRisk(order) {
  const total = orderTotal(order);
  if (order.paymentMethod.type === "invoice") return "high";
  if (order.paymentMethod.type === "wallet") {
    return total <= 20000 ? "low" : "medium";
  }
  // card
  if (total <= 15000) return "low";
  if (total <= 80000) return "medium";
  return "high";
}

function supportsRefund(paymentMethod) {
  return paymentMethod.type !== "invoice";
}

// ─── Payment lifecycle functions ──────────────────────────────────────────────
// Each function trusts that it has been given the right object.
// Nothing in the language verifies that trust.

function authorize(order, approvalNote) {
  return {
    orderId:          order.id,
    authCode:         "auth-" + order.id,
    authorizedAmount: orderTotal(order),
    approvalNote:     approvalNote,
  };
}

function capture(auth) {
  return {
    captureId:      "cap-" + auth.authCode,
    capturedAmount: auth.authorizedAmount,
  };
}

function refund(cap) {
  return {
    refundId:       "ref-" + cap.captureId,
    refundedAmount: cap.capturedAmount,
  };
}

// ─── Order processing — the realistic, documented flow ───────────────────────

function processOrder(order, auditLog) {
  const risk = assessRisk(order);

  if (risk === "low") {
    const auth = authorize(order, "auto-approved");
    const cap  = capture(auth);
    auditLog.push({ event: "authorized", detail: auth.authCode });
    auditLog.push({ event: "captured",   detail: cap.captureId });
    return { status: "captured", captureId: cap.captureId, auth, cap };

  } else if (risk === "medium") {
    // 3DS challenge — the caller is supposed to drive this exchange
    const challenge = { challengeId: "3ds-" + order.id, amountBand: "soft" };
    const proof     = { challengeId: challenge.challengeId, liabilityShift: true };
    const auth      = authorize(order, "3ds-verified:" + proof.challengeId);
    const cap       = capture(auth);
    auditLog.push({ event: "3ds-verified", detail: proof.challengeId });
    auditLog.push({ event: "authorized",   detail: auth.authCode });
    auditLog.push({ event: "captured",     detail: cap.captureId });
    return { status: "captured", captureId: cap.captureId, auth, cap };

  } else {
    // high risk — manual review gate
    const review  = { queue: "manual-review", reason: "high-risk or invoice" };
    const approval = { reviewer: "ops-reviewer", note: "KYC matched" };
    const auth    = authorize(order, "manual-review-approved:" + approval.reviewer);
    const cap     = capture(auth);
    auditLog.push({ event: "manual-review-approved", detail: approval.reviewer });
    auditLog.push({ event: "authorized",              detail: auth.authCode });
    auditLog.push({ event: "captured",                detail: cap.captureId });
    return { status: "captured", captureId: cap.captureId, auth, cap };
  }
}

module.exports = {
  orderTotal, assessRisk, supportsRefund,
  authorize, capture, refund,
  processOrder,
};
