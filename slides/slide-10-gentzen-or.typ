// =============================================================================
// Slide 10 — Gentzen: Logic as Interface
// =============================================================================
//
// Compile:  typst compile slide-10-gentzen-or.typ
// Watch:    typst watch  slide-10-gentzen-or.typ
//
// Requires the cetz package (auto-downloaded from typst-universe on first run).
// =============================================================================

#import "@preview/cetz:0.3.4"

// ─── Page / theme ───────────────────────────────────────────────────────────

// 16:9 widescreen slide at a comfortable print scale (25.4cm × 14.29cm).
#set page(
  width: 25.4cm,
  height: 14.29cm,
  margin: (x: 1.4cm, y: 0.8cm),
  fill: rgb("#0d1117"),
)
#set text(fill: rgb("#e6edf3"), font: "New Computer Modern", size: 14pt)
#set par(leading: 0.5em)

#let accent     = rgb("#79c0ff")
#let warn       = rgb("#ff7b72")
#let muted      = rgb("#8b949e")
#let bar-stroke = (paint: rgb("#e6edf3"), thickness: 0.6pt)

// ─── ND rule helper (cetz) ──────────────────────────────────────────────────
//
// Draws one natural-deduction rule:
//
//                    premise₁    premise₂    …
//                   ────────────────────────── (label)
//                            conclusion
//
// Premises are passed as an array of math content; their horizontal spacing
// is computed from `premise-spacing`. The bar's length adapts to the row.

#let nd-rule(
  premises,
  conclusion,
  label: none,
  premise-spacing: 2.2,
  bar-padding: 0.6,
  bar-offset: 0.45,  // vertical gap between premises and bar
) = cetz.canvas({
  import cetz.draw: *

  let n = premises.len()
  let total-width = (n - 1) * premise-spacing
  let bar-half = total-width / 2 + bar-padding

  // Premises in a horizontal row, centred on x = 0
  for (i, p) in premises.enumerate() {
    let x = -total-width / 2 + i * premise-spacing
    content((x, bar-offset + 0.25), p)
  }

  // The horizontal inference bar
  line(
    (-bar-half, 0),
    ( bar-half, 0),
    stroke: bar-stroke,
  )

  // The conclusion below the bar
  content((0, -0.45), conclusion)

  // Optional rule name to the right
  if label != none {
    content((bar-half + 0.7, 0), text(fill: accent, label))
  }
})

// ─── Title and motivating idea ──────────────────────────────────────────────

#text(size: 22pt, weight: "bold")[Gentzen: Logic as Interface]

#v(0.3em)

#block(
  inset: (x: 0.8em, y: 0.4em),
  stroke: (left: 2pt + accent),
  width: 100%,
)[
  Each connective is defined by its interface: *how to BUILD* a
  proof of it (introduction rules) and *how to USE* one (elimination
  rules). The rest follows.
]

#v(0.5em)

// ─── Rules side by side ─────────────────────────────────────────────────────

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,

  // ── Left column: introduction rules
  [
    #text(weight: "bold")[Introduction rules] — building $A or B$:

    #v(0.4em)

    #align(center)[
      #grid(
        columns: 2,
        column-gutter: 1.6cm,
        align: center + horizon,

        nd-rule(
          ($A$,),
          $ A or B $,
          label: $(or upright(I)_1)$,
        ),

        nd-rule(
          ($B$,),
          $ A or B $,
          label: $(or upright(I)_2)$,
        ),
      )
    ]

    #v(0.5em)

    #align(center)[
      #text(fill: muted, size: 12pt)[
        `Left(a)  : A ∨ B`#linebreak()
        `Right(b) : A ∨ B`
      ]
    ]
  ],

  // ── Right column: elimination rule
  [
    #text(weight: "bold")[Elimination rule] — using $A or B$:

    #v(0.4em)

    #align(center)[
      #nd-rule(
        (
          $A or B$,
          $[A] arrow.r.long C$,
          $[B] arrow.r.long C$,
        ),
        $ C $,
        label: $(or upright(E))$,
        premise-spacing: 2.4,
      )
    ]

    #v(0.3em)

    #align(center)[
      #text(fill: muted, size: 10pt)[
        Brackets mark *local assumptions*: $[A]$ scopes only to the
        left sub-proof of $C$; $[B]$ only to the right.
      ]
    ]

    #v(0.4em)

    #align(left)[
      #text(fill: muted, size: 12pt)[
        ```scala
        match x {
          case Left(a)  => C
          case Right(b) => C
        }
        ```
      ]
    ]
  ],
)

#v(0.5em)

// ─── Takeaway ───────────────────────────────────────────────────────────────

#block(
  inset: (x: 0.8em, y: 0.4em),
  stroke: (left: 2pt + warn),
  width: 100%,
)[
  #text(fill: warn, weight: "bold")[Missing the Right branch] $=$ you have
  not supplied $[B] arrow.r.long C$. The compiler cannot apply $or upright(E)$.
  *Compile error.*
]
