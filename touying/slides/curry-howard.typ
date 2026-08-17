// Clock: ~9:35–10:05 (inserted between convergence2 and mltt)
// §1.1: Curry-Howard gets its own slide — the conceptual fulcrum of the whole talk.
#import "../theme.typ": *
#import "../components.typ": *

// ── Local nd-rule helper (pure Typst — no cetz) ─────────────────────────────
// Same layout as diagrams/gentzen-or.typ and diagrams/mltt.typ.

#let _nd-rule(
  premises,
  conclusion,
  label: none,
  premise-gap: 18pt,
  bar-pad:     6pt,
  label-gap:   8pt,
  row-gap:     4pt,
) = context {
  let prem-row = stack(dir: ltr, spacing: premise-gap, ..premises)
  let prem-size = measure(prem-row)
  let concl-size = measure(conclusion)
  let bar-width = calc.max(prem-size.width, concl-size.width) + 2 * bar-pad
  if label == none {
    align(center)[
      #stack(dir: ttb, spacing: row-gap,
        prem-row,
        line(length: bar-width, stroke: 0.6pt + pal.fg),
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
        prem-row,   [],
        line(length: bar-width, stroke: 0.6pt + pal.fg),  text(fill: pal.accent, label),
        conclusion, [],
      )
    ]
  }
}

// ── The canvas ───────────────────────────────────────────────────────────────

#let ch-canvas = box[
  #grid(
    columns: (1.1fr, 1fr),
    gutter: sz(40pt),

    // ── Left: the three equations ───────────────────────────────────────────
    [
      // Three-row equation table
      #grid(
        columns: (1fr, sz(32pt), 1fr),
        row-gutter: sz(22pt),
        align: (right + horizon, center + horizon, left + horizon),

        text(size: sz(40pt), weight: 400, fill: pal.fg)[Proposition],
        text(size: sz(36pt), weight: 300, fill: pal.fg-dim)[=],
        text(size: sz(40pt), weight: 600, fill: pal.accent)[Type],

        text(size: sz(40pt), weight: 400, fill: pal.fg)[Proof],
        text(size: sz(36pt), weight: 300, fill: pal.fg-dim)[=],
        text(size: sz(40pt), weight: 600, fill: pal.accent)[Program],

        text(size: sz(40pt), weight: 400, fill: pal.fg)[Simplification],
        text(size: sz(36pt), weight: 300, fill: pal.fg-dim)[=],
        text(size: sz(40pt), weight: 600, fill: pal.accent)[Evaluation],
      )

      #v(sz(32pt))
      #line(length: 100%, stroke: 0.5pt + pal.rule-strong)
      #v(sz(20pt))

      #set text(size: sz(28pt), fill: pal.fg-dim)
      #set par(leading: 0.5em)
      The reason exhaustive matching IS a proof obligation, \
      and the reason the type checker IS a theorem prover \
      within the calculus it defines. \
      #v(sz(12pt))
      #text(size: sz(24pt), fill: pal.fg-faint)[
        (β-reduction IS proof reduction — running a program
        simplifies the proof it encodes.)
      ]
    ],

    // ── Right: ∨E ≅ exhaustive match ────────────────────────────────────────
    [
      #set text(size: sz(22pt))

      #text(weight: "bold", size: sz(22pt), fill: pal.fg-dim)[Gentzen ∨E]
      #v(sz(10pt))

      #_nd-rule(
        (
          text[A ∨ B],
          text[\[A\] → C],
          text[\[B\] → C],
        ),
        text[C],
        label: text[(∨E)],
        premise-gap: sz(20pt),
      )

      #v(sz(20pt))
      #align(center)[
        #text(size: sz(44pt), weight: 300, fill: pal.accent)[≅]
      ]
      #v(sz(16pt))

      #text(weight: "bold", size: sz(22pt), fill: pal.fg-dim)[Exhaustive match]
      #v(sz(10pt))

      #block(
        fill: pal.bg-warm,
        radius: 3pt,
        inset: (x: sz(16pt), y: sz(12pt)),
        width: 100%,
      )[
        #set text(font: mono-font, size: sz(20pt), fill: pal.fg)
        #set par(leading: 0.55em)
        ```scala
        risk match {
          case Low    l => path(l)  // [A]→C
          case Medium m => path(m)  // [B]→C
          case High   h => path(h)  // [C]→C
          // omit any case → compile error
        }
        ```
      ]
    ],
  )
]

#theory-slide(
  [Curry-Howard Correspondence · 1969],
  ch-canvas,
  footer: [Every stage from 3 onward is Curry-Howard made practical: the type is the proposition, the program that type-checks is the proof, and the compile error is the proof assistant rejecting an incomplete argument.],
)

#speaker-note[
"Howard, in 1969, showed that these two worlds — formal logic and programming — are the same world, described in different notation. A logical proposition corresponds to a type. A proof of that proposition corresponds to a program of that type. Running the program is simplifying the proof: when (lambda x. x+1)(5) reduces to 6, one modus ponens step was applied and discharged. Beta-reduction IS proof reduction.

This is why exhaustive matching is not just a convenience feature. It is enforcing Gentzen's elimination rule for disjunction — the rule we just saw on the previous slide. The compiler is, within the calculus it defines, acting as a theorem prover. It accepts programs that correspond to complete proofs. It rejects programs that correspond to incomplete arguments.

Every stage in the rest of the talk is this idea made practical. The type is the specification. The program that type-checks is the proof that the specification is met. The compile error tells you exactly which proof obligation is unsatisfied."
]
