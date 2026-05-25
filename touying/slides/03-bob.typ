// Clock: 1:45–3:00
#import "../theme.typ": *
#import "../components.typ": *

#incident-slide(
  [Checkout Fraud & Risk Engine],
  [Bob],
  [#text(fill: pal.bad)[OPEN]],
  [The Forgotten Branch],
  [
    Checkout service classifies orders: Low / Medium / High risk.
    Medium-risk card orders must complete 3DS before authorization.
    When a Medium tier was added, the original two-level branch still compiled —
    and Medium silently fell through to the fast path. 3DS skipped. Liability shift lost.
  ],
  [
    if (risk != HIGH) fastPath()  // MEDIUM falls through\
    else              manualReview()
  ],
)

#speaker-note[
"Bob's team added a medium-risk tier to their fraud engine. The original branching was written when there were only two outcomes — low and high. `if risk != HIGH, take the fast path` was reasonable code at the time. When medium was added, the condition still held for medium orders. They hit the fast path. No 3DS. The liability shift went to the merchant. The code compiled — it had always compiled, and there was no obvious reason it should have stopped. That's the real problem: there's nothing in the language that requires anyone to revisit existing branching when a third risk tier appears. The compiler had no opinion."
]
