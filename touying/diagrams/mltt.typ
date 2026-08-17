// =============================================================================
// diagrams/mltt.typ — Martin-Löf Type Theory: Π and Σ formation / intro /
// elimination rules.
//
// Built from scratch for the Touying deck. Exposes `mltt-canvas`, a
// self-contained two-column rule diagram placed inside the .s-theory slide
// for S13.
//
// Content:
//   - Two-column layout: Π left, Σ right
//   - Π: Introduction (λ), Elimination (application + β-reduction) — Formation removed
//   - Σ: Introduction (pair), Elimination (fst / snd projections) — Formation removed
//   - Inline plain-English gloss after each rule
//   - Bottom line: "protocolFromSnapshot is Π-elimination;
//                   assessOrder is Σ-introduction."
// =============================================================================

#let accent      = oklch(62%, 0.14, 55deg)
#let muted       = rgb("#5a5d68")
#let fg          = rgb("#14161d")

// ─── nd-rule helper — pure Typst layout that measures its content so the bar
// always spans the widest of premise-row / conclusion (matches gentzen-or).

#let nd-rule(
  premises,
  conclusion,
  label: none,
  premise-gap: 16pt,
  bar-pad:     6pt,
  label-gap:   8pt,
  row-gap:     3pt,
) = context {
  let prem-row = stack(
    dir: ltr,
    spacing: premise-gap,
    ..premises,
  )
  let prem-size = measure(prem-row)
  let concl-size = measure(conclusion)
  let bar-width = calc.max(prem-size.width, concl-size.width) + 2 * bar-pad

  // Two-column grid: premise/bar/conclusion in the left column (= bar-width),
  // label in the right column. Premise and conclusion centre over the bar
  // ONLY, not over bar + label. Label aligns vertically with the bar.
  if label == none {
    align(center)[
      #stack(
        dir: ttb,
        spacing: row-gap,
        prem-row,
        line(length: bar-width, stroke: 0.5pt + fg),
        conclusion,
      )
    ]
  } else {
    align(center)[
      #grid(
        columns: (bar-width, auto),
        column-gutter: label-gap,
        row-gutter: row-gap,
        align: (center + horizon, left + horizon),
        prem-row,    [],
        line(length: bar-width, stroke: 0.5pt + fg),  text(fill: accent, label),
        conclusion,  [],
      )
    ]
  }
}

// ─── The canvas ─────────────────────────────────────────────────────────────

#let mltt-canvas = box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 24pt,

    // ─────────── Π-types (left column) ────────────
    [
      #text(weight: "bold", size: 13pt)[
        Π-type — #text(fill: muted, weight: "regular")[$forall$ as dependent function]
      ]

      #v(4pt)

      // Introduction
      #text(fill: muted, size: 9pt)[Introduction (λ)]
      #nd-rule(
        ($Gamma, x:A tack.r b(x) : B(x)$,),
        $Gamma tack.r lambda x. b(x) : (Pi x:A). B(x)$,
        label: $(Pi"-Intro")$,
      )
      #text(fill: muted, size: 9pt, style: "italic")[
        λ-abstraction: if f(x) has type B(x) for each x:A, then λx.f(x) has type (Πx:A).B(x)
      ]

      #v(4pt)

      // Elimination
      #text(fill: muted, size: 9pt)[Elimination (application)]
      #nd-rule(
        ($Gamma tack.r f : (Pi x:A). B(x)$, $Gamma tack.r a : A$),
        $Gamma tack.r f(a) : B(a)$,
        label: $(Pi"-Elim")$,
      )
      #text(fill: muted, size: 9pt, style: "italic")[
        Application: the return type B(a) is indexed by the argument value a.
        β-reduction $(lambda x. b)(a) equiv b[a slash x]$ IS proof reduction.
      ]
    ],

    // ─────────── Σ-types (right column) ────────────
    [
      #text(weight: "bold", size: 13pt)[
        Σ-type — #text(fill: muted, weight: "regular")[$exists$ as dependent pair]
      ]

      #v(4pt)

      // Introduction
      #text(fill: muted, size: 9pt)[Introduction (pair)]
      #nd-rule(
        ($Gamma tack.r a : A$, $Gamma tack.r b : B(a)$),
        $Gamma tack.r (a, b) : (Sigma x:A). B(x)$,
        label: $(Sigma"-Intro")$,
      )
      #text(fill: muted, size: 9pt, style: "italic")[
        Bundle a value with a proof whose type mentions that value.
      ]

      #v(4pt)

      // Elimination — fst and snd combined
      #text(fill: muted, size: 9pt)[Elimination (proj₁ / proj₂)]
      #nd-rule(
        ($Gamma tack.r p : (Sigma x:A). B(x)$,),
        $Gamma tack.r upright("fst")(p) : A #h(1.4em) Gamma tack.r upright("snd")(p) : B(upright("fst")(p))$,
        label: $(Sigma"-Elim")$,
      )
      #text(fill: muted, size: 9pt, style: "italic")[
        Project: fst recovers the value; snd recovers the proof (indexed by that value).
      ]
    ],
  )

  #v(8pt)

  #block(
    inset: (x: 0.8em, y: 0.4em),
    stroke: (left: 2pt + accent),
    width: 100%,
  )[
    #text(size: 12pt)[
      In Stage 6: `protocolFromSnapshot` is
      #text(fill: accent, weight: "bold")[Π-elimination];
      `assessOrder` is
      #text(fill: accent, weight: "bold")[Σ-introduction].
    ]
  ]
]

// Standalone-compile guard.
#mltt-canvas
