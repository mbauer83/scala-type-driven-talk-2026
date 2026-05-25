// Clock: 30:00–30:45
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 6 · Session Types]),
  [Session Types · What They Are],
  grid(
    columns: (1fr, 1fr),
    gutter: sz(32pt),
    stack(
      dir: ttb,
      spacing: sz(20pt),
      eyebrow(style: "accent")[→ DEMO 6b in `Derivation.scala`],
      [
        #set text(size: sz(28pt), weight: 300)
        A session type describes a whole *conversation* in the type system — the full sequence of moves, in order, on both sides.
      ],
      [
        #set text(size: sz(26pt), fill: pal.fg-dim)
        Each channel's type is the _remainder of the protocol_: the moves still to be made. Performing a send or a receive consumes one step and produces a channel typed by what's left to do.
      ],
      [
        #set text(size: sz(26pt), fill: pal.fg-dim)
        Two parties hold *complementary* types: one's send is the other's receive. A mismatch at either end is a compile error, not a runtime drift.
      ],
      callout(
        [Duality],
        [Server holds `Channel[Dual[P]]` — every Send becomes a Receive and vice versa. `Dual[P]` is computed by the compiler from the same protocol definition.],
        style: "accent",
      ),
    ),
    code-pane(filename: "Derivation.scala", language: "scala")[
```scala
// Client's view — steps consumed left to right
type LowRiskProtocol =
  Send[Order,
    Receive[RiskSnapshot,
      Receive[AuthorizedPayment[LowRisk],
        Receive[CapturedPayment,
          Choose[Receive[RefundedPayment, End],
                 End]]]]]

// Server's view — computed by the compiler
// Dual[Send[A, P]] = Receive[A, Dual[P]]
// Dual[Receive[A, P]] = Send[A, Dual[P]]
// Dual[Choose[L, R]] = Offer[Dual[L], Dual[R]]

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
Say: "One thing Scala 3 doesn't enforce: calling `finish()` at the end. Wrong-order sends and wrong message types are rejected. Calling `finish()` mid-conversation is also rejected — the compiler can't prove the protocol equals `End`. But not calling `finish()` at all — just dropping the channel — is not caught. The mechanism that closes this is linear types: bind the channel at multiplicity 1, and the compiler refuses to accept a program that doesn't consume it. Idris 2 has this via Quantitative Type Theory. We'll see it firing in Stage 7."

→ Run demo (20 sec):
Run `sbt run` in the terminal (pre-compiled). Show the output of `demo2()` — medium-risk payment with the 3DS challenge and proof visible in the log. Say: "Client and server, running in parallel, protocol enforced at both ends."

→ Return to slides.
]
