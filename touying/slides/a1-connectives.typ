// A1-connectives · cap 1:20 · Act 1 beat 2 of 6
// The highest-risk slide in the deck for C13. The sealed interface DECLARES the
// disjunction; the match ELIMINATES it. Both halves are on screen, labelled.
// Java is verbatim from 03-java-function-types-sealed/RiskDecision.java:9-13.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#theory-slide(
  eyebrow: eyebrow([Leibniz · Boole 1847 · Frege 1879], style: "accent"),
  [Logic becomes something you can calculate],
  [
    #v(sz(10pt))
    #grid(
      columns: (sz(360pt), 1fr),
      column-gutter: sz(44pt),
      align: (left + top, left + top),

      // ── left: the two connectives, named
      stack(
        dir: ttb,
        spacing: sz(30pt),
        [
          #text(font: mono-font, size: sz(46pt), fill: pal.accent)[∨]
          #v(sz(4pt))
          #text(size: sz(27pt), fill: pal.fg)[exactly one of them holds]
          #v(sz(2pt))
          #text(size: sz(23pt), fill: pal.fg-dim)[a *disjunction*]
        ],
        line(length: 100%, stroke: 0.5pt + pal.rule),
        [
          #text(font: mono-font, size: sz(46pt), fill: pal.accent)[∧]
          #v(sz(4pt))
          #text(size: sz(27pt), fill: pal.fg)[all of them hold at once]
          #v(sz(2pt))
          #text(size: sz(23pt), fill: pal.fg-dim)[a *conjunction*]
        ],
      ),

      // ── right: the same two things, in their code
      stack(
        dir: ttb,
        spacing: sz(14pt),
        code-pane(filename: "RiskDecision.java", language: "java", code-size: 19pt)[
```java
public sealed interface RiskDecision
    permits RiskDecision.Low, RiskDecision.Medium, RiskDecision.High {

    record Low()    implements RiskDecision {}
    record Medium() implements RiskDecision {}
    record High()   implements RiskDecision {}
}
```
        ],
        align(right)[
          #text(size: sz(22pt), fill: pal.accent, weight: 500)[↑ the proposition]
        ],
        code-pane(filename: "Demo.java", language: "java", code-size: 19pt)[
```java
switch (risk) {
    case Low    l -> …
    case Medium m -> …
    case High   h -> …          // omit one → does not compile
}
```
        ],
        align(right)[
          #text(size: sz(22pt), fill: pal.accent, weight: 500)[↑ the proof step]
        ],
      ),
    )
  ],
  footer: act1-rail(lit: ("Leibniz", "Boole", "Frege")),
)

#speaker-note[
#read("../scripts/05-connectives.md")
]
