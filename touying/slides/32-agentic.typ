#import "../theme.typ": *
#import "../components.typ": *

// Stacked, not two columns: at 25pt the stage labels wrap, and a wrapped label
// beside a top-aligned price column throws every row out of register.
#let cost(stage, price, verdict) = stack(
  dir: ttb,
  spacing: sz(12pt),
  text(size: sz(27pt), weight: 600, fill: pal.fg)[#stage],
  block[
    #set text(size: sz(25pt), fill: pal.fg-dim)
    #set par(leading: 0.48em)
    #price #text(fill: pal.fg)[#verdict]
  ],
)

#light-slide(
  eyebrow: eyebrow([What it costs · and why the calculation is moving]),
  body-gap: sz(38pt),
  [What each stage costs to encode],
  stack(
    dir: ttb,
    spacing: sz(40pt),
    grid(
      columns: (1.35fr, 1fr),
      column-gutter: sz(64pt),
      align: (left + top, left + top),

      stack(
        dir: ttb,
        spacing: sz(34pt),
        cost([Stage 3 · sealed ⊕ records],
             [Java 17+, no dependency, an afternoon. ],
             [Worth doing regardless.]),
        cost([Stage 4 · phantom typestate],
             [An interface, a private constructor, a conversation in code
              review, and some generic noise in your signatures. ],
             [Where there is a lifecycle.]),
        cost([Stage 5 · Scala 3],
             [Build tooling, compile times in seconds rather than milliseconds,
              hiring, a real learning curve. ],
             [A team decision eventually — an afternoon on something small first.]),
        cost([Stage 6 · Idris 2],
             [Not a production proposal. ],
             [It shows where the ceiling is — and the ideas leak downwards.]),
      ),

      stack(
        dir: ttb,
        spacing: sz(24pt),
        callout(
          [Free],
          [None of the type-level machinery survives to runtime. What is left is
           the one check at the boundary you would have written by hand anyway.],
          style: "accent",
        ),
        
      ),
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      The question is whether this invariant is expensive enough to encode.
      #text(fill: pal.fg-dim)[ The tools keep getting cheaper, so that set keeps
      getting bigger.]
    ],
  ),
)

#speaker-note[
#read("../scripts/28-cost.md")
]
