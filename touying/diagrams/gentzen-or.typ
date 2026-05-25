// =============================================================================
// diagrams/gentzen-or.typ — Gentzen's OR introduction + elimination rules.
//
// Built from scratch for the Touying deck. Exposes `gentzen-or-canvas`, a
// self-contained cetz canvas that can be placed inside an `.s-theory` slide.
//
// Content requirements (Phase 1 spec):
//   - ∨I₁, ∨I₂ introduction rules
//   - ∨E elimination rule with discharged-assumption gloss
//   - Closing line "The rest follows."
//   - Code side: sealed declaration + exhaustive match with case-arms
//     aligned under the `match` keyword
// =============================================================================

#import "@preview/cetz:0.3.4": canvas, draw

// ─── Local theme tokens — mirror the deck palette so the canvas looks at home
// on a light .s-theory slide. Tokens are repeated rather than imported to keep
// each diagram canvas standalone-compilable for testing.

#let accent      = oklch(62%, 0.14, 55deg)
#let bad         = oklch(58%, 0.17, 28deg)
#let muted       = rgb("#5a5d68")
#let fg          = rgb("#14161d")
#let bar-stroke  = (paint: fg, thickness: 0.6pt)

// ─── ND rule helper ─────────────────────────────────────────────────────────
//
// Draws one natural-deduction rule:
//
//                    premise₁    premise₂    …
//                   ────────────────────────── (label)
//                            conclusion
//
// All premises are centred on x = 0 with `premise-spacing` between them.
// The horizontal inference bar adapts to the row width via `bar-padding`.

#let nd-rule(
  premises,
  conclusion,
  label: none,
  premise-spacing: 2.2,
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

// ─── The canvas itself ──────────────────────────────────────────────────────

#let gentzen-or-canvas = box[
  // Two columns: rules on the left, code-side on the right.
  #grid(
    columns: (1.1fr, 1fr),
    gutter: 14pt,

    // ── Left: introduction + elimination rules
    [
      #text(weight: "bold", size: 12pt)[Introduction rules — building $A or B$]

      #v(6pt)

      #align(center)[
        #grid(
          columns: 2,
          gutter: 18pt,
          align: center + horizon,
          nd-rule(($A$,),    $ A or B $, label: $(or upright(I)_1)$),
          nd-rule(($B$,),    $ A or B $, label: $(or upright(I)_2)$),
        )
      ]

      #v(8pt)

      #text(weight: "bold", size: 12pt)[Elimination rule — using $A or B$]

      #v(6pt)

      #align(center)[
        #nd-rule(
          ($A or B$, $[A] arrow.r.long C$, $[B] arrow.r.long C$),
          $ C $,
          label: $(or upright(E))$,
          premise-spacing: 2.4,
        )
      ]

      #v(6pt)

      #align(center)[
        #text(fill: muted, size: 9pt)[
          Square brackets mark discharged assumptions:
          $[A]$ means "supposing $A$, derive $C$" — the rule
          then retracts the supposition.
        ]
      ]
    ],

    // ── Right: code side
    [
      #text(weight: "bold", size: 12pt)[On the code side]

      #v(6pt)

      // sealed declaration
      #align(left)[
        #text(fill: muted, size: 11pt)[
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
        #text(fill: muted, size: 11pt)[
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
        #text(size: 10pt)[
          #text(fill: bad, weight: "bold")[Missing the Right branch]
          $=$ no $[B] arrow.r.long C$.
          The compiler cannot apply $or upright(E)$. #text(fill: bad)[*Compile error.*]
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
