// Clock: 27:00–27:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [5],
  [Scala 3 · What Opens Up],
  [scala 3 · bounded λω + type families · Iron refinements],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    eyebrow(style: "accent")[→ DEMO 5a in `PaymentDemo.scala`],
    code-pane(filename: "Domain.scala", language: "scala")[
```scala
def authorize[R <: Risk](
    order:    Order,
    approval: Approval[R],
): AuthorizedPayment[R] =
  val note = approval match
    case AutoApproved        => "auto-approved"
    case ThreeDSApproved(p)  => s"3ds:${p.id}"
    case ReviewerApproved(a) => s"reviewer:${a.id}"
  AuthorizedPayment(
    order    = order,
    authCode = AuthCode.of(s"auth-${order.id}"),
    approval = approval,
    audit    = List(s"authorized:$note"),
  )
```
    ],
  ),
)

#speaker-note[
// CUES:
// 1. Open PaymentDemo.scala → serverMediumRisk → change ThreeDSApproved to AutoApproved → error on ch.send line
// 2. Revert ⌘Z → "Protocol context catches Bob's mistake — not the authorize call itself"
// 3. Show NonEmptyString in Domain.scala → OrderId.of("") returns Left (safe) vs refineUnsafe[MinLength[1]] (compile-time check)
// 4. Show CanSend[P]#Msg in Chan.scala → "message type derived from protocol position — send wrong type → compile error"
// 5. Mention =:= evidence and finish() in session-types segment next

"Scala 3's type system opens up mechanisms that Java simply cannot reach. Let's look at three of them in our code — refined identifiers, path-dependent channels, and match types — those carry most of the structural weight. Four more are in the repository; I'll point at them as we move through the session-types demo, and then show how they combine into something that makes Danielle's protocol-drift incident a compile error."

→ Feature 1 — Phantom indexing with sealed-subtype inference (45 sec):
Open `05-scala3-payment/src/main/scala/demos/PaymentDemo.scala`, navigate to `serverMediumRisk`. Change the relevant `authorize(order, ThreeDSApproved(proof))` line to `authorize(order, AutoApproved)`. The IDE shows an error on the next `ch.send(authorized)`. Hover: read "Found: `AuthorizedPayment[LowRisk]`, Required: `AuthorizedPayment[MediumRisk]`." Say: "Worth being precise here. `authorize(order, AutoApproved)` itself is well-typed — it just produces an `AuthorizedPayment[LowRisk]`. The compile error happens one line later, when we try to send that value through the channel: the medium-risk protocol requires `AuthorizedPayment[MediumRisk]` at this position, and `LowRisk` doesn't satisfy it. The protocol context is what catches Bob's mistake. Revert." (⌘Z)

→ Feature 2 — Refined types: NonEmptyString-refined identifiers (30 sec):
Open `Domain.scala`, navigate to `type NonEmptyString = String :| MinLength[1]`. Frame as a domain rule first: "order and customer identifiers must be non-empty — that's a business invariant, not a runtime check to remember at every consumer." Show `OrderId.of("")` → returns `Left(...)` (smart constructor for runtime values). Show `"".refineUnsafe[MinLength[1]]` → DOES NOT COMPILE (macro checks at compile time). Say: "Two paths into the type. The smart constructor handles runtime values safely. The macro path proves the predicate at compile time for literals."

→ Feature 3 — Path-dependent types (30 sec, LIVE):
Briefly show `CanSend[P]#Msg` in `Chan.scala`. Point at `ch.send(...)` — say: "The message type is derived from the protocol position. Sending the wrong type or sending on a receive step is a compile error. Defensive per-call-site test gone; behavioural tests stay."

→ Additional mechanisms (brief verbal mention, ~10 sec — no live edits):
"One more mechanism worth naming: opaque types — `AuthCode`, `CaptureId`, `RefundId` are all `String` underneath, but the compiler refuses to mix them. I'll show `=:=` evidence and `finish()` in the session-types segment next."

→ Return to slide briefly.
]
