// A5-demo5-out · captured output for Demo 5, verbatim from `demos/5-term.txt`,
// produced by tools/capture-terminal.sh against the real `idris2 --build`.
// Fallback, and the freeze-frame to read the error from.
//
// Read BOTH lines: the compiler points at the BINDING, not at the missing call
// — it is counting a variable, not looking for a `finish` — and its own
// suggestion line states the rule in plain English better than a paraphrase.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 5 · recorded · 2 of 2], style: "bad"),
  body-gap: sz(28pt),
  [The compiler counts],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    terminal-pane(read("../../demos/5-term.txt").trim(), title: "bash", size: 18pt),
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      #set par(leading: 0.55em)
      The compiler counted the uses of one variable and got zero.
    ],
  ),
)

#speaker-note[
Read both lines off the screen, unhurried. Say »zero uses« for `0 uses`:

»There are zero uses of linear name done.«
»Linearly bounded variables must be used exactly once.«

Beat. Then:

»The compiler counted the uses of one variable, got zero, and refused to build
the program — and that is the last of the four accounted for.«

Then put `finish done` back, rebuild, green. Say nothing.
]
