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
MB WRITES THE WORDS. Budget 1:00 — about 115 spoken words. This is the minute
that turns four war stories into the thesis, and it is the second place you are
most likely to stumble, so it is worth over-rehearsing whatever you write.

Beats it has to hit, in this order:

1. The four incidents are not testing failures. In each one the language allowed
   a program that the business had already ruled out.

2. The scale of what follows. Specifying programs with types sits at the end of a
   long line running through philosophy, logic, mathematics and computer science.
   Your own draft used "two-thousand-five-hundred years"; Aristotle is 4th c. BCE,
   so 2,400 is the defensible number and "two and a half thousand" is a fair
   round figure. Say it however you say it — do not let me write it for you.

3. The claim: a substantial part of what this room does daily is the same activity
   that proof theory describes. Careful with the strength here — a sealed
   interface is an instance of a structure proof theory studies, not itself proof
   theory. Overclaiming loses the people who know the difference.

4. What understanding it buys: stating stronger and more precise invariants and
   having the machine check them, with fast and specific feedback when they break.

5. Agents get one clause at most. The full argument is slide 29 and spending it
   here weakens the close.

AVOID: "you just don't call it that" and similar stock kickers — the linter
blocks that one by name.
]
