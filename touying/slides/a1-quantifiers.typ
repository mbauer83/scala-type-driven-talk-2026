// A1-quantifiers · cap 1:05 · Act 1 beat 3 of 6
//
// THIRD BUILD, 18 Aug. MB: still unhappy with the second. Three changes:
//
//  1. The program-level / type-level distinction has moved to `A1-connectives`,
//     where Java first appears, and is made once for the whole act. This slide
//     no longer teaches two things at once.
//  2. The values rung loses its code pane and becomes a one-line concession.
//     MB's objection stands and must be answered — `assessRisk(Order order)` IS
//     ∀o:Order, so presenting ∀ as new tells the room nothing — but answering it
//     costs a clause, not half a slide.
//  3. **Generics arrive bounded.** An unbounded `T` is barely useful, so showing
//     one bare and adding bounds as an afterthought teaches the wrong default.
//
// The bound is explained by the shape the room already has: `∀ T. comparable(T)
// → …` is a universally quantified conditional, exactly like Aristotle's "all
// medium-risk orders need 3DS" on the slide two beats back. A bound is the *if*.
//
// The Java is illustrative and rendered as a card, not a file — same treatment,
// and for the same reason, as `RefundRule` on `A1-connectives` (Part 12/R9).
// The repo's real bounded generic is `Payment<S extends PaymentState>`
// (04-…-typestate/Payment.java:20), deliberately not spent here: A3-stage4 needs
// it, and `Comparable` shows you getting an operation back, which a marker
// interface cannot.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let shape-card(body) = block(
  width: 100%,
  fill: pal.bg-dark-2,
  stroke: 0.5pt + pal.rule-dark-strong,
  radius: sz(6pt),
  inset: (x: sz(26pt), y: sz(20pt)),
)[
  #show raw: set text(font: mono-font, size: sz(21pt), fill: pal.fg-dark)
  #set par(leading: 0.62em)
  #body
]

#theory-slide(
  eyebrow: eyebrow([Frege · Begriffsschrift · 1879], style: "accent"),
  [Quantifiers, and what they range over],
  body-gap: sz(34pt),
  [
    #block(width: 100%)[
      #set text(size: sz(25pt), fill: pal.fg-dim)
      #set par(leading: 0.5em)
      Frege's move: let a proposition contain a #text(fill: pal.fg, weight: 500)[variable],
      then say what holds for every value it could take. Every signature you write
      already does that —
      #text(font: mono-font, size: sz(23pt), fill: pal.fg)[∀ o : Order. assessRisk(o) : RiskDecision].
      A generic moves the variable #text(fill: pal.fg, weight: 500)[one level up],
      so it ranges over types.
    ]
    #v(sz(58pt))
    #grid(
      columns: (1fr, sz(760pt)),
      column-gutter: sz(48pt),
      align: (left + top, left + top),
      [
        #text(font: mono-font, size: sz(28pt), fill: pal.fg)[
          ∀ T. #h(sz(10pt)) comparable(T) #h(sz(6pt)) →
        ]
        #v(sz(6pt))
        #text(font: mono-font, size: sz(28pt), fill: pal.fg)[
          #h(sz(48pt)) ( List\<T\> → T )
        ]
        #v(sz(20pt))
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #set text(size: sz(23pt), fill: pal.fg-dim)
        The same shape as _all medium-risk orders need 3DS_ two slides ago:
        a for-all with an #text(font: mono-font)[if] inside it.
      ],
      stack(
        dir: ttb,
        spacing: sz(18pt),
        shape-card[
          #raw(block: true, "static <T extends Comparable<T>> T max(List<T> xs)")
        ],
        block[
          #set text(size: sz(23pt), fill: pal.fg-dim)
          #set par(leading: 0.45em)
          The bound is the #text(fill: pal.fg, weight: 500)[if]. It says which
          types the claim covers — everything at or below `Comparable<T>` — and it
          is what hands `compareTo` back to the body. A language without
          subtyping does the same job with a typeclass constraint.
        ],
      ),
    )
    #v(sz(64pt))
    #align(right)[
      #text(size: sz(21pt), fill: pal.fg-faint)[
        #text(font: mono-font)[∃] — the other quantifier. Java's wildcards
        (`List<?>`) are a restricted form of it; the strong version, a value
        handed to you together with evidence about it, comes back at the top.
      ]
    ]
  ],
  footer: act1-rail(lit: ("Frege",)),
)

#speaker-note[
#read("../scripts/06-quantifiers.md")
]
