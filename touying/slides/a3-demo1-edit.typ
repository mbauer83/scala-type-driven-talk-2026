// A3-demo1-edit · recorded terminal frame 1 of 2 — the edit.
// Verbatim from demos/1-edit.txt, produced by tools/capture-terminal.sh.
// Advance past it in a second when the live demo worked; it IS the demo when
// the live one did not.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 1 · recorded · 1 of 2], style: "bad"),
  body-gap: sz(30pt),
  [the switch loses a case],
  terminal-pane(read("../../demos/1-edit.txt").trim(), title: "03-java-function-types-sealed", size: 19pt),
)

#speaker-note[
Advance past this in a second: »There is the line, gone.«
If the live edit never happened, this IS the edit — same sentence, no comment.
]
