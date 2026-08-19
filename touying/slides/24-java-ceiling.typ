// NO CUBE REVEAL. Parameterising it well is an hour I do not have before
// Thursday, and the reveal's whole job — name the two axes Java does not reach
// — is done in words below at no risk. The full cube is wired into the
// appendix for Q&A. C2 discipline on the ceiling claims, checked one at a time
// rather than asserted in bulk: risk-indexed approval Java can do properly;
// refinements it can do downstream but not on a literal and not composed;
// protocol duality it cannot do at all, because deriving the dual is type-
// level computation and Java has none. Conceding the first two is what makes
// the third believable.
#import "../theme.typ": *
#import "../components.typ": *

#let limit(head, body) = stack(
  dir: ttb,
  spacing: sz(14pt),
  text(size: sz(25pt), weight: 600, fill: pal.fg)[#head],
  block[
    #set text(size: sz(23pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Stage 4 payoff · and the Java ceiling]),
  body-gap: sz(30pt),
  [Charlie's bug is now a compile error, too],
  stack(
    dir: ttb,
    spacing: sz(44pt),
    block(width: 100%, fill: pal.good-bg, inset: (x: sz(26pt), y: sz(18pt)), radius: sz(4pt))[
      #set text(size: sz(26pt), fill: pal.fg)
      Two of the four incidents are gone, and neither of them by a test. Bob's
      needed every case. Charlie's needed #text(weight: 500)[provenance] — some
      evidence of where the value had been.
    ],
    line(length: 100%, stroke: 0.5pt + pal.rule),
    [
      #set text(size: sz(26pt), weight: 500, fill: pal.fg)
      Three things you can still write, and Java will still accept:
    ],
    grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: sz(40pt),
      limit([Approve a medium-risk order the automatic way.],
            [The risk level is not in the authorization's type.
             #text(fill: pal.fg)[Java can fix this] — another phantom parameter,
             more noise. #text(fill: pal.accent)[Stage 5 makes it cheap.]]),
      limit([Build an order with no lines, or a negative quantity.],
            [A smart constructor gets the same guarantee downstream.
             #text(fill: pal.fg)[What Java cannot do] is reject
             `Quantity.of(-1)` where the compiler can already see the `-1`, or
             compose two such rules into one type.
             #text(fill: pal.accent)[Stage 5.]]),
      limit([Disagree with the other service about the protocol.],
            [#text(fill: pal.fg)[This one Java cannot reach.] Deriving the other
             side's protocol needs types computed from types, and Java has no
             such thing. #text(fill: pal.accent)[Stage 5, and 6.]]),
    ),
    align(center)[
      #set text(size: sz(24pt), fill: pal.fg-dim)
      You can go a long way in Java. What comes next is a language where all
      three of these are cheap.
    ],
  ),
)

#speaker-note[
#read("../scripts/19-ceiling.md")
]
