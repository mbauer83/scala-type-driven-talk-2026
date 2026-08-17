// A1-quantifiers · cap 1:05 · Act 1 beat 3 of 6
// ∀ mirrored by a generic method. ∃ is NAMED but deliberately given no Java
// mirror: Optional[T] is T ∨ 1, a disjunction, and the Curry-Howard reading of
// ∃ is a dependent pair — which A1-above introduces as Σ and Stage 6 shows
// Java cannot express. See the FACTS block in scripts/06-quantifiers.md.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#theory-slide(
  eyebrow: eyebrow([Frege · Begriffsschrift · 1879], style: "accent"),
  [Propositions with holes in them],
  [
    #v(sz(16pt))
    #align(center)[
      #text(font: mono-font, size: sz(40pt), fill: pal.fg)[
        ∀o. #h(sz(6pt)) medium(o) → needs3DS(o)
      ]
      #v(sz(10pt))
      #text(size: sz(26pt), fill: pal.fg-dim)[
        one statement, covering every order that will ever exist
      ]
    ]
    #v(sz(46pt))
    #grid(
      columns: (1fr, sz(560pt)),
      column-gutter: sz(44pt),
      align: (left + horizon, left + horizon),
      [
        #set text(size: sz(29pt), fill: pal.fg)
        #set par(leading: 0.45em)
        A generic method makes a claim about
        #text(fill: pal.accent, weight: 500)[every type it will ever be applied to] —
        including types nobody has written yet.
        #v(sz(14pt))
        #set text(size: sz(25pt), fill: pal.fg-dim)
        Proved once, in one place. The compiler holds you to it everywhere.
      ],
      code-pane(filename: "Validator.java", language: "java", code-size: 19pt)[
```java
static <T> Validator<T> check(Predicate<T> p, String msg)
```
      ],
    )
    #v(sz(30pt))
    #align(center)[
      #text(size: sz(23pt), fill: pal.fg-faint)[
        #text(font: mono-font)[∃] — "there is one" — is the other quantifier. It needs more than Java has; we come back to it.
      ]
    ]
  ],
  footer: act1-rail(lit: ("Frege",)),
)

#speaker-note[
#read("../scripts/06-quantifiers.md")
]
