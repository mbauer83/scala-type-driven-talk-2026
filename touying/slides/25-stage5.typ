// A4-opens · cap 1:20 · Act 4 beat 1 of 5 · REWORK of v1 25-stage5
//
// D-C option (d): the act is motivated by the residual failure A3-ceiling ends
// on. That slide names three things Java still accepts; this one takes the
// first two, Demo 3 fires the first, and A4-sessions takes the third.
//
// v1 was a stage-opener showing the BODY of authorize — a match building an
// audit string — with `order.id`, `p.id`, `a.id` and `audit =`. None of those
// identifiers exist (Domain.scala has order.orderId.orderIdStr, p.challengeId,
// a.reviewer, auditTrail), and the body demonstrates nothing anyway: the
// signature above it is the whole argument, and it is what makes Demo 3's error
// readable sixty seconds later.
//
// Both panes are verbatim from payment/Domain.scala, bodies elided with `...`.
// MinLength[1] & MaxLength[10] is real in Iron and is NOT in this repository,
// so composition stays a spoken clause (Part 12/R9).
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

// The language change gets a filled chip rather than the 21px grey eyebrow every
// other slide carries. MB, 18 Aug: nothing made it prominent that the talk had
// moved language. This and A5-mltt are the only two slides that use it, because
// they are the only two places the syntax on the wall changes — stages 1 to 4
// are all Java. Two dark stage-opener slides were built for this and cut again;
// scripts/20-stage5.md records why.
#let lang-chip(lang, rest) = {
  box(fill: pal.accent, inset: (x: sz(14pt), y: sz(8pt)), radius: sz(4pt))[
    #text(font: mono-font, size: sz(26pt), weight: 700, fill: pal.bg, tracking: 0.08em)[#upper(lang)]
  ]
  h(sz(18pt))
  text(font: mono-font, size: sz(26pt), weight: 500, fill: pal.fg-dim, tracking: 0.02em)[#upper(rest)]
}

#light-slide(
  eyebrow: lang-chip([scala 3], [stage 5 · indexed evidence ⊕ refinement]),
  body-gap: sz(22pt),
  [Which risk it is, and what has been checked],
  stack(
    dir: ttb,
    spacing: sz(26pt),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(40pt),
      row-gutter: sz(30pt),
      align: (left + top, left + top),

      code-pane(filename: "Domain.scala", language: "scala", code-size: 19pt, pad-y: 14pt,
                height: sz(341pt), highlights: ((7, "hl-good"), (8, "hl-good")))[
```scala
sealed trait Approval[+R <: Risk]

case object AutoApproved extends Approval[LowRisk]
case class ThreeDSApproved(proof: ThreeDSProof)
     extends Approval[MediumRisk]

def authorize[R <: Risk](order: Order, approval: Approval[R])
    : AuthorizedPayment[R] = ...
```
      ],
      code-pane(filename: "Domain.scala", language: "scala", code-size: 19pt, pad-y: 14pt,
                height: sz(341pt), highlights: ((6, "hl-good"),))[
```scala
type NonEmptyLines  = List[OrderLine] :| MinLength[1]
type NonNegativeInt = Int :| GreaterEqual[0]

final case class Order private (
    lines: NonEmptyLines, ...):
  def firstLine: OrderLine = lines.head
```
      ],

      [
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #text(weight: 600, fill: pal.fg)[An approval is evidence for one level.]
        The only way to an `Approval[MediumRisk]` is a 3-D Secure proof, and
        `authorize` carries the level forward into the payment.
      ],
      [
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #text(weight: 600, fill: pal.fg)[`firstLine` is total.]
        No `Optional`, no defensive branch — the emptiness was excluded at the
        boundary, and nobody downstream establishes it again.
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/20-stage5.md")
]
