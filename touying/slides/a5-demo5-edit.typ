// A5-demo5-edit · recorded terminal frame 1 of 2 — the edit.
// Verbatim from demos/5-edit.txt, produced by tools/capture-terminal.sh.
// Advance past it in a second when the live demo worked; it IS the demo when
// the live one did not.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 5 · recorded · 1 of 2], style: "bad"),
  body-gap: sz(30pt),
  [The close goes away],
  terminal-pane(read("../../demos/5-edit.txt").trim(), title: "06-idris2-payment", size: 19pt),
)

#speaker-note[
Advance past this in a second: »The close is gone.«
If the live edit never happened, this IS the edit.
]
