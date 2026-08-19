// What was wrong with the previous version: · ∨ got two code panes and ∧ got a
// trailing clause with no example — the two connectives were not treated as
// two things · a caption ("both panes are this one connective") existed only
// to explain the layout, which means the layout was wrong · the C13 guard was
// a disclaimer — "none of this is if (a && b)" — which makes the audience hold
// the wrong idea in mind while you deny it  The through-line that replaces all
// three: Boole turned logic into ALGEBRA. He wrote OR as `+` and AND as `×`,
// and those are still the names — sum type, product type — because the
// arithmetic is literal. Count the inhabitants. A slide about counting the
// values of a type cannot be confused with a slide about boolean control flow,
// so the disclaimer is unnecessary. It also carries F1: Aristotle's forms were
// already checkable by inspection; what the algebra adds is CALCULABILITY.
// Frege has moved off this slide entirely and onto A1-quantifiers, which is
// his beat. Two names here, not three. Introduction/elimination — the
// exhaustive match as ∨E — is NOT here. It is A3-gentzen's job, sixty seconds
// before the compile error it explains, which is the whole point of P2. This
// slide is formation: what the connectives build.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let connective(sym, alg, name, gloss) = stack(
  dir: ttb,
  spacing: sz(18pt),
  grid(
    columns: (auto, auto, auto, 1fr),
    column-gutter: sz(16pt),
    align: horizon,
    text(font: mono-font, size: sz(42pt), fill: pal.accent)[#sym],
    text(size: sz(32pt), fill: pal.fg-faint)[≡],
    text(font: mono-font, size: sz(40pt), fill: pal.accent)[#alg],
    text(size: sz(30pt), weight: 500, fill: pal.fg)[#h(sz(10pt)) #name],
  ),
  text(size: sz(24pt), fill: pal.fg-dim)[#gloss],
)

#theory-slide(
  eyebrow: eyebrow([Leibniz · Boole 1847], style: "accent"),
  [Logic becomes algebra],
    body-gap: sz(18pt),
  [
    #block(width: 100%)[
      #set text(size: sz(24pt), fill: pal.fg-dim)
      Boole made Aristotle's forms something you could
      #text(fill: pal.fg, weight: 500)[compute] with: OR became
      #text(font: mono-font, fill: pal.fg)[+], AND became
      #text(font: mono-font, fill: pal.fg)[×], and there is a mathematical reason
      for that. You know both already, as `||` and `&&` over booleans. Here they
      are over #text(fill: pal.fg, weight: 500)[types].
    ]
        #v(sz(2pt))
    #grid(
      columns: (1.32fr, 1fr),
      column-gutter: sz(36pt),
      row-gutter: sz(10pt),
      align: (left + top, left + top),

      connective([∨], [+], [a sum], [one of the variants, and the compiler knows which]),
      connective([∧], [×], [a product], [every field, at once]),

      code-pane(filename: "RiskDecision.java", language: "java", code-size: 18pt, pad-y: 6pt)[
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
      // NOT a code-pane: no filename tab, no gutter, no syntax colour. This is a
      // shape, not a file. `RiskDecision` and `RefundMechanism` are both real
      // (RiskDecision.java, RefundMechanism.java); `RefundRule` is the
      // illustrative wrapper that makes the arithmetic visible.
      //
      // The previous example was the real `OrderLine(String, int, int)`. It was
      // verbatim and it was useless here: |String| is unbounded, so "count the
      // values" — the only thing this slide is doing — could not be carried out.
      // Two small real sealed types multiply to six, which can.
      stack(
        dir: ttb,
        spacing: sz(18pt),
        block(
          width: 100%,
          fill: pal.bg-dark-2,
          stroke: 0.5pt + pal.rule-dark-strong,
          radius: sz(6pt),
                    inset: (x: sz(24pt), y: sz(18pt)),
        )[
                    #show raw: set text(font: mono-font, size: sz(19pt), fill: pal.fg-dark)
          #set par(leading: 0.62em)
          #raw(block: true,
            "record RefundRule(\n"
            + "    RiskDecision    risk,   // 3\n"
            + "    RefundMechanism how    // 2\n"
            + ")")
        ],
        // Where the 2 comes from — RiskDecision's 3 is visible on the left, and
        // this is the only other number the arithmetic needs.
                block[
          #set text(size: sz(23pt), fill: pal.fg-dim)
          #set par(leading: 0.45em)
          #text(font: mono-font)[RefundMechanism] is the other sealed one in that
          package: #text(font: mono-font)[InstantReversal] or
          #text(font: mono-font)[CreditNoteRequired].
        ],
      ),

      text(size: sz(23pt), fill: pal.fg-faint)[
        #text(font: mono-font, fill: pal.accent)[3] values: #text(font: mono-font)[1 + 1 + 1]
      ],
      text(size: sz(23pt), fill: pal.fg-faint)[
        #text(font: mono-font, fill: pal.accent)[6] values: #text(font: mono-font)[3 × 2]
      ],
    )
            #v(sz(22pt))
    #line(length: 100%, stroke: 0.5pt + pal.rule)
    #v(sz(10pt))
    #grid(
      columns: (auto, 1fr),
      column-gutter: sz(40pt),
      align: (left + horizon, left + horizon),
      block[
        #set text(font: mono-font, size: sz(25pt), fill: pal.fg)
        PaymentMethod #h(sz(8pt)) = #h(sz(8pt))
        Card(String, …) #h(sz(6pt)) #text(fill: pal.accent)[+] #h(sz(6pt))
        Wallet(String, …) #h(sz(6pt)) #text(fill: pal.accent)[+] #h(sz(6pt))
        Invoice(String, …)
      ],
      block[
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        A sum whose variants are products. Most domain models are this shape.
      ],
    )
    // The row is centred between the rule above and the progress rail below.
    // The rail is not pinned to the page bottom, so this gap has to be written
    // out; measure it, do not eyeball it.
    #v(sz(45pt))
  ],
  footer: act1-rail(lit: ("Leibniz", "Boole")),
)

#speaker-note[
#read("../scripts/05-connectives.md")
]
