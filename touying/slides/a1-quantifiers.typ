// A1-quantifiers · cap 1:05 · Act 1 beat 3 of 6
//
// Part 10 rebuild. The slide used to present ∀ as new, and MB's review is that
// it is not: `all medium-risk orders need 3DS` on A1-aristotle already quantifies
// universally. The slide now concedes that first — Aristotle's form sits on the
// left, Frege's on the right — and then names the three things binding a
// variable actually buys.
//
// ∃ is NAMED but deliberately given no Java mirror: Optional[T] is T ∨ 1, a
// disjunction, and the Curry-Howard reading of ∃ is a dependent pair — which
// A1-above introduces as Σ and Stage 6 shows Java cannot express. See the FACTS
// block in scripts/06-quantifiers.md.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let adds(n, head, body) = grid(
  columns: (sz(40pt), 1fr),
  column-gutter: sz(14pt),
  align: (right + top, left + top),
  text(font: mono-font, size: sz(22pt), fill: pal.accent)[#n],
  stack(
    dir: ttb,
    spacing: sz(6pt),
    text(size: sz(25pt), weight: 500, fill: pal.fg)[#head],
    block[
      #set text(size: sz(22pt), fill: pal.fg-dim)
      #set par(leading: 0.45em)
      #body
    ],
  ),
)

#theory-slide(
  eyebrow: eyebrow([Frege · Begriffsschrift · 1879], style: "accent"),
  [You have already seen a quantifier],
  [
    #v(sz(26pt))
    #grid(
      columns: (1fr, sz(70pt), 1fr),
      column-gutter: sz(20pt),
      align: (center + horizon, center + horizon, center + horizon),
      stack(
        dir: ttb,
        spacing: sz(10pt),
        text(font: mono-font, size: sz(34pt), fill: pal.fg-dim)[All M are T],
        text(size: sz(21pt), fill: pal.fg-faint)[Aristotle — the *all* is built into the form],
      ),
      text(size: sz(30pt), fill: pal.fg-faint)[→],
      stack(
        dir: ttb,
        spacing: sz(10pt),
        text(font: mono-font, size: sz(34pt), fill: pal.fg)[∀o. #h(sz(6pt)) medium(o) → needs3DS(o)],
        text(size: sz(21pt), fill: pal.fg-faint)[Frege — the *all* is a part you can get hold of],
      ),
    )
    #v(sz(44pt))
    #line(length: 100%, stroke: 0.5pt + pal.rule)
    #v(sz(34pt))
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: sz(34pt),
      adds([1], [It binds a variable],
           [So you can nest one quantifier inside another, and put a negation between them.]),
      adds([2], [It ranges over anything],
           [Not a term in a fixed scheme — every order that will ever exist, including tonight's.]),
      adds([3], [It has a partner],
           [#text(font: mono-font)[∃] — _there is one_. Java has no honest way to write that; we come back to it.]),
    )
    #v(sz(56pt))
    #grid(
      columns: (1fr, sz(780pt)),
      column-gutter: sz(40pt),
      align: (left + horizon, left + horizon),
      [
        #set text(size: sz(26pt), fill: pal.fg)
        #set par(leading: 0.45em)
        You write the universal already — and
        #text(fill: pal.accent, weight: 500)[the signature is the claim,
        the body is what makes good on it.]
      ],
      code-pane(filename: "Validator.java", language: "java", code-size: 16pt)[
```java
static <T> Validator<T> check(Predicate<T> p, String msg)
```
      ],
    )
  ],
  footer: act1-rail(lit: ("Frege",)),
)

#speaker-note[
#read("../scripts/06-quantifiers.md")
]
