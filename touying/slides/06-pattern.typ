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
      None of these is a testing failure.\
      In each one, the language let someone write down\
      something the business had already declared #text(fill: pal.bad)[illegal].
    ]
    #v(sz(96pt))
    #align(center)[
      #set text(size: sz(36pt), weight: 300, fill: pal.fg-dim)
      #set par(leading: 0.7em, justify: false)
      Writing down a type is a #text(fill: pal.fg, weight: 500)[two-and-a-half-thousand-year-old] activity.
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
VERBATIM. Four sentences, four breaths. Do not improvise here — this is the
minute that converts the war stories into the thesis, and it is the second
place you are most likely to stumble.

"None of these is a testing failure. In each one, the language let someone write
down something the business had already declared illegal.

Writing down a type is a two-and-a-half-thousand-year-old activity. The thread
runs from philosophy into logic, into mathematics, and into the compiler you
used this morning.

My claim for the next forty-five minutes is simple. A good part of what you
already do every day is proof theory. You just don't call it that.

Once you can see that, you can push on it — state stronger rules about your
system, and have the machine enforce them. For you, and for whatever else is
writing code in your repository these days."

(Last clause plants the agentic argument. Do not spend it here — slide 32 lands it.)
]
