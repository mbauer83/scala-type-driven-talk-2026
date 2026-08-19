// A4-sessions · cap 1:30 · Act 4 beat 3 of 5 · REWORK of v1 26-session-types
//
// This is the fourth of the four things A1-above promised the room it would see
// running — "a conversation between two services written down as one type" —
// and the first of the four to be paid off. It is also the third item on
// A3-ceiling's list, the one Java cannot reach at all, because deriving the
// other side needs types computed from types.
//
// v1 carried four prose bullets plus a callout plus a pane, and the bullets
// said in words what the two panes say in code (Part 14/R11). Both panes are
// verbatim: Derivation.scala:38-43 and Dual.scala:7-12.
//
// The summon block is on the wall and NOT in the script. It is the honest
// answer to "how do you know Dual is right" and a good Q&A beat; there is no
// airtime for it here.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 5 · session types · duality]),
  body-gap: sz(20pt),
  [Both ends, out of one definition],
  stack(
    dir: ttb,
    spacing: sz(34pt),
    grid(
      columns: (1fr, 1.05fr),
      column-gutter: sz(38pt),
      row-gutter: sz(28pt),
      align: (left + top, left + top),

      code-pane(filename: "Derivation.scala", language: "scala", code-size: 19pt, pad-y: 12pt)[
```scala
type LowRiskProtocol =
  Send[Order,
    Receive[RiskSnapshot,
      Receive[AuthorizedPayment[LowRisk],
        Receive[CapturedPayment,
          Choose[Receive[RefundedPayment, End], End]]]]]
```
      ],
      code-pane(filename: "Dual.scala", language: "scala", code-size: 19pt, pad-y: 12pt)[
```scala
type Dual[P <: Protocol] <: Protocol = P match
  case End           => End
  case Send[a, n]    => Receive[a, Dual[n]]
  case Receive[a, n] => Send[a, Dual[n]]
  case Choose[l, r]  => Offer[Dual[l], Dual[r]]
  case Offer[l, r]   => Choose[Dual[l], Dual[r]]
```
      ],

      [
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #text(weight: 600, fill: pal.fg)[The whole exchange, in order.] The
        channel you hold is typed by what is left to do, so every step hands you
        back a smaller protocol.
      ],
      [
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #text(weight: 600, fill: pal.fg)[A `match` on a type, giving back a
        type,] and calling itself on the rest — run by the compiler, before your
        program does anything.
      ],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    grid(
      columns: (1.15fr, 1fr),
      column-gutter: sz(38pt),
      align: (left + horizon, left + horizon),
      [
        #set text(size: sz(25pt), fill: pal.fg)
        #set par(leading: 0.45em)
        The client holds `Channel[P]` and the server holds `Channel[Dual[P]]`.
        #text(fill: pal.fg-dim)[ A server that sends where it should be
        receiving does not compile.]
      ],
      block(width: 100%, fill: pal.good-bg, radius: sz(6pt),
            inset: (x: sz(20pt), y: sz(14pt)))[
        #show raw: set text(font: mono-font, size: sz(18pt), fill: pal.fg)
        #raw(block: true,
          "summon[Dual[LowRiskProtocol] =:=\n"
          + "  Receive[Order, Send[RiskSnapshot, ...]]]")
        #v(sz(6pt))
        #text(size: sz(20pt), fill: pal.fg-dim)[It compiles, or the build fails.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/22-sessions.md")
]
