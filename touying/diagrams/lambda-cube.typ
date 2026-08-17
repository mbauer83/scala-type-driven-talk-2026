// =============================================================================
// diagrams/lambda-cube.typ — Barendregt's lambda cube with stage tags.
//
// Built from scratch for the Touying deck. Exposes `lambda-cube-canvas`, a
// self-contained cetz canvas placed inside the .s-theory slide for S15.
//
// Content requirements (Phase 1 spec):
//   - 3D cube, 8 labelled vertices
//   - Primary labels = system names (normal weight); λ-names secondary, 9pt muted
//   - Vertex names: STLC, System F, Fω⁻, System Fω, LF, F+dep., Fω+dep., CIC
//   - Three labelled axes:
//       · terms-on-types       (bottom, horizontal — generics)
//       · types-on-types       (right, vertical — type operators)
//       · types-on-terms       (depth, diagonal — dependent types)
//   - Stage tags: Stage 1 / Stage 2 / Stages 4–5 / Stage 6 at the path vertices
//   - Highlight path: λ→ → λ2 → λω→ → λC (front-bottom-left → back-top-right)
// =============================================================================

#import "@preview/cetz:0.3.4": canvas, draw

#let accent      = oklch(62%, 0.14, 55deg)
#let stage-color = oklch(75%, 0.16, 75deg)   // warm gold for stage tags
#let path-color  = oklch(58%, 0.17, 28deg)   // red highlight along the talk path
#let muted       = rgb("#5a5d68")
#let back-edge   = rgb("#8a8c93")
#let fg          = rgb("#14161d")
#let bg-color    = rgb("#f4f1ea")            // matches pal.bg — masks red path under labels

#let lambda-cube-canvas = canvas({
  import draw: *

  // Cube geometry — sized slightly larger than the Phase-1 baseline so the
  // diagram reads from the back row at projection scale.
  let w  = 3.8     // front-face width
  let h  = 2.8     // front-face height
  let dx = 1.1     // depth offset x
  let dy = 0.9     // depth offset y

  let f-bl = (0,       0)
  let f-br = (w,       0)
  let f-tl = (0,       h)
  let f-tr = (w,       h)
  let b-bl = (dx,      dy)
  let b-br = (w + dx,  dy)
  let b-tl = (dx,      h + dy)
  let b-tr = (w + dx,  h + dy)

  // ── Back face — dashed, dim
  let back = (paint: back-edge, thickness: 0.6pt, dash: "dashed")
  line(b-bl, b-br, stroke: back)
  line(b-bl, b-tl, stroke: back)
  line(b-br, b-tr, stroke: back)
  line(b-tl, b-tr, stroke: back)

  // ── Front-to-back connecting edges — dim
  let conn = (paint: back-edge, thickness: 0.6pt)
  line(f-bl, b-bl, stroke: conn)
  line(f-br, b-br, stroke: conn)
  line(f-tl, b-tl, stroke: conn)
  line(f-tr, b-tr, stroke: conn)

  // ── Front face — solid
  let front = (paint: fg, thickness: 0.9pt)
  line(f-bl, f-br, stroke: front)
  line(f-bl, f-tl, stroke: front)
  line(f-br, f-tr, stroke: front)
  line(f-tl, f-tr, stroke: front)

  // ── Highlight path: λ→ → λ2 → λω→ → λC (the talk's route)
  let path = (paint: path-color, thickness: 1.8pt)
  line(f-bl, f-br, stroke: path)   // STLC → System F
  line(f-br, f-tr, stroke: path)   // System F → System Fω
  line(f-tr, b-tr, stroke: path)   // System Fω → CIC

  // ── Vertex dots
  for p in (f-bl, f-tl, f-br, f-tr) {
    circle(p, radius: 0.07, fill: fg, stroke: none)
  }
  for p in (b-bl, b-tl, b-br, b-tr) {
    circle(p, radius: 0.06, fill: back-edge, stroke: none)
  }
  // re-highlight the four path vertices
  for p in (f-bl, f-br, f-tr, b-tr) {
    circle(p, radius: 0.10, fill: path-color, stroke: none)
  }

  // ── Vertex label helper
  //
  //   Row 1: "System name  (λ-symbol)"   — primary name + muted lambda
  //   Row 2: stage tag — drawn BELOW row 1 regardless of anchor side, so the
  //          path-stage callout sits beneath its system name in every case.
  //
  // Row 1 is wrapped in a `box(fill: bg-color, ...)` so the red highlight path
  // does not visually cross through the text where the path runs behind a label.

  // Layout lesson: stage tags must sit clearly BELOW the system name. The
  // drop must exceed the label's own visual height so the two rows separate.
  // White-bg inset on each row masks the red highlight path running behind.
  let stage-drop = 0.78

  let vlabel(pos, name, lam, anchor, stage: none) = {
    let label-x = pos.at(0)
    let label-y = pos.at(1)
    let row1 = box(fill: bg-color, inset: (x: 1.5pt, y: 1pt),
      text(weight: "medium", size: 12pt, name)
        + text(fill: muted, size: 9pt, [ (#lam)])
    )
    content((label-x, label-y), row1, anchor: anchor)
    if stage != none {
      content(
        (label-x, label-y - stage-drop),
        box(fill: bg-color, inset: (x: 1.5pt, y: 1pt))[
          #text(fill: stage-color, size: 10pt, weight: "bold", stage)
        ],
        anchor: anchor,
      )
    }
  }

  // ── Front face
  vlabel((f-bl.at(0) - 0.20, f-bl.at(1) - 0.15), [STLC], $lambda arrow.r$,
         "north-east", stage: [Stage 1])
  vlabel((f-br.at(0) + 0.20, f-br.at(1) - 0.15), [System F], $lambda 2$,
         "north-west", stage: [Stage 2])
  vlabel((f-tl.at(0) - 0.20, f-tl.at(1) + 0.40), [F$omega$⁻], $lambda omega$,
         "south-east")
  // System Fω: shift further right + down so its stage tag clears CIC above.
  vlabel((f-tr.at(0) + 0.55, f-tr.at(1) - 0.35), [System F$omega$],
         $lambda omega arrow.r$, "south-west", stage: [Stages 5–6])

  // ── Back face
  vlabel((b-bl.at(0) - 0.20, b-bl.at(1) + 0.15), [LF], $lambda upright(P)$,
         "south-east")
  vlabel((b-br.at(0) + 0.20, b-br.at(1) - 0.15), [F + dep.],
         $lambda upright(P) 2$, "north-west")
  vlabel((b-tl.at(0) - 0.20, b-tl.at(1) + 0.15), [F$omega$ + dep.],
         $lambda upright(P) omega$, "south-east")
  // CIC: shift further right; stage tag drops below.
  vlabel((b-tr.at(0) + 0.55, b-tr.at(1) + 0.50), [CIC], $lambda upright(C)$,
         "south-west", stage: [Stage 6])

  // ── Axis 1: terms-on-types (generics) — bottom horizontal
  line(
    (-0.1, -1.4), (w + 0.1, -1.4),
    stroke: (paint: muted, thickness: 0.4pt),
    mark: (end: ">", fill: muted, scale: 0.4),
  )
  content((w / 2, -1.7),
    text(fill: muted, size: 9pt, [terms-on-types · generics]))

  // ── Axis 2: types-on-types (type operators) — right vertical
  // Anchored far enough right to clear the back-face labels.
  let axis-x = w + dx + 3.0
  line(
    (axis-x, -0.2), (axis-x, h + dy + 0.2),
    stroke: (paint: muted, thickness: 0.4pt),
    mark: (end: ">", fill: muted, scale: 0.4),
  )
  content(
    (axis-x + 0.4, (h + dy) / 2),
    angle: 90deg,
    text(fill: muted, size: 9pt, [types-on-types · type operators]),
  )

  // ── Axis 3: types-on-terms (dependent types) — depth/diagonal
  // Moved up-and-left from the original (-1.3, h+dy+0.25) so the arrow does
  // not cross over the "F + dep." label band.
  let dep-mid = (-2.0, h + dy + 0.95)
  let dep-half-len = 0.85
  let dep-len = calc.sqrt(dx * dx + dy * dy)
  let dep-dir-x = dx / dep-len
  let dep-dir-y = dy / dep-len
  let dep-start = (
    dep-mid.at(0) - dep-half-len * dep-dir-x,
    dep-mid.at(1) - dep-half-len * dep-dir-y,
  )
  let dep-end = (
    dep-mid.at(0) + dep-half-len * dep-dir-x,
    dep-mid.at(1) + dep-half-len * dep-dir-y,
  )
  line(
    dep-start, dep-end,
    stroke: (paint: muted, thickness: 0.4pt),
    mark: (end: ">", fill: muted, scale: 0.4),
  )
  let dep-angle = calc.atan2(dx, dy)
  let label-offset = 0.35
  let perp-x = -dep-dir-y * label-offset
  let perp-y =  dep-dir-x * label-offset
  content(
    (dep-mid.at(0) + perp-x, dep-mid.at(1) + perp-y),
    angle: dep-angle,
    text(fill: muted, size: 9pt, [types-on-terms · dependent types]),
  )
})

// Standalone-compile guard.
#lambda-cube-canvas
