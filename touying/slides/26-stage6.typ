// Clock: 27:00–27:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [6],
  [Scala 3 · What Opens Up],
  [scala 3 · bounded λω + type families · Iron refinements],
  stack(
    dir: ttb,
    spacing: sz(16pt),
    eyebrow(style: "accent")[→ DEMO 6a in `PaymentDemo.scala`],
    grid(
      columns: (1fr, 1fr),
      gutter: sz(20pt),
      stack(
        dir: ttb,
        spacing: sz(10pt),
        text(size: sz(20pt), weight: 500, font: mono-font, fill: pal.fg-dim)[MECHANISMS AT WORK],
        line(length: 100%, stroke: 0.5pt + pal.rule-strong),
        ..for (mech, detail) in (
          ("Refined types",            "NonEmptyString = String :| MinLength[1]"),
          ("Opaque + refined IDs",     "OrderId, CustomerId"),
          ("Path-dependent types",     "CanSend[P]#Msg"),
          ("Compiler-derived evidence","P =:= End"),
          ("Match types + duality",    "Dual[P] computed by compiler"),
          ("Higher-kinded types",      "interpret[F[_]: Functor, A]"),
        ) {
          (
            grid(
              columns: (auto, 1fr),
              gutter: sz(12pt),
              text(size: sz(22pt), weight: 500, fill: pal.accent)[#mech],
              text(size: sz(20pt), fill: pal.fg-dim, font: mono-font)[#detail],
            ),
          )
        },
      ),
      code-pane(filename: "Domain.scala", language: "scala")[
```scala
def authorize[R <: Risk](
    order:    Order,
    approval: Approval[R],
): AuthorizedPayment[R] =
  val note = approval match
    case AutoApproved        => "auto-approved"
    case ThreeDSApproved(p)  => s"3ds:${p.challengeId}"
    case ReviewerApproved(a) => s"manual-review:${a.reviewer}"
  AuthorizedPayment(
    order      = order,
    authCode   = AuthCode.of(s"auth-${order.orderId.orderIdStr}"),
    approval   = approval,
    auditTrail = List(s"authorized:$note"),
  )
```
      ],
    ),
  ),
)

#speaker-note[
"Scala 3's type system opens up mechanisms that Java simply cannot reach. Let's look at three of them in our code — refined identifiers, path-dependent channels, and match types — those carry most of the structural weight. Four more are in the repository; I'll point at them as we move through the session-types demo, and then show how they combine into something that makes Danielle's protocol-drift incident a compile error."

→ Feature 1 — Phantom indexing with sealed-subtype inference (45 sec):
Open `06-scala3-payment/src/main/scala/demos/PaymentDemo.scala`, navigate to `serverMediumRisk`. Change the relevant `authorize(order, ThreeDSApproved(proof))` line to `authorize(order, AutoApproved)`. The IDE shows an error on the next `ch.send(authorized)`. Hover: read "Found: `AuthorizedPayment[LowRisk]`, Required: `AuthorizedPayment[MediumRisk]`." Say: "Worth being precise here. `authorize(order, AutoApproved)` itself is well-typed — it just produces an `AuthorizedPayment[LowRisk]`. The compile error happens one line later, when we try to send that value through the channel: the medium-risk protocol requires `AuthorizedPayment[MediumRisk]` at this position, and `LowRisk` doesn't satisfy it. The protocol context is what catches Bob's mistake. Revert." (⌘Z)

→ Feature 2 — Refined types: NonEmptyString-refined identifiers (30 sec):
Open `Domain.scala`, navigate to `type NonEmptyString = String :| MinLength[1]`. Frame as a domain rule first: "order and customer identifiers must be non-empty — that's a business invariant, not a runtime check to remember at every consumer." Show `OrderId.of("")` → returns `Left(...)` (smart constructor for runtime values). Show `"".refineUnsafe[MinLength[1]]` → DOES NOT COMPILE (macro checks at compile time). Say: "Two paths into the type. The smart constructor handles runtime values safely. The macro path proves the predicate at compile time for literals."

→ Feature 3 — Path-dependent types (30 sec, LIVE):
Briefly show `CanSend[P]#Msg` in `Chan.scala`. Point at `ch.send(...)` — say: "The message type is derived from the protocol position. Sending the wrong type or sending on a receive step is a compile error. Defensive per-call-site test gone; behavioural tests stay."

→ Features 4–6 (mention as walk-through, ~30 sec total — no live edits):
"Three more mechanisms in the file — `=:=` evidence (`finish()` requires a compiler-constructed proof that the protocol equals `End`), opaque types (`AuthCode`, `CaptureId`, `RefundId` are all `String` underneath but the compiler refuses to mix them), and catamorphisms (`interpret[F[_]: Functor, A]`). You can see all three in the repo."

→ Return to slide briefly.
]
