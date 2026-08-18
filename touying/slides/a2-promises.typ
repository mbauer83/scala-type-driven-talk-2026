// A2-promises · cap 1:05 · Act 2 beat 3 of 3 · NEW
//
// Cashes out A1-crisis for practitioners: Hilbert's three requirements, said
// once in Act 1 as a list, now read off against the thing in the room. This
// slide was agreed in review, the budget was raised to make space for it, and
// then it was never added — see Part 3.
//
// Two things must land, and one correction must not be lost:
//   1. Completeness is given up for DECIDABILITY, and that is Rice's theorem,
//      not Gödel. Conflating the two is a real error and someone in the room
//      may know it (Part 8/C8).
//   2. Soundness is bounded by the escape hatches you use. Java's array-store
//      hole is the honest evidence, and it is Java's own.
//
// Do NOT claim the audience feels incompleteness daily — MB's experience is
// that they do not, because when the compiler says no it is usually right. You
// feel it when you try to encode a STRONGER invariant, which is the cost this
// talk asks them to weigh. That hands off to A6-cost.
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
  eyebrow: eyebrow([Hilbert's three, cashed out], style: "normal"),
  [What a type checker actually promises],
  [
    #v(sz(10pt))
    #grid(
      columns: (sz(230pt), sz(500pt), 1fr),
      column-gutter: sz(36pt),
      row-gutter: sz(18pt),
      align: (left + top, left + top, left + top),
      stroke: (x, y) => if y == 0 { (bottom: 0.5pt + pal.rule-strong) } else { none },
      inset: (bottom: sz(10pt)),

      text(size: sz(20pt), fill: pal.fg-faint)[],
      text(font: mono-font, size: sz(20pt), fill: pal.fg-faint)[IN LOGIC],
      text(font: mono-font, size: sz(20pt), fill: pal.fg-faint)[IN YOUR TYPE CHECKER],

      ..promise-row([consistent],
        [never derives a contradiction],
        [no well-typed program can produce a value of an impossible type]),
      ..promise-row([sound],
        [provable ⟹ true],
        [if it compiles, the property holds]),
      ..promise-row([complete],
        [true ⟹ provable],
        [every safe program is accepted #h(sz(12pt))
         #text(fill: pal.bad, weight: 500)[— deliberately given up]], dim: true),
    )
    #v(sz(30pt))
    #grid(
      columns: (1fr, sz(760pt)),
      column-gutter: sz(44pt),
      align: (left + top, left + top),
      [
        #text(size: sz(24pt), weight: 600, fill: pal.fg)[Given up for decidability — and that is Rice, not Gödel]
        #v(sz(10pt))
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        Every non-trivial semantic property of programs is undecidable, so a
        checker that always terminates has to approximate — and it approximates on
        the safe side, rejecting some programs that would in fact have been fine.
        #v(sz(14pt))
        #text(size: sz(24pt), weight: 600, fill: pal.fg)[Soundness is bounded by the hatches you use]
        #v(sz(10pt))
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        `null`, unchecked casts, Scala's `asInstanceOf`, Idris's `believe_me` —
        and one hole that is Java's own:
      ],
      stack(
        dir: ttb,
        spacing: sz(14pt),
        // Held down so the pane sits level with "Soundness is bounded…", which
        // is the sentence it is evidence for.
        v(sz(158pt)),
        code-pane(filename: "ArrayStore.java", language: "java", code-size: 17pt, pad-y: 12pt)[
```java
Object[] arr = new String[1];
arr[0] = 42;      // compiles → ArrayStoreException
```
        ],
        block[
          #set text(size: sz(23pt), fill: pal.fg-dim)
          #set par(leading: 0.45em)
          You will not feel the missing completeness on a normal Tuesday — when the
          compiler says no, it is usually right. You feel it the moment you try to
          encode a #text(fill: pal.fg, weight: 500)[stronger] invariant, and what
          that costs is the last question of the talk.
        ],
      ),
    )
  ],
)

#speaker-note[
#read("../scripts/11-promises.md")
]
