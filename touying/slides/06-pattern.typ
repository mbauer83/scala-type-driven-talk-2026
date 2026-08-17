// Clock: 2:45–3:45 · cap 1:00 · VERBATIM SCRIPT
//
// v2: "the turn". The single most important minute in the talk — it converts
// four war stories into the thesis. Delivered verbatim, over-rehearsed.
#import "../theme.typ": *
#import "../components.typ": *

// No headline: this slide's job is one statement, and a meta-title like
// "The Turn" would spend its most valuable line telling the audience nothing.
#slide-page[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #set text(size: sz(52pt), weight: 300, fill: pal.fg)
      #set par(leading: 0.8em, justify: false)
      A test catches the cases you thought of.\
      A type constrains #text(fill: pal.accent)[every call site] —\
      whether you thought of it or not.
    ]
    #v(sz(96pt))
    #align(center)[
      #set text(size: sz(36pt), weight: 300, fill: pal.fg-dim)
      #set par(leading: 0.7em, justify: false)
      What we are doing when we specify programs and types\
      has a history of about #text(fill: pal.fg, weight: 500)[two and a half thousand years.]
    ]
    #v(sz(28pt))
    #align(center)[
      #set text(font: mono-font, size: sz(28pt), fill: pal.fg-faint)
      philosophy #h(sz(20pt)) → #h(sz(20pt)) logic #h(sz(20pt)) → #h(sz(20pt)) mathematics
      #h(sz(20pt)) → #h(sz(20pt)) #text(fill: pal.accent)[your compiler]
    ]
    #v(1fr)
  ]
]

#speaker-note[
#read("../scripts/03-the-turn.md")
]
