// =============================================================================
// code-pane.typ — IDE-styled code-pane component. STUB FOR PHASE 1.
//
// Phase 1 placeholder: renders a labelled dark box matching `.code-pane`'s
// outer chrome from style_other_presentation.css. Full implementation
// (gutter, per-line highlights, hover overlays, diagnostic strip, syntax
// highlighting) is the Phase 2 deliverable.
//
// The SIGNATURE below is final — do not change it in later phases.
// =============================================================================

#import "theme.typ": pal, sz, type-scale, mono-font

#let code-pane(
  filename: "Demo.java",
  language: "java",
  body,
  highlights: (),
  hover: none,
  diagnostic: none,
) = {
  let _summary = (
    "phase-1 stub · language=" + language
      + " · highlights=" + str(highlights.len())
      + " · hover=" + (if hover == none { "none" } else { "yes" })
      + " · diagnostic=" + (if diagnostic == none { "none" } else { "yes" })
  )

  block(
    width: 100%,
    fill: pal.bg-dark-2,
    radius: 4pt,
    clip: true,
    stroke: none,
  )[
    // ── Tab bar: bg-dark, accent dot + filename in mono
    #block(
      width: 100%,
      fill: pal.bg-dark,
      inset: (x: 12pt, y: 7pt),
      stroke: none,
    )[
      #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dark-dim)
      #box(
        width: 4pt,
        height: 4pt,
        fill: pal.accent,
        radius: 50%,
      )
      #h(8pt)
      #text(fill: pal.fg-dark, weight: 500)[#filename]
    ]
    // ── Code-area placeholder
    #block(
      width: 100%,
      inset: (x: 20pt, y: 16pt),
      stroke: none,
    )[
      #set text(font: mono-font, size: sz(type-scale.code), fill: pal.fg-dark)
      #text(fill: pal.fg-dark-faint)[#_summary]
      #linebreak()
      #text(fill: pal.fg-dark)[#body]
    ]
  ]
}
