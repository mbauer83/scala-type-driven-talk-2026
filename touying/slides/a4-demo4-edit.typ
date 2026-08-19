// A4-demo4-edit · recorded terminal frame 1 of 2 — the edit.
// Verbatim from demos/4-edit.txt, produced by tools/capture-terminal.sh.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 4 · recorded · 1 of 2], style: "bad"),
  body-gap: sz(30pt),
  [One side adds a step to the conversation],
  terminal-pane(read("../../demos/4-edit.txt").trim(), title: "05-scala3-payment", size: 19pt),
)

#speaker-note[
Advance past this in a second: »There it is — this side now waits for a
confirmation.«
If the live edit never happened, this IS the edit.
]
