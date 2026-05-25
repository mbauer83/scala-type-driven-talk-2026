// Clock: 13:00–13:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [1],
  [Simple Types · Smart Constructors],
  [java 1–4 · nominal types + private constructors],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    eyebrow(style: "accent")[→ DEMO 2 in `Demo.java`],
    code-pane(
      filename: "Authorization.java",
      language: "java",
      highlights: ((7, "err"), (14, "hl-good")),
    )[
```java
public class Authorization {
    private final String orderId;
    private final String authCode;
    private final int    authorizedAmountCents;
    private final String approvalNote;

    private Authorization(String orderId, String authCode, int amount, String note) { ... }

    static Authorization from(Order order, String approvalNote) {
        return new Authorization(
            order.getOrderId(),
            "auth-" + order.getOrderId(),
            order.getTotalCents(),
            approvalNote);
    }
}
```
    ],
  ),
)

#speaker-note[
"Stage 1 adds nominal types and the smart-constructor pattern. The compiler now knows the difference between an Order and an Authorization. You cannot pass one where the other is expected. And because the constructor is private, you cannot fabricate an Authorization — you have to call the factory method, which validates and records the prior step. That closes the shape-confusion class and fabricated lifecycle values. The risk level still isn't in the type, so Bob's branching gap remains — Stage 4 closes that. Stage 2 generalises today's gains across every domain type at once."

→ Open `01-java-simple-types/Demo.java`, navigate to `gainDemo_SmartConstructors()`.
→ In the IDE, type `new Authorization(...)` next to the existing `Authorization.from(...)` call — the compiler shows a red squiggle: "Authorization() has private access in Authorization". Read it aloud: "The constructor is private; the only path in is the smart constructor, which validates and records the prior step."
→ Then navigate to `buggyDemo_Skip3DS()` — it still compiles. Point at it: "The risk level isn't in the type. Bob's branch can still be forgotten — Stage 4 closes that."
→ Return to slide.
]
