// A3-demo1-out · Act 3 · the captured output for Demo 1
//
// Doubles as fallback and as the freeze-frame the error is read aloud from.
// Text is verbatim from `demos/1-exhaustiveness.txt`, produced by
// `tools/capture-demos.sh` against the real compiler.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 1 · recorded · 2 of 2], style: "bad"),
  body-gap: sz(30pt),
  [∨E, in the compiler's own words],
  stack(
    dir: ttb,
    spacing: sz(34pt),
    terminal-pane(read("../../demos/1-term.txt").trim(), title: "bash", size: 19pt),
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      #set par(leading: 0.55em)
      Gentzen's elimination rule, sixty seconds old, coming out of `javac`:
      you may not use a disjunction without covering every side of it.
    ],
  ),
)

#speaker-note[
Read it off the screen, verbatim and unhurried:

"The switch expression does not cover all possible input values."

Beat. Then one sentence and no more:

"That is Gentzen's elimination rule, sixty seconds old, coming out of javac."

Then undo in the IDE, recompile, let the room see it go green. Say nothing.
]
