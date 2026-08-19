#import "../theme.typ": *
#import "../components.typ": *

// The QR from the title slide, repeated: the moment people actually decide to
// take the link is the moment the talk ends. Same caption, so it reads as the
// same thing rather than a second, different link.
#close-slide(
  qr: qr-plate(
               [slides, and the code \
                for all six stages],
               fg: pal.fg-dim),
  [
  Every stage tonight made the same move: a rule that was only #text(fill: pal.fg-dim)[promised]
  — in a comment, in a test, in somebody's head — became a rule the type
  #text(fill: pal.accent)[states].

  #v(sz(28pt))

  A program that type-checks is a proof, and you have been writing them all along.

  #v(sz(28pt))
  #text(weight: 500)[Thank you.]

  ],
)

#speaker-note[
#read("../scripts/31-close.md")
]
