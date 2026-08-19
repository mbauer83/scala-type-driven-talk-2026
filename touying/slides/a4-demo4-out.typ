// A4-demo4-out · captured output for Demo 4, verbatim from `demos/4-term.txt`,
// produced by tools/capture-terminal.sh against the real `sbt compile`.
// Fallback, and the freeze-frame to read the error from.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 4 · recorded · 2 of 2], style: "bad"),
  body-gap: sz(30pt),
  [The protocol says whose turn it is],
  stack(
    dir: ttb,
    spacing: sz(34pt),
    terminal-pane(read("../../demos/4-term.txt").trim(), title: "bash", size: 20pt),
    // The money line is one clause in the middle of a dark pane. This is that
    // clause, at a size the back row can read, and it is the thing MB points at.
    align(center)[
      #block(fill: pal.bg-warm, inset: (x: sz(30pt), y: sz(18pt)), radius: sz(4pt))[
        #set text(font: mono-font, size: sz(26pt), fill: pal.fg)
        #text(fill: pal.accent)[receive]
        #h(sz(18pt))
        #text(size: sz(22pt), font: body-font, fill: pal.fg-dim)[
          — and what this conversation still owes is
        ]
        #h(sz(14pt))
        Send[CapturedPayment, End]
      ]
    ],
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      #set par(leading: 0.55em)
      The drift Danielle found three weeks in has nowhere left to happen.
    ],
  ),
)

#speaker-note[
Read the one line off the screen, unhurried:

»No given instance of CanReceive, for Send of CapturedPayment, End.«

Leave »for parameter r of method receive in class Channel« unread — it is the
compiler naming its own plumbing.

Beat. Then:

»There is no evidence that you may receive here, because what is left of this
conversation begins with a send. Untyped, that is not an exception anybody
catches — it is two services waiting for each other. The drift Danielle found
three weeks in has nowhere left to happen.«

Then put `ch5.send(captured)` back — one line replacing the two — recompile,
green. Say nothing.
]
