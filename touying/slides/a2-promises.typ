// That is horrific"; the array-covariance passage "barely coherent and doesn't
// seem to fit". All three land. The Rice/Gödel line was a correction addressed
// to a heckler who does not exist. Nobody in the room cares which theorem
// bounds the checker; they care that it says no to code they know is fine.
// Verified against javac 21.0.11: `f` fails with "missing return statement",
// `g` compiles. Exhaustive, safe, rejected — and then accepted, four Java
// versions later, which is the boundary moving in front of them. Rice,
// decidability and array covariance are all in the script's PREPARATION block
// for Q&A. None of it is spoken.
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
  eyebrow: eyebrow([Hilbert's three, about your compiler], style: "normal"),
  [What a type checker actually promises],
  body-gap: sz(44pt),
  [
    #grid(
      columns: (sz(230pt), sz(470pt), 1fr),
      column-gutter: sz(36pt),
      row-gutter: sz(26pt),
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
    #v(sz(30pt))
    #grid(
      columns: (1fr, 1fr),
      column-gutter: sz(40pt),
      row-gutter: sz(22pt),
      align: (left + top, left + top),

      text(size: sz(23pt), fill: pal.fg-dim)[
        a switch #text(weight: 600, fill: pal.bad)[statement] — exhaustive, safe, rejected
      ],
      text(size: sz(23pt), fill: pal.fg-dim)[
        the same three cases as a switch #text(weight: 600, fill: pal.good)[expression]
      ],

      code-pane(filename: "Colour.java", language: "java", code-size: 18pt, pad-y: 10pt)[
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
      code-pane(filename: "Colour.java", language: "java", code-size: 18pt, pad-y: 10pt)[
```java
int g(Colour c) {
    return switch (c) {
        case RED   -> 1;
        case GREEN -> 2;
        case BLUE  -> 3;
    };
}   // compiles — Java 14
```
      ],
    )
    #v(sz(22pt))
    #align(center)[
      #set text(size: sz(25pt), fill: pal.fg)
      Identical logic. A check that has to terminate has to approximate — and in
      2014 Java made the approximation a good deal less conservative.
    ]
  ],
)

#speaker-note[
#read("../scripts/11-promises.md")
]
