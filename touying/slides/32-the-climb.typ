// Clock: 41:00–42:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([The Climb]),
  [What Was Removed at Each Stage],
  stack(
    dir: ttb,
    spacing: sz(14pt),
    // Summary table — font sizes reduced to sz(16pt)/sz(18pt) to prevent overflow
    block(
      width: 100%,
      stroke: (top: 1.5pt + pal.rule, bottom: 1.5pt + pal.rule),
      inset: 0pt,
      {
        let row(stage, lang, elim, header: false) = {
          let fill = if header { pal.bg-warm } else { white }
          let weight = if header { 500 } else { 300 }
          let sz-body = if header { sz(16pt) } else { sz(18pt) }
          grid(
            columns: (sz(70pt), sz(140pt), 1fr),
            rows: (auto,),
            gutter: 0pt,
            block(
              inset: (x: sz(10pt), y: sz(6pt)),
              fill: fill,
              stroke: (right: 0.5pt + pal.rule, bottom: 0.5pt + pal.rule),
              text(size: sz-body, weight: weight, font: mono-font, fill: if header { pal.fg-dim } else { pal.accent })[#stage],
            ),
            block(
              inset: (x: sz(10pt), y: sz(6pt)),
              fill: fill,
              stroke: (right: 0.5pt + pal.rule, bottom: 0.5pt + pal.rule),
              text(size: sz-body, weight: weight, fill: if header { pal.fg-dim } else { pal.fg })[#lang],
            ),
            block(
              inset: (x: sz(10pt), y: sz(6pt)),
              fill: fill,
              stroke: (bottom: 0.5pt + pal.rule),
              text(size: sz-body, weight: weight, fill: if header { pal.fg-dim } else { pal.fg-dim })[#elim],
            ),
          )
        }
        row([Stage], [Language], [What the type system now prevents], header: true)
        row([0], [JavaScript],        [Every invariant requires a test. No structural checking.])
        row([1], [Simple types],      [Shape confusion. Fabricated lifecycle values.])
        row([2], [Generics],          [Wrong element types. Composition proven for all T.])
        row([4], [Sum types],         [Forgotten branches. Unhandled error paths.])
        row([5], [Phantom typestate], [Lifecycle ordering. Fabricated state objects.])
        row([6], [Scala 3],           [Wrong approval for risk level. Empty identifiers at boundary. Protocol drift.])
        row([7], [Idris 2],           [Runtime-to-type bridge (Π-elimination at openSession). Channel-must-be-completed (multiplicity 1).])
      },
    ),
    ladder(
      [Lifecycle and authorization structurally enforced.],
      [Every invariant class has a compile-time test.],
      [All nine. `protocolFromSnapshot` computes type from runtime value. Linearity closes the channel.],
      encoded-active: true,
    ),
    grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      gutter: sz(10pt),
      block(fill: pal.bg-warm, inset: (x: sz(10pt), y: sz(6pt)), radius: sz(3pt),
        text(size: sz(20pt), weight: 500, fill: pal.accent)[✓ Alice — boundary]),
      block(fill: pal.bg-warm, inset: (x: sz(10pt), y: sz(6pt)), radius: sz(3pt),
        text(size: sz(20pt), weight: 500, fill: pal.accent)[✓ Bob — approval]),
      block(fill: pal.bg-warm, inset: (x: sz(10pt), y: sz(6pt)), radius: sz(3pt),
        text(size: sz(20pt), weight: 500, fill: pal.accent)[✓ Charlie — lifecycle]),
      block(fill: pal.bg-warm, inset: (x: sz(10pt), y: sz(6pt)), radius: sz(3pt),
        text(size: sz(20pt), weight: 500, fill: pal.accent)[✓ Danielle — protocol]),
    ),
  ),
)

#speaker-note[
"Let me trace what we removed. JavaScript: every invariant is a test. Stage 1: shape confusion and fabricated lifecycle values are type errors. Stage 2: element-type bugs and parametricity failures are type errors. Stage 4: forgotten branches and unhandled error paths are compile errors — via OR-elimination, the same rule Gentzen formalised. Stage 5: lifecycle ordering is no longer a runtime check, it is a structural guarantee. Stage 6: the approval method for the assessed risk level, non-empty boundary predicates, protocol drift — all become type errors. In Stage 7, we no longer have a gap between runtime classification and compile-time protocol-shape — `protocolFromSnapshot snapshot` computes it directly — and the channel becomes a linear resource the program is required to consume."
]
