// Three changes:  1. The program-level / type-level distinction has moved to
// `A1-connectives`, where Java first appears, and is made once for the whole
// act. This slide no longer teaches two things at once. 2. The values rung
// loses its code pane and becomes a one-line concession. 3. **Generics arrive
// bounded.** An unbounded `T` is barely useful, so showing one bare and adding
// bounds as an afterthought teaches the wrong default. The bound is explained
// by the shape the room already has: `∀ T. comparable(T) → …` is a universally
// quantified conditional, exactly like Aristotle's "all medium-risk orders
// need 3DS" on the slide two beats back. A bound is the *if*. The repo's real
// bounded generic is `Payment<S extends PaymentState>`
// (04-…-typestate/Payment.java:20), deliberately not spent here: A3-stage4
// needs it, and `Comparable` shows you getting an operation back, which a
// marker interface cannot.
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
      then say what holds for every value it could take. Every method signature
      you write already does that, and a generic moves the variable
      #text(fill: pal.fg, weight: 500)[one level up], so it ranges over types.
      #v(sz(14pt))
      #align(center)[
        #text(font: mono-font, size: sz(26pt), fill: pal.fg)[
          ∀ o : Order. #h(sz(10pt)) assessRisk(o) : RiskDecision
        ]
      ]
    ]
    #v(sz(58pt))
    #grid(
      columns: (1fr, sz(760pt)),
      column-gutter: sz(48pt),
                  align: (left + top, left + top),
            [
                // Top-aligned columns already put this signature on the Java line's
        // baseline; padding by the card inset overshot by exactly that inset.
        #text(font: mono-font, size: sz(27pt), fill: pal.fg)[
          max : #h(sz(8pt)) ∀ T. #h(sz(8pt)) comparable(T) #h(sz(8pt)) ⇒ #h(sz(8pt)) T × T → T
        ]
        #v(sz(22pt))
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #set text(size: sz(23pt), fill: pal.fg-dim)
        Read it left to right: #emph[for any type T, provided T can be compared, take
two Ts and give back a T]. The double arrow is the #text(font: mono-font)[if] —
the same shape as _all medium-risk orders need 3DS_, two slides ago.
      ],
      stack(
        dir: ttb,
        spacing: sz(18pt),
        shape-card[
          #raw(block: true, "static <T extends Comparable<T>> T max(T a, T b)")
        ],
        block[
          #set text(size: sz(23pt), fill: pal.fg-dim)
          #set par(leading: 0.45em)
          The bound is the #text(fill: pal.fg, weight: 500)[if]. Strip it off and
          there is nothing the body can do with a `T` at all — no comparing, and
          so no `max`.
        ],
      ),
    )
    #v(sz(64pt))
    #align(right)[
            #text(size: sz(24pt), fill: pal.fg-dim)[
        #text(font: mono-font)[∃] — the other quantifier. Java's wildcards
        (`List<?>`) are a restricted form of it; the strong version — a value
        handed to you together with evidence about it — we come back to.
      ]
    ]
  ],
  footer: act1-rail(lit: ("Frege",)),
)

#speaker-note[
#read("../scripts/06-quantifiers.md")
]
