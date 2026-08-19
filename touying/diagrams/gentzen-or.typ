#import "@preview/cetz:0.5.2": canvas, draw

// ─── Local theme tokens — mirror the deck palette so the canvas looks at home
// on a light .s-theory slide. Tokens are repeated rather than imported to keep
// each diagram canvas standalone-compilable for testing.

#let accent      = oklch(62%, 0.14, 55deg)
#let bad         = oklch(58%, 0.17, 28deg)
#let muted       = rgb("#5a5d68")
#let fg          = rgb("#14161d")

// ─── ND rule helper ─────────────────────────────────────────────────────────
//
// Pure-Typst inference-rule renderer. Lays the rule out as a centred column:
//
//                    premise₁    premise₂    …
//                   ────────────────────────── (label)
//                            conclusion
//
// The horizontal bar measures to the WIDER of the premise row and the
// conclusion (plus a thin pad), so the bar is always at least as wide as the
// widest formula it sits between. The label is then placed just right of the
// bar's end.

#let nd-rule(
  premises,
  conclusion,
  label: none,
  premise-gap: 18pt,
  bar-pad:     6pt,
  label-gap:   8pt,
  row-gap:     4pt,
) = context {
  let prem-row = stack(
    dir: ltr,
    spacing: premise-gap,
    ..premises,
  )
  let prem-size = measure(prem-row)
  let concl-size = measure(conclusion)
  let bar-width = calc.max(prem-size.width, concl-size.width) + 2 * bar-pad

  // Two-column grid: premise / bar / conclusion stack in the LEFT column
  // (width = bar-width), label sits in the RIGHT column (auto width). Premise
  // and conclusion are centred ONLY over the bar, not over the bar + label.
  // The label row aligns vertically with the bar via `horizon`.
  if label == none {
    align(center)[
      #stack(
        dir: ttb,
        spacing: row-gap,
        prem-row,
        line(length: bar-width, stroke: 0.6pt + fg),
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
        line(length: bar-width, stroke: 0.6pt + fg),  text(fill: accent, label),
        conclusion,  [],
      )
    ]
  }
}

// ─── The canvas itself ──────────────────────────────────────────────────────

#let gentzen-or-canvas = box[
  // Two columns: rules on the left, code-side on the right.
  #grid(
    columns: (1.1fr, 1fr),
    gutter: 22pt,

    // ── Left: introduction + elimination rules
    [
      #text(weight: "bold", size: 15pt)[Introduction rules — building $A or B$]

      #v(6pt)

      #align(center)[
        #grid(
          columns: 2,
          gutter: 36pt,
          align: center + horizon,
          nd-rule(($A$,),    $A or B$, label: $(or upright(I)_1)$),
          nd-rule(($B$,),    $A or B$, label: $(or upright(I)_2)$),
        )
      ]

      #v(10pt)

      #text(weight: "bold", size: 15pt)[Elimination rule — using $A or B$]

      #v(6pt)

      #nd-rule(
        ($A or B$, $[A] arrow.r.long C$, $[B] arrow.r.long C$),
        $C$,
        label: $(or upright(E))$,
        premise-gap: 28pt,
      )

      #v(8pt)

      #align(center)[
        #text(fill: muted, size: 11pt)[
          Square brackets mark discharged assumptions:
          $[A]$ means "supposing $A$, derive $C$" — the rule
          then retracts the supposition.
        ]
      ]
    ],

    // ── Right: code side
    [
      #text(weight: "bold", size: 15pt)[On the code side]

      #v(6pt)

      // sealed declaration
      #align(left)[
        #text(fill: muted, size: 13pt)[
          ```scala
          sealed trait Either[+A, +B]
          case class Left [A](a: A) extends Either[A, Nothing]
          case class Right[B](b: B) extends Either[Nothing, B]
          ```
        ]
      ]

      #v(6pt)

      // exhaustive match — case arms aligned under `match`
      #align(left)[
        #text(fill: muted, size: 13pt)[
          ```scala
          x match {
            case Left(a)  => useA(a)   // [A] → C
            case Right(b) => useB(b)   // [B] → C
          }
          ```
        ]
      ]

      #v(8pt)

      #block(
        inset: (x: 0.7em, y: 0.4em),
        stroke: (left: 2pt + bad),
        width: 100%,
      )[
        #text(size: 12pt)[
          #text(fill: bad, weight: "bold")[Missing the Right branch]
          $=$ no $[B] arrow.r.long C$.
          The compiler cannot apply $or upright(E)$. #text(fill: bad)[*Compile error.*]
        ]
      ]
    ],
  )

    #v(26pt)

  #block(
    inset: (x: 0.8em, y: 0.6em),
    stroke: (left: 2pt + accent),
    width: 100%,
  )[
    #text(size: 13pt)[
      Each connective is defined by its interface: *how to build* a proof
      of it (introduction) and *how to use* one (elimination).
      #text(fill: accent, weight: "bold")[The rest follows.]
    ]
  ]
]

// Standalone-compile guard: when this file is compiled directly (not imported)
// the constant below is rendered so the build succeeds. When imported via
// `#import "diagrams/gentzen-or.typ": *`, only the bindings are exported.
#gentzen-or-canvas
