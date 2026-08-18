// A3-demo2-out · captured output for Demo 2, verbatim from
// `demos/2-typestate.txt`. Fallback, and the freeze-frame to read from.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 2 · recorded · 2 of 2], style: "bad"),
  body-gap: sz(30pt),
  [The lifecycle, enforced],
  stack(
    dir: ttb,
    spacing: sz(34pt),
    terminal-pane(read("../../demos/2-term.txt").trim(), title: "bash", size: 19pt),
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      #set par(leading: 0.55em)
      Nobody wrote a test for that, and nobody had to catch it in review.
      Charlie's transition is not a program any more.
    ],
  ),
)

#speaker-note[
Read it off the screen, verbatim:

"Incompatible types: Payment of Initiated cannot be converted to Payment of Authorized."

Beat. Then:

"Nobody wrote a test for that, and nobody had to catch it in review."

Then re-comment, recompile, green. Say nothing.
]
