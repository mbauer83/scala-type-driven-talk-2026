// A1-connectives · cap 1:20 · Act 1 beat 2 of 6
// The highest-risk slide in the deck for C13. The sealed interface DECLARES the
// disjunction; the match ELIMINATES it. Both halves are on screen, labelled.
// Java is verbatim from 03-java-function-types-sealed/RiskDecision.java:9-13.
//
// Part 10 rebuild, two corrections:
//   · F1 — the arithmetic turn buys CALCULABILITY, not checkability. Aristotle
//     already made inference checkable by inspection; the top line says so.
//   · layout — both panes are the same ∨ (declaration and use). `∧` used to sit
//     level with the lower pane, which made the layout claim the lower pane was
//     the conjunction. `∧` is now a strip beneath both, pointing back up at the
//     records, and the ∨ card names both panes as one connective.
//
// The two role labels sit BESIDE their pane rather than under it: stacked under
// each pane they cost two rows the slide does not have, and the arrow had to
// point up through the caption of the pane below.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let role(body) = text(size: sz(22pt), fill: pal.accent, weight: 500)[#body #h(sz(4pt)) →]

#theory-slide(
  eyebrow: eyebrow([Leibniz · Boole 1847 · Frege 1879], style: "accent"),
  [Logic becomes something you can calculate],
  [
    #v(sz(2pt))
    #block(width: 100%)[
      #set text(size: sz(23pt), fill: pal.fg-dim)
      Aristotle's shapes could already be checked by eye. What the algebra adds is
      that you can #text(fill: pal.fg, weight: 500)[compute] with them.
    ]
    #v(sz(8pt))
    #grid(
      columns: (sz(340pt), sz(220pt), 1fr),
      column-gutter: sz(24pt),
      row-gutter: sz(10pt),
      align: (left + horizon, right + horizon, left + horizon),

      // ── left: ONE connective, covering both panes
      grid.cell(rowspan: 2)[
        #stack(
          dir: ttb,
          spacing: sz(8pt),
          text(font: mono-font, size: sz(52pt), fill: pal.accent)[∨],
          v(sz(2pt)),
          text(size: sz(27pt), fill: pal.fg)[exactly one of them holds],
          text(size: sz(23pt), fill: pal.fg-dim)[a *disjunction*],
          v(sz(14pt)),
          line(length: 100%, stroke: 0.5pt + pal.rule),
          v(sz(8pt)),
          block[
            #set text(size: sz(22pt), fill: pal.fg-dim)
            #set par(leading: 0.45em)
            Both panes are this one connective — once where it is
            #text(fill: pal.fg)[declared], once where it is #text(fill: pal.fg)[used].
          ],
        )
      ],

      // ── right: the same connective, in their code
      role[the proposition],
      code-pane(filename: "RiskDecision.java", language: "java", code-size: 14pt, pad-y: 8pt)[
```java
public sealed interface RiskDecision
    permits RiskDecision.Low, RiskDecision.Medium, RiskDecision.High {

    record Low()    implements RiskDecision {}
    record Medium() implements RiskDecision {}
    record High()   implements RiskDecision {}
}
```
      ],

      role[the proof step],
      code-pane(filename: "Demo.java", language: "java", code-size: 14pt, pad-y: 8pt)[
```java
switch (risk) {
    case Low    l -> …
    case Medium m -> …
    case High   h -> …          // omit one → does not compile
}
```
      ],
    )
    #v(sz(14pt))
    #grid(
      columns: (sz(340pt), 1fr),
      column-gutter: sz(24pt),
      align: (left + horizon, left + top),
      grid(
        columns: (sz(52pt), 1fr),
        column-gutter: sz(12pt),
        align: (left + horizon, left + horizon),
        text(font: mono-font, size: sz(34pt), fill: pal.accent)[∧],
        text(size: sz(22pt), fill: pal.fg-dim)[a *conjunction*],
      ),
      [
        #set text(size: sz(23pt), fill: pal.fg)
        #set par(leading: 0.45em)
        And each `record` up there is the other connective — every field at once.
        #v(sz(4pt))
        #set text(size: sz(21pt), fill: pal.fg-dim)
        None of this is `if (a && b)` — a boolean is computed while the program runs;
        these shapes are fixed before it runs at all.
      ],
    )
  ],
  footer: act1-rail(lit: ("Leibniz", "Boole", "Frege")),
)

#speaker-note[
#read("../scripts/05-connectives.md")
]
