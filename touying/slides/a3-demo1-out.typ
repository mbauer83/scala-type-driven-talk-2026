// A3-demo1-out · Act 3 · the captured output for Demo 1
//
// Doubles as fallback and as the freeze-frame the error is read aloud from.
// Text is verbatim from `demos/1-exhaustiveness.txt`, produced by
// `tools/capture-demos.sh` against the real compiler.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 1 · javac], style: "bad"),
  body-gap: sz(26pt),
  [∨E, in the compiler's own words],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    code-pane(
      filename: "Demo.java", language: "java", code-size: 20pt, pad-y: 12pt,
      diagnostic: ("bad",
        "Demo.java:121: error",
        [the switch expression does not cover all possible input values]),
    )[
```java
String label = switch (decision) {
    case RiskDecision.Low    l -> "low-risk fast path";
    case RiskDecision.High   h -> "high-risk review path";
};
```
    ],
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      Gentzen's elimination rule, sixty seconds old, enforced by `javac`:
      you may not use a disjunction without covering every side of it.
    ],
  ),
)

#speaker-note[
#read("../scripts/15-demo1.md")
]
