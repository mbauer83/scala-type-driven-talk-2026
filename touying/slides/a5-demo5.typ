// A5-demo5 · Act 5 beat 2 · LIVE DEMO 5 — setup card. Same shape as Demos 1–4.
//
// The sentence is the second of A4-ceiling's two remaining limits, said back
// plainly: "nothing makes you finish the channel." This is the one Scala could
// not catch at all.
#import "../theme.typ": *
#import "../components.typ": *

#slide-page(fill: pal.bg-dark, fg: pal.fg-dark)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(24pt), fill: pal.accent, tracking: 0.08em)[LIVE · DEMO 5]
      #v(sz(48pt))
      #set text(size: sz(60pt), weight: 300, fill: pal.fg-dark)
      #set par(leading: 0.72em, justify: false)
      Let's drop the channel\
      without #text(font: mono-font, fill: pal.accent)[closing] it.
    ]
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(22pt), fill: pal.fg-dark-faint)[
        06-idris2-payment/src/Main.idr:115
      ]
    ]
  ]
]

#speaker-note[
#read("../scripts/26-demo5.md")
]
