// =============================================================================
// diagrams/mltt.typ — Martin-Löf Type Theory: Π and Σ formation / intro /
// elimination rules.
//
// Built from scratch for the Touying deck. Exposes `mltt-canvas`, a
// self-contained two-column rule diagram placed inside the .s-theory slide
// for S12.
//
// Content requirements (Phase 1 spec):
//   - Two-column layout: Π left, Σ right
//   - Π: Formation, Introduction (λ), Elimination (application), β-reduction
//   - Σ: Introduction (pair), Elimination (fst / snd projections)
//   - Brief gloss under each column
//   - Bottom line: "protocolFromSnapshot is Π-elimination;
//                   assessOrder is Σ-introduction."
// =============================================================================

#import "@preview/cetz:0.3.4": canvas, draw

#let accent      = oklch(62%, 0.14, 55deg)
#let muted       = rgb("#5a5d68")
#let fg          = rgb("#14161d")
#let bar-stroke  = (paint: fg, thickness: 0.6pt)

// ─── nd-rule helper (same shape as gentzen-or; kept local for standalone use) ─

#let nd-rule(
  premises,
  conclusion,
  label: none,
  premise-spacing: 2.4,
  bar-padding: 0.6,
  bar-offset: 0.45,
) = canvas({
  import draw: *

  let n = premises.len()
  let total-width = (n - 1) * premise-spacing
  let bar-half = total-width / 2 + bar-padding

  for (i, p) in premises.enumerate() {
    let x = -total-width / 2 + i * premise-spacing
    content((x, bar-offset + 0.25), p)
  }
  line((-bar-half, 0), (bar-half, 0), stroke: bar-stroke)
  content((0, -0.45), conclusion)
  if label != none {
    content((bar-half + 0.6, 0), text(fill: accent, label))
  }
})

// ─── The canvas ─────────────────────────────────────────────────────────────

#let mltt-canvas = box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 18pt,

    // ─────────── Π-types (left column) ────────────
    [
      #text(weight: "bold", size: 12pt)[
        Π-type — #text(fill: muted, weight: "regular")[$forall$ as dependent function]
      ]

      #v(6pt)

      // Formation
      #text(fill: muted, size: 9pt)[Formation]
      #align(center)[
        #nd-rule(
          ($Gamma tack.r A : cal(U)$, $Gamma, x:A tack.r B(x) : cal(U)$),
          $ Gamma tack.r (Pi x:A). B(x) : cal(U) $,
          label: $(Pi"-Form")$,
        )
      ]

      #v(4pt)

      // Introduction
      #text(fill: muted, size: 9pt)[Introduction (λ)]
      #align(center)[
        #nd-rule(
          ($Gamma, x:A tack.r b(x) : B(x)$,),
          $ Gamma tack.r lambda x. b(x) : (Pi x:A). B(x) $,
          label: $(Pi"-Intro")$,
        )
      ]

      #v(4pt)

      // Elimination
      #text(fill: muted, size: 9pt)[Elimination (application)]
      #align(center)[
        #nd-rule(
          ($Gamma tack.r f : (Pi x:A). B(x)$, $Gamma tack.r a : A$),
          $ Gamma tack.r f(a) : B(a) $,
          label: $(Pi"-Elim")$,
        )
      ]

      #v(4pt)

      // β-reduction (computation)
      #align(center)[
        #text(size: 10pt)[
          #text(fill: muted, size: 9pt)[Computation: ]
          $ (lambda x. b)(a) equiv b[a slash x] $
          #text(fill: muted, size: 9pt)[(β-reduction)]
        ]
      ]

      #v(6pt)

      #align(left)[
        #text(fill: muted, size: 10pt, style: "italic")[
          Applied to a runtime value → return type depends on that value.
        ]
      ]
    ],

    // ─────────── Σ-types (right column) ────────────
    [
      #text(weight: "bold", size: 12pt)[
        Σ-type — #text(fill: muted, weight: "regular")[$exists$ as dependent pair]
      ]

      #v(6pt)

      // Introduction
      #text(fill: muted, size: 9pt)[Introduction (pair)]
      #align(center)[
        #nd-rule(
          ($Gamma tack.r a : A$, $Gamma tack.r b : B(a)$),
          $ Gamma tack.r (a, b) : (Sigma x:A). B(x) $,
          label: $(Sigma"-Intro")$,
        )
      ]

      #v(4pt)

      // Elimination — fst
      #text(fill: muted, size: 9pt)[Elimination (proj₁)]
      #align(center)[
        #nd-rule(
          ($Gamma tack.r p : (Sigma x:A). B(x)$,),
          $ Gamma tack.r upright("fst")(p) : A $,
          label: $(Sigma"-Elim"_1)$,
        )
      ]

      #v(4pt)

      // Elimination — snd
      #text(fill: muted, size: 9pt)[Elimination (proj₂)]
      #align(center)[
        #nd-rule(
          ($Gamma tack.r p : (Sigma x:A). B(x)$,),
          $ Gamma tack.r upright("snd")(p) : B(upright("fst")(p)) $,
          label: $(Sigma"-Elim"_2)$,
        )
      ]

      #v(6pt)

      #align(left)[
        #text(fill: muted, size: 10pt, style: "italic")[
          A value bundled with a proof that depends on it.
        ]
      ]
    ],
  )

  #v(10pt)

  #block(
    inset: (x: 0.8em, y: 0.4em),
    stroke: (left: 2pt + accent),
    width: 100%,
  )[
    #text(size: 11pt)[
      In Stage 7: `protocolFromSnapshot` is
      #text(fill: accent, weight: "bold")[Π-elimination];
      `assessOrder` is
      #text(fill: accent, weight: "bold")[Σ-introduction].
    ]
  ]
]

// Standalone-compile guard.
#mltt-canvas
