// A2-promises · cap 1:05 · Act 2 beat 2 of 2
//
// REBUILT 18 Aug. MB: "convoluted, and shows the revision history in terms of
// reading like the result of an argument"; "'and that's Rice, not Gödel' — are
// you serious? That is horrific"; the array-covariance passage "barely coherent
// and doesn't seem to fit". All three land.
//
// The Rice/Gödel line was a correction addressed to a heckler who does not
// exist. Nobody in the room cares which theorem bounds the checker; they care
// that it says no to code they know is fine. So the slide answers MB's actual
// question — WHERE, in Java, is completeness noticeably given up — with a
// program every one of them has written and had rejected.
//
// Verified against javac 21.0.11: `f` fails with "missing return statement",
// `g` compiles. Exhaustive, safe, rejected — and then accepted, four Java
// versions later, which is the boundary moving in front of them.
//
// Rice, decidability and array covariance are all in the script's PREPARATION
// block for Q&A. None of it is spoken.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let promise-row(name, logic, checker, dim: false) = (
  text(font: mono-font, size: sz(26pt), weight: 500,
       fill: if dim { pal.fg-faint } else { pal.fg })[#name],
  text(size: sz(24pt), fill: if dim { pal.fg-faint } else { pal.fg-dim })[#logic],
  text(size: sz(24pt), fill: if dim { pal.fg-faint } else { pal.fg })[#checker],
)

#theory-slide(
  eyebrow: eyebrow([The same questions, for your compiler], style: "normal"),
  [What a type checker actually promises],
  body-gap: sz(30pt),
  [
    #grid(
      columns: (sz(230pt), sz(470pt), 1fr),
      column-gutter: sz(36pt),
      row-gutter: sz(16pt),
      align: (left + top, left + top, left + top),
      stroke: (x, y) => if y == 0 { (bottom: 0.5pt + pal.rule-strong) } else { none },
      inset: (bottom: sz(9pt)),

      text(size: sz(20pt), fill: pal.fg-faint)[],
      text(font: mono-font, size: sz(20pt), fill: pal.fg-faint)[IN LOGIC],
      text(font: mono-font, size: sz(20pt), fill: pal.fg-faint)[IN YOUR TYPE CHECKER],

      ..promise-row([consistent], [never derives a contradiction],
        [no well-typed program produces a value of an impossible type]),
      ..promise-row([sound], [provable ⟹ true],
        [if it compiles, the property holds — as far as the escape hatches let it]),
      ..promise-row([complete], [true ⟹ provable],
        [every safe program is accepted #h(sz(10pt))
         #text(fill: pal.bad, weight: 500)[— given up, on purpose]], dim: true),
    )
    #v(sz(34pt))
    #grid(
      columns: (sz(700pt), 1fr),
      column-gutter: sz(48pt),
      align: (left + top, left + top),
      code-pane(filename: "Colour.java", language: "java", code-size: 20pt, pad-y: 12pt)[
```java
int f(Colour c) {
    switch (c) {
        case RED:   return 1;
        case GREEN: return 2;
        case BLUE:  return 3;
    }
}   // error: missing return statement
```
      ],
      [
        #text(size: sz(26pt), weight: 600, fill: pal.fg)[This is where you feel it.]
        #v(sz(12pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.5em)
        Exhaustive. Safe. Rejected — because a check that always terminates has to
        approximate, and it approximates on the side that says no.
        #v(sz(16pt))
        #set text(size: sz(24pt), fill: pal.fg)
        Write it as a `switch` #emph[expression] and Java 14 accepts it.
        #text(fill: pal.fg-dim)[The boundary moves. That is the whole business
        this talk is about.]
      ],
    )
  ],
)

#speaker-note[
#read("../scripts/11-promises.md")
]
