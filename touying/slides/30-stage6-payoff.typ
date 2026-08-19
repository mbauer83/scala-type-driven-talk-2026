// Clock: 40:00–40:30
#import "../theme.typ": *
#import "../components.typ": *

// A5-payoff · cap 0:50 · Act 5 beat 3 of 3 · KEEP (Part 3)
//
// Dark culmination slide, and the deck's ONLY collective view of the four
// incidents — every payoff slide carried a scoreboard in v1 and P5 removed all
// of them so this one would land. 31-the-climb, which used to carry the
// bookkeeping, is cut to the appendix for the same reason.
//
// SLIDE COPY REWRITTEN 18 Aug (MB): v1 used the word *unrepresentable* twice,
// top and bottom, with two anaphoric negative lines between them — and the
// lesson lands without any of that. MB: it would immediately make eyes roll.
// The claim is now made once, positively, and the concept name lands once.
// The exact retired wording is in tools/retired.tsv, not repeated here.
//
// The v1 speaker note ended on a tricolon — "The
// compiler required the proof. Gentzen required it. Curry-Howard required it."
// — which was the only lint ERROR in Act 5, and the roll-call asks the room to
// do bookkeeping at the moment it should be feeling something. See the script.

#slide-page(fill: pal.bg-dark, fg: pal.fg-dark)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #{
        set text(size: sz(72pt), weight: 300, fill: pal.fg-dark)
        set par(leading: 0.55em, justify: false)
        [All four bugs are now]
        linebreak()
        [programs that cannot be written down.]
        linebreak()
        v(sz(24pt))
        text(weight: 500, fill: pal.accent, size: sz(80pt))[Unrepresentable.]
      }
    ]
    #v(sz(64pt))
    #story-strip((
      (name: "Alice",    what: [CSV amounts summed as strings — a twelve-digit total], state: "open", closed: true),
      (name: "Bob",      what: [Medium-risk branch forgotten — 3-D Secure skipped],   state: "open", closed: true),
      (name: "Charlie",  what: [A refund executed without checking its state],        state: "open", closed: true),
      (name: "Danielle", what: [Client and server drifted apart on the protocol],     state: "open", closed: true),
    ))
    #v(1fr)
  ]
]

#speaker-note[
#read("../scripts/27-payoff.md")
]
