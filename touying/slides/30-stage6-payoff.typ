// Clock: 40:00–40:30
#import "../theme.typ": *
#import "../components.typ": *

// Dark culmination slide — the moment the talk's central promise is fulfilled.
// test-list deliberately absent: S34 (The Climb) carries the bookkeeping.
// This slide carries the emotional weight.

#slide-page(fill: pal.bg-dark, fg: pal.fg-dark)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #{
        set text(size: sz(72pt), weight: 300, fill: pal.fg-dark)
        set par(leading: 0.55em, justify: false)
        [All four incidents are unrepresentable.]
        linebreak()
        text(fill: pal.fg-dark-dim, size: sz(56pt))[Not caught by tests.]
        linebreak()
        text(fill: pal.fg-dark-dim, size: sz(56pt))[Not caught at runtime.]
        linebreak()
        text(weight: 500, fill: pal.accent, size: sz(80pt))[Unrepresentable.]
      }
    ]
    #v(sz(64pt))
    #story-strip((
      (name: "Alice",    what: [Empty OrderId slips through the boundary],           state: "open", closed: true),
      (name: "Bob",      what: [Medium-risk branch forgotten — wrong approval path],  state: "open", closed: true),
      (name: "Charlie",  what: [Capture before authorize — lifecycle violated],       state: "open", closed: true),
      (name: "Danielle", what: [Client / server protocol drift at deployment],        state: "open", closed: true),
    ))
    #v(1fr)
  ]
]

#speaker-note[
// CUES:
// 1. Let this land — four chips, all CLOSED, dark slide
// 2. "Each of these four incidents has become a program that cannot be expressed."
// 3. "Not 'we wrote a test.' Not 'we reviewed the PR.' Unrepresentable."
// 4. Advance to S34 (The Climb) for the technical bookkeeping.

"Each of these four production incidents — Alice's boundary, Bob's branch, Charlie's lifecycle, Danielle's protocol — has, at this point, become a program that cannot be expressed in the type system. That is a much stronger guarantee than a test that catches it: there is no test to write, no PR to review, no runtime check to remember. The shape of the type makes the violation unrepresentable. The compiler required the proof. Gentzen required it. Curry-Howard required it."
]
