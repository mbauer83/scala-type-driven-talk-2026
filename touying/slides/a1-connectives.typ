// A1-connectives · cap 1:20 · Act 1 beat 2 of 6
//
// REBUILT 18 Aug after MB's review. What was wrong with the previous version:
//   · ∨ got two code panes and ∧ got a trailing clause with no example — the
//     two connectives were not treated as two things
//   · a caption ("both panes are this one connective") existed only to explain
//     the layout, which means the layout was wrong
//   · the C13 guard was a disclaimer — "none of this is if (a && b)" — which
//     makes the audience hold the wrong idea in mind while you deny it
//
// The through-line that replaces all three: Boole turned logic into ALGEBRA.
// He wrote OR as `+` and AND as `×`, and those are still the names — sum type,
// product type — because the arithmetic is literal. Count the inhabitants.
// A slide about counting the values of a type cannot be confused with a slide
// about boolean control flow, so the disclaimer is unnecessary.
//
// It also carries F1: Aristotle's forms were already checkable by inspection;
// what the algebra adds is CALCULABILITY.
//
// Frege has moved off this slide entirely and onto A1-quantifiers, which is his
// beat. Two names here, not three.
//
// Introduction/elimination — the exhaustive match as ∨E — is NOT here. It is
// A3-gentzen's job, sixty seconds before the compile error it explains, which
// is the whole point of P2. This slide is formation: what the connectives build.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let connective(sym, alg, name, gloss) = stack(
  dir: ttb,
  spacing: sz(8pt),
  grid(
    columns: (auto, auto, auto, 1fr),
    column-gutter: sz(16pt),
    align: bottom,
    text(font: mono-font, size: sz(44pt), fill: pal.accent)[#sym],
    text(size: sz(30pt), fill: pal.fg-faint)[≡],
    text(font: mono-font, size: sz(40pt), fill: pal.accent)[#alg],
    text(size: sz(30pt), weight: 500, fill: pal.fg)[#h(sz(10pt)) #name],
  ),
  text(size: sz(24pt), fill: pal.fg-dim)[#gloss],
)

#theory-slide(
  eyebrow: eyebrow([Leibniz · Boole 1847], style: "accent"),
  [Logic becomes algebra],
  body-gap: sz(34pt),
  [
    #block(width: 100%)[
      #set text(size: sz(24pt), fill: pal.fg-dim)
      Boole made Aristotle's forms something you could
      #text(fill: pal.fg, weight: 500)[compute] with: OR became
      #text(font: mono-font, fill: pal.fg)[+], AND became
      #text(font: mono-font, fill: pal.fg)[×], and those are still the names.
    ]
    #v(sz(20pt))
    #grid(
      columns: (1.32fr, 1fr),
      column-gutter: sz(36pt),
      row-gutter: sz(12pt),
      align: (left + top, left + top),

      connective([∨], [+], [a sum], [one of the variants, and the compiler knows which]),
      connective([∧], [×], [a product], [every field, at once]),

      code-pane(filename: "RiskDecision.java", language: "java", code-size: 21pt, pad-y: 10pt)[
```java
public sealed interface RiskDecision
    permits RiskDecision.Low,
            RiskDecision.Medium,
            RiskDecision.High {

    record Low()    implements RiskDecision {}
    record Medium() implements RiskDecision {}
    record High()   implements RiskDecision {}
}
```
      ],
      code-pane(filename: "OrderLine.java", language: "java", code-size: 21pt, pad-y: 10pt)[
```java
public record OrderLine(
        String sku,
        int    unitPriceCents,
        int    quantity) { }
```
      ],

      text(size: sz(23pt), fill: pal.fg-faint)[
        #text(font: mono-font, fill: pal.accent)[3] values: #text(font: mono-font)[1 + 1 + 1]
      ],
      text(size: sz(23pt), fill: pal.fg-faint)[
        as many as #text(font: mono-font)[sku × price × quantity]
      ],
    )
    #v(sz(16pt))
    #line(length: 100%, stroke: 0.5pt + pal.rule)
    #v(sz(14pt))
    #grid(
      columns: (auto, 1fr),
      column-gutter: sz(40pt),
      align: (left + horizon, left + horizon),
      block[
        #set text(font: mono-font, size: sz(25pt), fill: pal.fg)
        PaymentMethod #h(sz(8pt)) = #h(sz(8pt))
        Card(String) #h(sz(6pt)) #text(fill: pal.accent)[+] #h(sz(6pt))
        Wallet(String) #h(sz(6pt)) #text(fill: pal.accent)[+] #h(sz(6pt))
        Invoice(String)
      ],
      block[
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        A sum whose variants are products — one sealed interface over three
        records. Most domain models are this shape.
      ],
    )
  ],
  footer: act1-rail(lit: ("Leibniz", "Boole")),
)

#speaker-note[
#read("../scripts/05-connectives.md")
]
