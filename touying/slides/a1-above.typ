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
  body-gap: sz(46pt),
  [
    #block(width: 100%)[
      #set text(size: sz(25pt), fill: pal.fg-dim)
      #set par(leading: 0.45em)
      Until now a function's result type was fixed before you called it.
      Martin-Löf let it be #text(fill: pal.fg, weight: 500)[computed from the
      argument value] — every step tonight makes a type say more; this is the one
      that lets it speak about a particular value.
    ]
    #v(sz(24pt))
    #align(center)[
      #block(fill: pal.bg-warm, inset: (x: sz(30pt), y: sz(16pt)), radius: sz(4pt))[
        #set text(font: mono-font, size: sz(24pt), fill: pal.fg)
        (++) : Vect m a → Vect n a → Vect #text(fill: pal.accent)[(m + n)] a
        #h(sz(30pt))
        #text(size: sz(21pt), fill: pal.fg-dim, font: body-font)[
          three ++ four has type seven, because the compiler did the arithmetic
        ]
      ]
    ]
    #v(sz(30pt))
    #stack(
      dir: ttb,
      spacing: sz(38pt),
// ⇄ is paid off on A4-sessions in Act 4; Π and Σ both land on A5-mltt in Act
// 5, Π first; 1 is set up there and fired by Demo 5. Any other order makes
// A4-sessions' "here is the first" false. Keep the script in step.
      notation([⇄], `Send[Order, Receive[RiskSnapshot, ...]]`,
               [a whole conversation, as one type]),
      notation([Π], `Approval : RiskLevel -> Type`,
               [a type indexed by a runtime value]),
      notation([Σ], `(lvl : RiskLevel ** Assessment lvl n c)`,
               [a value paired with a proof about that value]),
      notation([1], `(1 _ : Session p) -> ...`,
               [a binding that must be used exactly once]),
    )
    #v(sz(50pt))
    #align(center)[
      #set text(size: sz(27pt), fill: pal.fg)
      All four of these run on the payment flow #text(fill: pal.accent, weight:
500)[before the end].
    ]
  ],
  footer: act1-rail(lit: ("Martin-Löf",)),
)

#speaker-note[
#read("../scripts/09-above.md")
]
