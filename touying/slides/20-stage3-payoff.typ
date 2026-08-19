// P5 diagnosed both: two parallel scoreboards doing the same job badly,
// strikethrough that dies at projection distance, ~15 seconds each time, five
// times across the deck. So: no tables. The claim, the dead line, and the
// handover.
#import "../theme.typ": *
#import "../components.typ": *

#slide-page[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #set text(size: sz(56pt), weight: 300, fill: pal.fg)
      #set par(leading: 0.72em, justify: false)
      Bob's bug is now a #text(fill: pal.accent)[compile error.]
    ]
    #v(sz(64pt))
    #align(center)[
      #block(
        fill: pal.bad-bg, radius: sz(6pt),
        inset: (x: sz(40pt), y: sz(26pt)),
      )[
        #show raw: set text(font: mono-font, size: sz(26pt), fill: pal.fg-faint)
        #raw(block: true, "if (risk != HIGH) {\n    return fastPath(order);\n}")
      ]
    ]
    #v(sz(40pt))
    #align(center)[
      #set text(size: sz(30pt), weight: 300, fill: pal.fg-dim)
      #set par(leading: 0.7em, justify: false)
      The switch will not build without #text(font: mono-font, fill: pal.fg)[case Medium].\
      There is no longer an #text(font: mono-font, fill: pal.fg)[if] to get wrong.
    ]
    #v(1fr)
  ]
]

#speaker-note[
#read("../scripts/16-payoff-bob.md")
]
