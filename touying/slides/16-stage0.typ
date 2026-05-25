// Clock: 12:00–12:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [0],
  [JavaScript · The Untyped Baseline],
  [javascript · no static guarantees],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    eyebrow(style: "accent")[→ DEMO 1 in `demo.js`],
    code-pane(filename: "payment.js", language: "javascript")[
```js
function authorize(order, approvalNote) {
  return {
    orderId:          order.id,
    authCode:         "auth-" + order.id,
    authorizedAmount: orderTotal(order),
    approvalNote:     approvalNote,   // any string; any caller; no checks
  };
}

function capture(auth) {
  return {
    captureId:      "cap-" + auth.authCode,
    capturedAmount: auth.authorizedAmount, // undefined if Order passed instead
  };
}
```
    ],
  ),
)

#speaker-note[
"Stage 0 is what the baseline gives us: runtime freedom, no structural constraints, every invariant is a test someone has to remember to write. Let's see what that looks like in code, then watch the bugs run silently."

→ Open `00-js-untyped-payment/demo.js` in the IDE. Show the payment business logic at the top: `assessRisk`, `authorize`, `capture` — no type annotations anywhere.
→ Run the two bad demos in the terminal first. The output shows: capture returning `capturedAmount: undefined`; medium-risk getting `approvalNote: 'auto-approved-wrong'`. No errors thrown.
→ Back in the IDE, navigate to `buggyDemo_CaptureBeforeAuthorize()`: point at `capture(lowRiskCardOrder)` — an Order passed where something else is expected. The interpreter has no complaint.
→ Then `buggyDemo_Skip3DS()`: point at the `if/else` over risk — medium-risk falls through to auto-approve.
→ Say: "Both runs succeeded. Both programs are valid. Every business invariant we want to hold is a test we have to remember to write."
→ Close or minimize `demo.js`.
]
