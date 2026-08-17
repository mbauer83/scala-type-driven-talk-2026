// =============================================================================
// Slide 11 — The Lambda Cube (with 2×2 dependency matrix)
// =============================================================================
//
// Compile:  typst compile slide-11-lambda-cube.typ slide-11-lambda-cube.svg
// =============================================================================

#import "@preview/cetz:0.5.2"

// ─── Page / theme ───────────────────────────────────────────────────────────

// 16:9 widescreen slide at a comfortable print scale (25.4cm × 14.29cm).
#set page(
  width: 25.4cm,
  height: 14.29cm,
  margin: (x: 1.4cm, y: 0.9cm),
  fill: rgb("#0d1117"),
)
#set text(fill: rgb("#e6edf3"), font: "New Computer Modern", size: 14pt)
#set par(leading: 0.5em)

#let accent      = rgb("#79c0ff")
#let stage-color = rgb("#ffd33d")
#let muted       = rgb("#8b949e")
#let back-edge   = rgb("#6e7681")
#let highlight   = rgb("#ff7b72")

// ─── Dependency matrix (native Typst table — cleaner for a text grid) ───────

#let dep-matrix = table(
  columns: (auto, 1fr, 1fr),
  rows: (auto, auto, auto),
  align: (right + horizon, center + horizon, center + horizon),
  stroke: (paint: muted, thickness: 0.5pt),
  inset: 0.6em,
  fill: (col, row) => if row == 0 or col == 0 { rgb("#161b22") } else { none },

  // Header row
  table.cell(
    align: center + horizon,
    fill: none,
    stroke: none,
    [#text(fill: muted, size: 11pt)[depends on →]],
  ),
  [#text(fill: accent, weight: "bold")[terms]],
  [#text(fill: accent, weight: "bold")[types]],

  // Row 1 — the term uses …
  [#text(fill: accent, weight: "bold")[the term]\
   #text(fill: muted, size: 11pt)[uses…]],
  [function application\
   #text(fill: muted, size: 10pt)[(every language)]],
  [polymorphic functions\
   #text(fill: muted, size: 10pt)[generics, $forall$]\
   #text(fill: stage-color, size: 10pt)[Stage 2 →]],

  // Row 2 — the type uses …
  [#text(fill: accent, weight: "bold")[the type]\
   #text(fill: muted, size: 11pt)[uses…]],
  [dependent types ($Pi, Sigma$)\
   #text(fill: muted, size: 10pt)[the type itself reads a value]\
   #text(fill: stage-color, size: 10pt)[Stage 7]],
  [type constructors + match types\
   #text(fill: muted, size: 10pt)[List[T], Dual[P], …]\
   #text(fill: stage-color, size: 10pt)[Stages 5–6]],
)

// ─── Lambda cube (cetz) ─────────────────────────────────────────────────────
//
// 3D cube projected with depth offset. Front face = the two non-dependent
// axes (terms-on-types horizontally, types-on-types vertically). Back face
// adds dependent types (types-on-terms).
//
// Highlighted in red: the path the stages of the talk trace —
// λ→ (Stage 1) → λ2 (Stage 2) → λω→ (Stages 5–6) → λC (Stage 7).

#let lambda-cube = cetz.canvas({
  import cetz.draw: *

  // Cube geometry (compact)
  let w = 3.2                                       // front face width
  let h = 2.4                                       // front face height
  let dx = 0.9                                      // depth offset x
  let dy = 0.75                                     // depth offset y

  let f-bl = (0, 0)
  let f-br = (w, 0)
  let f-tl = (0, h)
  let f-tr = (w, h)
  let b-bl = (dx, dy)
  let b-br = (w + dx, dy)
  let b-tl = (dx, h + dy)
  let b-tr = (w + dx, h + dy)

  // ── Back face — dashed, dim
  let back = (paint: back-edge, thickness: 0.6pt, dash: "dashed")
  line(b-bl, b-br, stroke: back)
  line(b-bl, b-tl, stroke: back)
  line(b-br, b-tr, stroke: back)
  line(b-tl, b-tr, stroke: back)

  // ── Connecting edges (front-to-back) — dim
  let conn = (paint: back-edge, thickness: 0.6pt)
  line(f-bl, b-bl, stroke: conn)
  line(f-br, b-br, stroke: conn)
  line(f-tl, b-tl, stroke: conn)
  line(f-tr, b-tr, stroke: conn)

  // ── Front face — solid
  let front = (paint: rgb("#e6edf3"), thickness: 0.9pt)
  line(f-bl, f-br, stroke: front)
  line(f-bl, f-tl, stroke: front)
  line(f-br, f-tr, stroke: front)
  line(f-tl, f-tr, stroke: front)

  // ── Highlight path: λ→ → λ2 → λω→ → λC (the talk's route)
  let path = (paint: highlight, thickness: 1.8pt)
  line(f-bl, f-br, stroke: path)
  line(f-br, f-tr, stroke: path)
  line(f-tr, b-tr, stroke: path)

  // ── Vertices: small filled dot for visual anchor
  let dot = (radius: 0.07, fill: rgb("#e6edf3"), stroke: none)
  let highlight-dot = (radius: 0.10, fill: highlight, stroke: none)
  for p in (f-bl, f-tl, f-br, f-tr) { circle(p, ..dot) }
  for p in (b-bl, b-tl, b-br, b-tr) { circle(p, radius: 0.06, fill: back-edge, stroke: none) }
  // Re-highlight the four stage vertices
  for p in (f-bl, f-br, f-tr, b-tr) { circle(p, ..highlight-dot) }

  // ── Vertex labels
  //
  // Compact two-row scheme:
  //   Row 1: "Primary name  (λ-name)"  — one line, with the λ-name as a
  //          muted parenthetical to the right of the system name.
  //   Row 2: stage tag (only for the four vertices on the talk path).
  //
  // This halves the vertical extent compared with a three-row stack and
  // avoids back-face / front-face label interleaving along the depth edge.

  let vlabel(pos, name, lam, anchor, stage: none) = {
    let row1-y = pos.at(1)
    let row2-y = if anchor.contains("south") {
      pos.at(1) + 0.55
    } else {
      pos.at(1) - 0.55
    }
    let line = [#text(weight: "medium", name) #text(fill: muted, size: 9pt, [(#lam)])]
    content((pos.at(0), row1-y), line, anchor: anchor)
    if stage != none {
      content(
        (pos.at(0), row2-y),
        text(fill: stage-color, size: 9pt, weight: "bold", stage),
        anchor: anchor,
      )
    }
  }

  // Front face — primary name + λ-name + (where on path) stage tag.
  // Anchor offsets pull labels well clear of vertices and edges.
  vlabel((f-bl.at(0) - 0.25, f-bl.at(1) - 0.15), [STLC], $lambda arrow.r$,
         "north-east", stage: [Stage 1])
  vlabel((f-br.at(0) + 0.25, f-br.at(1) - 0.15), [System F], $lambda 2$,
         "north-west", stage: [Stage 2])

  // Front-top vertices: shift labels noticeably ABOVE the vertices so that
  // the depth edge running from f-tr to b-tr (the highlighted red path
  // segment) does not cross the "System F$omega$" text.
  vlabel((f-tl.at(0) - 0.25, f-tl.at(1) + 0.40), [F$omega$⁻], $lambda omega$,
         "south-east")
  vlabel((f-tr.at(0) + 0.25, f-tr.at(1) + 0.40), [System F$omega$],
         $lambda omega arrow.r$, "south-west", stage: [Stages 5–6])

  // Back face — labels just outside their respective vertices.
  vlabel((b-bl.at(0) - 0.20, b-bl.at(1) + 0.15), [LF], $lambda upright(P)$,
         "south-east")
  vlabel((b-br.at(0) + 0.25, b-br.at(1) - 0.15), [F + dep.],
         $lambda upright(P) 2$, "north-west")
  vlabel((b-tl.at(0) - 0.20, b-tl.at(1) + 0.15), [F$omega$ + dep.],
         $lambda upright(P) omega$, "south-east")

  // Back-top-right (CIC / λC / Stage 7). Pushed up enough so its row 1
  // sits clear above f-tr's stage-tag row (which sits at f-tr.y + 0.95 = 3.35,
  // and b-tr.y is 3.15). Row 1 at b-tr.y + 0.55 puts CIC at y = 3.70 — a
  // 0.35 visible gap above f-tr's "Stages 5–6" tag.
  vlabel((b-tr.at(0) + 0.25, b-tr.at(1) + 0.55), [CIC], $lambda upright(C)$,
         "south-west", stage: [Stage 7])

  // ── Axis labels — placed clear of vertex labels but kept close to the cube
  // so the overall canvas stays compact.
  //
  // Bottom: generics axis (terms-on-types). Stage 1 / Stage 2 tags sit at
  // y = f-?.y - 0.70 (row-2 offset, anchor north-*). Bottom axis stays
  // 0.5 units below that.
  line(
    (-0.1, -1.4), (w + 0.1, -1.4),
    stroke: (paint: muted, thickness: 0.4pt),
    mark: (end: ">", fill: muted, scale: 0.4),
  )
  content((w / 2, -1.7),
    text(fill: muted, size: 9pt, [terms-on-types · generics]))

  // Right: type-operators axis (types-on-types).
  // Pushed well clear of the back-face primary labels. The widest right-side
  // label is "F$omega$ + dep." at b-tl on the back-top-left, but the relevant
  // right-axis-overlapping ones are at b-br (≈ "F + dep.") and b-tr (≈ "CIC")
  // — these extend right from b-?r.x + 0.20 + label-width. With body 14pt,
  // "F + dep." is roughly 2 units wide, so it extends to b-br.x + 2.2.
  // We anchor the axis at b-br.x + 3.0 (= w + dx + 3.0) to leave clear gap.
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

  // Upper-left diagonal: dependent-types axis (types-on-terms).
  // Direction = depth vector (dx, dy) — same direction as the connecting
  // edges from front face to back face. Placed in the empty upper-left
  // region so the arrow's mid-point sits clearly to the top-left of the
  // "F" in "F$omega$ + dep." (the b-tl primary label).
  let dep-mid = (-1.3, h + dy + 0.25)
  let dep-half-len = 0.75
  let dep-len = calc.sqrt(dx * dx + dy * dy)
  let dep-dir-norm-x = dx / dep-len
  let dep-dir-norm-y = dy / dep-len
  let dep-start = (
    dep-mid.at(0) - dep-half-len * dep-dir-norm-x,
    dep-mid.at(1) - dep-half-len * dep-dir-norm-y,
  )
  let dep-end = (
    dep-mid.at(0) + dep-half-len * dep-dir-norm-x,
    dep-mid.at(1) + dep-half-len * dep-dir-norm-y,
  )
  line(
    dep-start, dep-end,
    stroke: (paint: muted, thickness: 0.4pt),
    mark: (end: ">", fill: muted, scale: 0.4),
  )
  // Label diagonal, aligned with the arrow direction. atan(dy/dx) ≈ 39.8°.
  // In Typst, positive angles rotate counter-clockwise; passing the angle
  // makes the baseline of the text run along the arrow.
  let dep-angle = calc.atan2(dx, dy)  // returns angle whose tan = dy/dx
  // dep-angle gives the angle of the (dx, dy) vector from positive x axis.
  // calc.atan2(y, x) but typst's argument order is (x, y) per their docs.
  // Place label slightly above the arrow line.
  let label-offset = 0.35  // distance perpendicular to the arrow
  let perp-x = -dep-dir-norm-y * label-offset
  let perp-y =  dep-dir-norm-x * label-offset
  content(
    (dep-mid.at(0) + perp-x, dep-mid.at(1) + perp-y),
    angle: dep-angle,
    text(fill: muted, size: 9pt, [types-on-terms · dependent types]),
  )
})

// ─── Slide assembly ─────────────────────────────────────────────────────────

#text(size: 22pt, weight: "bold")[The Lambda Cube]

#v(0.3em)

#text(size: 13pt)[
  A program is built from #text(fill: accent, weight: "bold")[terms]
  (values, expressions — what exists at runtime) and
  #text(fill: accent, weight: "bold")[types] (the descriptions the compiler
  reasons about). Construction can mix the two in four ways:
]

#v(0.4em)

// Two-column layout: matrix on the left, cube on the right
#grid(
  columns: (9cm, 1fr),
  column-gutter: 0.8cm,
  align: (left + horizon, center + horizon),

  // ── Left: dependency matrix
  align(center)[
    #dep-matrix
  ],

  // ── Right: lambda cube
  align(center)[
    #lambda-cube
  ],
)

#v(0.4em)

// ─── Bottom takeaway ────────────────────────────────────────────────────────

#block(
  inset: (x: 0.8em, y: 0.4em),
  stroke: (left: 2pt + highlight),
  width: 100%,
)[
  #text(size: 12pt)[
    Stages 1–6 move along the first two axes
    (#text(fill: highlight)[terms-on-types], #text(fill: highlight)[types-on-types]).
    *Stage 7 crosses into the third* (#text(fill: highlight)[types-on-terms]) —
    what makes it qualitatively different from the others.
  ]
]
