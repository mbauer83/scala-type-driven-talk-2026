// A4-demo5 · Act 4 beat 4 · LIVE DEMO 5 — setup card. Same shape as Demos 1-4.
//
// NEW, 19 Aug. Danielle was the one incident of the four that ended in a
// sentence rather than in a compiler error the room watched arrive; A4-sessions
// states the property and this checks it. The edit is the LAST operation of
// serverHighRisk, which is what keeps the error to a single readable line —
// scripts/22b-demo5.md records the four positions that do not.
//
// The edit is arranged, and the bug class is not: the payment side decides the
// high-risk flow ends with the client confirming the capture, and waits for an
// acknowledgement the client's contract never mentions. An earlier version used
// `ch5.receive()._2` — same error, but nobody writes that by accident, and a
// room that notices stops believing the demo (MB, 19 Aug).
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
      Let's make the payment side #text(font: mono-font, fill: pal.accent)[wait]\
      for a message the other side never sends.
    ]
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(22pt), fill: pal.fg-dark-faint)[
        05-scala3-payment/…/demos/PaymentDemo.scala:141
      ]
    ]
  ]
]

#speaker-note[
#read("../scripts/22b-demo5.md")
]
