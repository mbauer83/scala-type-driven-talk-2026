// Clock: 41:00–42:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([The Climb]),
  [Mistakes we can no longer make at each stage],
  stack(
    dir: ttb,
    spacing: sz(14pt),
    // Summary table — Typst `table` handles per-row uniform fills automatically
    // (wrapped cells extend the whole row's fill, fixing the previous bug
    // where only the wrapping column held its background past line 1).
    table(
      columns: (sz(80pt), sz(180pt), 1fr),
      rows: auto,
      stroke: 0.5pt + pal.rule,
      align: (left + horizon, left + horizon, left + horizon),
      inset: (x: sz(14pt), y: sz(12pt)),
      fill: (col, row) => if row == 0 { pal.bg-warm } else { none },
      // ── Header row
      table.cell({
        set text(size: sz(20pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)
        upper[Stage]
      }),
      table.cell({
        set text(size: sz(20pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)
        upper[Language]
      }),
      table.cell({
        set text(size: sz(20pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)
        upper[What the type system now prevents]
      }),
      // ── Data rows
      ..(
        ("0", "JavaScript",              "Every invariant requires a test. No structural checking."),
        ("1", "Simple types",            "Shape confusion. Fabricated lifecycle values."),
        ("2", "Generics",                "Wrong element types. Composition proven for all T."),
        ("3", "ADTs: records + sealed",     "Forgotten branches. Unhandled error paths. Compiler enforces sums of products."),
        ("4", "Phantom typestate",       "Lifecycle ordering. Fabricated state objects."),
        ("5", "Scala 3",                 "Wrong approval for risk level. Empty identifiers at boundary. Protocol drift."),
        ("6", "Idris 2",                 "Runtime-to-type bridge (Π-elimination). Channel-must-be-completed (multiplicity 1)."),
      ).map(r => (
        text(size: sz(22pt), font: mono-font, weight: 500, fill: pal.accent)[#r.at(0)],
        text(size: sz(22pt), fill: pal.fg)[#r.at(1)],
        text(size: sz(22pt), fill: pal.fg-dim)[#r.at(2)],
      )).flatten()
    ),
    ladder(
      [Lifecycle and authorization structurally enforced.],
      [Every invariant class has a compile-time test.],
      [All nine. `protocolFromSnapshot` computes type from runtime value. Linearity closes the channel.],
      encoded-active: true,
    ),
// The four name-chips are removed: they overflowed the slide, and they were
// the fifth appearance of the tracking furniture P5 took off every other
// payoff.

  ),
)

#speaker-note[
"Let me trace the mistakes that stopped being possible. JavaScript: every invariant is a test. Stage 1: shape confusion and fabricated lifecycle values are type errors. Stage 2: element-type bugs and parametricity failures are type errors. Stage 3: algebraic data types — records as products, sealed interfaces as sums — make forgotten branches and unhandled error paths compile errors, via OR-elimination, the same rule Gentzen formalised in 1935. Stage 4: lifecycle ordering is no longer a runtime check or a naming convention, it is a structural guarantee in the phantom type parameter. Stage 5: the approval method for the assessed risk level, non-empty boundary predicates, protocol drift — all become type errors. In Stage 6, we no longer have a gap between runtime classification and compile-time protocol-shape — `protocolFromSnapshot snapshot` computes it directly — and the channel becomes a linear resource the program is required to consume."
]
