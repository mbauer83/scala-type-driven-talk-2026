// A3-demo2 · Act 3 beat 7 · LIVE DEMO 2 — setup card. Same shape as Demo 1.
#import "../theme.typ": *
#import "../components.typ": *

#slide-page(fill: pal.bg-dark, fg: pal.fg-dark)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(24pt), fill: pal.accent, tracking: 0.08em)[LIVE · DEMO 2]
      #v(sz(48pt))
      #set text(size: sz(60pt), weight: 300, fill: pal.fg-dark)
      #set par(leading: 0.72em, justify: false)
      I capture a payment\
      that was never #text(font: mono-font, fill: pal.accent)[authorized].
    ]
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(22pt), fill: pal.fg-dark-faint)[
        04-java-advanced-generics-typestate/Demo.java:170
      ]
    ]
  ]
]

#speaker-note[
#read("../scripts/18-demo2.md")
]
