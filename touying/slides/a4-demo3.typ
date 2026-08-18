// A4-demo3 · Act 4 beat 2 · LIVE DEMO 3 — setup card. Same shape as Demos 1 and 2.
//
// The sentence is the first item on A3-ceiling's list of what Java still
// accepts, said back word for word, so the room knows exactly which promise is
// being cashed.
#import "../theme.typ": *
#import "../components.typ": *

#slide-page(fill: pal.bg-dark, fg: pal.fg-dark)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(24pt), fill: pal.accent, tracking: 0.08em)[LIVE · DEMO 3]
      #v(sz(48pt))
      #set text(size: sz(60pt), weight: 300, fill: pal.fg-dark)
      #set par(leading: 0.72em, justify: false)
      Let's try to approve a medium-risk order\
      the #text(font: mono-font, fill: pal.accent)[automatic] way.
    ]
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(22pt), fill: pal.fg-dark-faint)[
        05-scala3-payment/…/demos/PaymentDemo.scala:123
      ]
    ]
  ]
]

#speaker-note[
#read("../scripts/21-demo3.md")
]
