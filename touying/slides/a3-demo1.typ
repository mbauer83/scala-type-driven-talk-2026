// A3-demo1 · Act 3 beat 4 · LIVE DEMO 1 — the setup card
//
// D-D: one sentence naming what to watch, then silence. The audience cannot
// read code and listen at once, so this slide is deliberately almost empty and
// dark — the signal is "stop reading the wall, look at the IDE".
//
// The captured output is the NEXT slide, not a reveal on this one: a fallback
// you have to un-hide is a fallback you fumble under stress, and one on the
// following slide is recovered by the forward key you are already pressing.
// When the demo works it is a freeze-frame to read the error from.
#import "../theme.typ": *
#import "../components.typ": *

#slide-page(fill: pal.bg-dark, fg: pal.fg-dark)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(24pt), fill: pal.accent, tracking: 0.08em)[LIVE · DEMO 1]
      #v(sz(48pt))
      #set text(size: sz(60pt), weight: 300, fill: pal.fg-dark)
      #set par(leading: 0.72em, justify: false)
      Let's delete #text(font: mono-font, fill: pal.accent)[case Medium]\
      and watch what the compiler does.
    ]
    #v(1fr)
    #align(center)[
      #text(font: mono-font, size: sz(22pt), fill: pal.fg-dark-faint)[
        03-java-function-types-sealed/Demo.java:123
      ]
    ]
  ]
]

#speaker-note[
#read("../scripts/15-demo1.md")
]
