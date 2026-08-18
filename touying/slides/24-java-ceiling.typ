// A3-ceiling · cap 1:20 · Act 3 beat 8 of 8 · MERGE of v1 23-stage4-payoff + 24-java-ceiling
//
// Charlie's payoff is one line here rather than a slide of its own — v1's
// payoff carried the nine-row table and the four-chip strip, both of which P5
// removed and Part 2 replaced with Device 1.
//
// NO CUBE REVEAL. Part 2/Device 2 wants `lambda-cube-canvas(reveal: 1)` here,
// and the diagram is still the fixed unparameterised value it always was
// (diagrams/lambda-cube.typ:29). Parameterising it well is an hour I do not
// have before Thursday, and the reveal's whole job — name the two axes Java
// does not reach — is done in words below at no risk. The full cube is wired
// into the appendix for Q&A. Flagged in the plan, not quietly dropped.
//
// C2 discipline on the ceiling claims: Java CAN encode all three of these with
// enough hand-rolled machinery. The honest limit is what it costs, not what is
// possible, and the linter has an `overclaim` rule watching for the stronger
// form.
#import "../theme.typ": *
#import "../components.typ": *

#let limit(head, body) = stack(
  dir: ttb,
  spacing: sz(8pt),
  text(size: sz(25pt), weight: 600, fill: pal.fg)[#head],
  block[
    #set text(size: sz(23pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Stage 4 payoff · and the Java ceiling]),
  body-gap: sz(22pt),
  [Charlie's bug is now a compile error too],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    block(width: 100%, fill: pal.good-bg, inset: (x: sz(26pt), y: sz(18pt)), radius: sz(4pt))[
      #set text(size: sz(26pt), fill: pal.fg)
      Two of the four incidents are gone, and neither of them by a test. Bob's
      needed every case; Charlie's needed the right order.
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
            [A smart constructor gets you the same guarantee downstream.
             #text(fill: pal.fg)[What Java cannot do] is check it on a literal,
             or combine two such predicates. #text(fill: pal.accent)[Stage 5.]]),
      limit([Disagree with the other service about the protocol.],
            [#text(fill: pal.fg)[This one Java cannot reach.] Deriving the other
             side's protocol needs types computed from types, and Java has no
             such thing. #text(fill: pal.accent)[Stage 5, and 6.]]),
    ),
    align(center)[
      #set text(size: sz(24pt), fill: pal.fg-dim)
      The question is never whether to change language. It is which of these
      you are paying for already, and what each one costs to encode.
    ],
  ),
)

#speaker-note[
#read("../scripts/19-ceiling.md")
]
