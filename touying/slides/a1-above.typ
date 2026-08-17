// A1-above · cap 1:05 · Act 1 beat 6 of 6 · rail complete
// Four notations, uncovered together — a glimpse, not a lesson. Every
// identifier is grepped from source; see FACTS in scripts/09-above.md.
#import "../theme.typ": *
#import "../components.typ": *

#let notation(sym, code, gloss) = grid(
  columns: (sz(90pt), sz(470pt), 1fr),
  column-gutter: sz(28pt),
  align: (center + horizon, left + horizon, left + horizon),
  text(font: mono-font, size: sz(34pt), weight: 600, fill: pal.accent)[#sym],
  text(font: mono-font, size: sz(23pt), fill: pal.fg)[#code],
  text(size: sz(24pt), fill: pal.fg-dim)[#gloss],
)

#theory-slide(
  eyebrow: eyebrow([Martin-Löf 1972 · Coquand 1988], style: "accent"),
  [What lies above],
  [
    #v(sz(18pt))
    #stack(
      dir: ttb,
      spacing: sz(24pt),
      notation([Π], `Approval : RiskLevel -> Type`,
               [a type indexed by a runtime value]),
      notation([Σ], `(lvl : RiskLevel ** Assessment lvl n c)`,
               [a value paired with a proof about that value]),
      notation([1], `(1 _ : Session p) -> ...`,
               [a binding that must be used exactly once]),
      notation([⇄], `Send[Order, Receive[RiskSnapshot, ...]]`,
               [a whole conversation, as one type]),
    )
    #v(sz(34pt))
    #align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      You will not walk out fluent in these, and that is not the point —\
      you will walk out knowing #text(fill: pal.accent, weight: 500)[what each one buys],
      having watched all four run.
    ]
  ],
  footer: act1-rail(lit: ("Martin-Löf",)),
)

#speaker-note[
#read("../scripts/09-above.md")
]
