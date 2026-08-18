// A4-demo3-out · captured output for Demo 3, verbatim from `demos/3-term.txt`,
// produced by tools/capture-terminal.sh against the real `sbt compile`.
// Fallback, and the freeze-frame to read the error from.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 3 · recorded · 2 of 2], style: "bad"),
  body-gap: sz(30pt),
  [The level is in the type of the evidence],
  stack(
    dir: ttb,
    spacing: sz(34pt),
    terminal-pane(read("../../demos/3-term.txt").trim(), title: "bash", size: 19pt),
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      #set par(leading: 0.55em)
      The first demo made Bob write the medium-risk case. This one makes the
      medium-risk case do the medium-risk thing.
    ],
  ),
)

#speaker-note[
Read the two lines off the screen, unhurried:

»Found: AutoApproved. Required: an Approval of MediumRisk.«

Leave `.type` unread — it is the singleton type of the `case object` and it
teaches nothing here.

Beat. Then:

»The first demo made Bob write the medium-risk case. This one makes the
medium-risk case do the medium-risk thing, and the whole mechanism is that one
parameter on Approval.«

Then put the proof back, recompile, green. Say nothing.
]
