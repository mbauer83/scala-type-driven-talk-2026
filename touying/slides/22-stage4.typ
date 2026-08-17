// Clock: 21:00–21:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [4],
  [Phantom Typestate · The State IS the Type],
  [java (advanced) · System Fω · phantom generics],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    eyebrow(style: "accent")[→ DEMO 4 in `Demo.java`],
    code-pane(
      filename: "Demo.java",
      language: "java",
      highlights: ((4, "err"), (5, "err")),
    )[
```java
Payment<Initiated>  init       = Payment.initiate(order);
Payment<Authorized> authorized = Payment.authorizeAuto(init);
Payment<Captured>   captured   = Payment.capture(authorized);

// Payment.capture(init);                  // ← UNCOMMENT → won't compile
// Payment.refund(authorized, instant);    // ← UNCOMMENT → won't compile
```
    ],
    signature-card[
      `authorizeAuto(`*`Payment<Initiated>`*`)` → `Payment<Authorized>`\
      `authorize3DS(`*`Payment<Initiated>`*`, ThreeDSProof)` → `Payment<Authorized>`\
      `capture(`*`Payment<Authorized>`*`)` → `Payment<Captured>`\
      `refund(`*`Payment<Captured>`*`, RefundMechanism)` → `Result<Payment<Refunded>>`
    ],
  ),
)

#speaker-note[
// CUES:
// 1. Open Payment.java → class declaration + private constructor → "phantom: no data, just a type constraint"
// 2. Show authorizeAuto / authorize3DS / capture signatures → "signature family IS the state machine"
// 3. Navigate to demo4_TypestateCompileErrors() in Demo.java
// 4. Uncomment "Payment.capture(init);" → read error aloud: "Payment<Initiated> cannot be converted to Payment<Authorized>"
// 5. Re-comment ⌘Z → "That type constraint IS the lifecycle ordering"
// 6. Show buggyDemo_WrongApprovalMethodStillPossible() → still compiles → "Risk level not in the type — Stage 5 closes this"

"Charlie's incident in the opening was a refund approval workflow with an illegal state transition. The demo here uses the same failure shape on payment capture instead — same structural problem, a little more compact to demonstrate. The parameter is a phantom — it carries no runtime data. What it does is restrict which factory methods can accept which payments. You cannot pass a `Payment<Initiated>` to `capture` — the types don't match. There is no expressible program here that holds a `Payment<Captured>` without having passed through `Payment<Authorized>` first."

→ Step 1 (30 sec): Open `04-java-advanced-generics-typestate/Payment.java`. Show the class declaration: `public final class Payment<S extends PaymentState>` with private constructor. Navigate to `initiate()` — public static, the only entry point.
→ Step 2 (30 sec): Show the `authorizeAuto`, `authorize3DS`, and `capture` signatures side by side. Say: "The method signature family IS the state machine. Each transition is a function that requires the right phantom type on input and produces the next phantom type on output."
→ Step 3 — LIVE UNCOMMENT MOMENT (60 sec): Navigate to `demo4_TypestateCompileErrors()` in `Demo.java`. Show the body: an order is built, `init`/`authorized`/`captured` go through the lifecycle, and three commented-out lines sit below — each marked `← UNCOMMENT`. Uncomment the `Payment.capture(init);` line. The compiler reports: "Payment<Initiated> cannot be converted to Payment<Authorized>". Read it aloud: "The capture function requires Payment<Authorized>. We're passing Payment<Initiated>. The lifecycle ordering is now a type constraint, not a convention." Re-comment with the `// ← UNCOMMENT` line restored.
→ Step 4 (60 sec): Navigate to `buggyDemo_WrongApprovalMethodStillPossible()`. Show a medium-risk order being authorized via `authorizeAuto`. Say: "This compiles. The type of `Payment<Initiated>` does not know which risk level it represents. The risk assessment is a runtime value. Java's phantom generics can carry the lifecycle state — but not the runtime risk classification. That gap is what Scala 3 closes."
→ Return to slides.
]
