// A3-demo2-edit · recorded terminal frame 1 of 2 — the edit.
// Verbatim from demos/2-edit.txt, produced by tools/capture-terminal.sh.
// Advance past it in a second when the live demo worked; it IS the demo when
// the live one did not.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 2 · recorded · 1 of 2], style: "bad"),
  body-gap: sz(30pt),
  [The commented line comes back],
  terminal-pane(read("../../demos/2-edit.txt").trim(), title: "04-java-advanced-generics-typestate", size: 19pt),
)

#speaker-note[
Advance past this in a second: »The line is back.«
If the live edit never happened, this IS the edit.
]
