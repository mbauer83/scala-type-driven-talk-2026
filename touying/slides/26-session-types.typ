// Clock: 30:00–30:45
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let bullet(label, body) = grid(
  columns: (sz(32pt), 1fr),
  gutter: sz(14pt),
  align: (right + top, left + top),
  text(size: sz(28pt), weight: 600, fill: pal.accent)[•],
  [
    #set par(leading: 0.4em)
    #text(size: sz(26pt), weight: 600)[#label] \
    #text(size: sz(24pt), fill: pal.fg-dim)[#body]
  ],
)

#light-slide(
  eyebrow: eyebrow([Stage 6 · Session Types]),
  [Session Types · What They Are],
  grid(
    columns: (1fr, 1.1fr),
    gutter: sz(28pt),
    align: (left + top, left + top),
    stack(
      dir: ttb,
      spacing: sz(22pt),
      eyebrow(style: "accent")[→ DEMO 6b in `Derivation.scala`],
      bullet([Protocol as type],
             [The full conversation — every send / receive / choice — encoded in the type.]),
      bullet([Channel = remainder],
             [Each step consumes one move; the channel's type is _what's left to do_.]),
      bullet([Complementary endpoints],
             [Client's send is server's receive. Mismatch is a compile error, not a runtime drift.]),
      callout(
        [Duality],
        [`Channel[Dual[P]]` on the server. `Dual[P]` is _computed_ from the same definition — both ends derived from one source.],
        style: "accent",
      ),
    ),
    code-pane(filename: "Derivation.scala", language: "scala", code-size: 22pt)[
```scala
// Client's view — steps consumed left to right
type LowRiskProtocol =
  Send[Order,
    Receive[RiskSnapshot,
      Receive[AuthorizedPayment[LowRisk],
        Receive[CapturedPayment,
          Choose[Receive[RefundedPayment, End],
                 End]]]]]

// Dual: Send ↔ Receive, Choose ↔ Offer
summon[Dual[LowRiskProtocol] =:=
  Receive[Order,
    Send[RiskSnapshot,
      Send[AuthorizedPayment[LowRisk],
        Send[CapturedPayment,
          Offer[Send[RefundedPayment, End],
                End]]]]]]
```
    ],
  ),
)

#speaker-note[
"A session type describes a whole conversation in the type system — the full sequence of moves, in order, on both sides. The channel's type at any point is the remainder of the protocol: the moves still to be made. Each send or receive consumes one step and gives back a channel typed by what's left to do. The two parties hold complementary session types — one side's send is the other side's receive — so a mismatch at either end is a compile error rather than a runtime drift. The 'complementary' relation is what duality formalises: the server holds `Channel[Dual[P]]` where the client holds `Channel[P]`, and the compiler computes `Dual[P]` from the same definition. Both ends are derived from one source. They cannot drift independently."

→ Session types in code (45 sec):
Open `Derivation.scala`. Show `LowRiskProtocol`, `MediumRiskProtocol`, `HighRiskProtocol` — the type-level conversation descriptions. Say: "These aren't interfaces. They are types that describe the entire conversation: order of messages, message types, choices. Client gets `Channel[P]`, server gets `Channel[Dual[P]]`."

→ Channel API (30 sec):
Open `Chan.scala`. Show `send` requiring `CanSend[P]`, `receive` requiring `CanReceive[P]`, `finish` requiring `P =:= End`. Say: "Every operation is constrained by the current protocol position. Wrong order or wrong direction is a compile error."

→ Duality computation (45 sec):
Return to `Derivation.scala`, `DualityChecks` object. Show one `summon[Dual[MediumRiskProtocol] =:= Receive[Order, Send[RiskSnapshot, ...]]]` assertion. Say: "The server's protocol is computed by the compiler from the client's protocol. They are derived from the same definition. If the server tries to send when it should receive, it doesn't compile. Danielle's incident is now structurally impossible."

→ Honest gap — channel completion (30 sec):
Say: "One thing Scala 3 doesn't enforce: calling `finish()` at the end. Wrong-order sends and wrong message types are rejected. Calling `finish()` mid-conversation is also rejected — the compiler can't prove the protocol equals `End`. But not calling `finish()` at all — just dropping the channel — is not caught. The mechanism that closes this is linear types: bind the channel at multiplicity 1, and the compiler refuses to accept a program that doesn't consume it. Idris 2 has this via Quantitative Type Theory. We'll see it firing in Stage 6."

→ Run demo (20 sec):
Run `sbt run` in the terminal (pre-compiled). Show the output of `demo2()` — medium-risk payment with the 3DS challenge and proof visible in the log. Say: "Client and server, running in parallel, protocol enforced at both ends."

→ Return to slides.
]
