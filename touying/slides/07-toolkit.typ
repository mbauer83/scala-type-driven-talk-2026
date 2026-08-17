// A1-aristotle · cap 1:05 · Act 1 beat 1 of 6
// Validity is a property of form. Absorbs v1's `07-toolkit` history slide:
// the 2,400-year sweep now runs along the rail instead of costing a beat.
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([Aristotle · 4th century BCE], style: "accent"),
  [What makes an argument valid],
  [
    #v(sz(30pt))
    #align(center)[
      #grid(
        columns: (sz(520pt), sz(110pt), sz(300pt)),
        column-gutter: sz(28pt),
        row-gutter: sz(20pt),
        align: (right + horizon, center + horizon, left + horizon),

        text(size: sz(31pt), fill: pal.fg-dim)[All medium-risk orders need 3DS.],
        [],
        text(font: mono-font, size: sz(33pt), fill: pal.fg)[All M are T],

        text(size: sz(31pt), fill: pal.fg-dim)[This order is medium-risk.],
        [],
        text(font: mono-font, size: sz(33pt), fill: pal.fg)[x is M],

        line(length: 100%, stroke: 0.6pt + pal.rule-strong),
        [],
        line(length: 100%, stroke: 0.6pt + pal.fg),

        text(size: sz(31pt), fill: pal.fg-dim)[So this order needs 3DS.],
        [],
        text(font: mono-font, size: sz(33pt), fill: pal.fg)[x is T],
      )
    ]
    #v(sz(60pt))
    #align(center)[
      #set text(size: sz(36pt), weight: 400, fill: pal.fg)
      The content is gone. #text(fill: pal.accent)[The argument survived.]
    ]
  ],
  footer: act1-rail(lit: ("Aristotle",)),
)

#speaker-note[
#read("../scripts/04-aristotle.md")
]
