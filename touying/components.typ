// =============================================================================
// components.typ — slide-class functions and reusable patterns.
//
// SIGNATURES are FINAL — do not change them in later phases.
// BODIES are layout stubs in Phase 1: each slide-class function applies the
// correct background fill, padding, and column grid drawn from
// style_other_presentation.css. Typography is refined in Phase 4 as real
// slide content lands.
//
// Pattern functions documented in Phase 3 (ladder, story-strip, test-list,
// lcube) are present here as // TODO stubs with their final signatures.
// =============================================================================

#import "theme.typ": *
#import "code-pane.typ": code-pane

// ─── helpers ────────────────────────────────────────────────────────────────

// speaker-note: no-op in PDF output — notes are for presenter reference only.
#let speaker-note(body) = []

// `slide-pad` wraps content in a fixed-size block sized to the slide chrome
// so that `v(1fr)` distributes the remaining vertical space (it would not
// work inside a plain `pad(...)`). The block fills the page (which is the
// only sized parent) and applies the four padding values as `inset`.
#let slide-pad(body, top: pad-top, bottom: pad-bottom, x: pad-x) = block(
  width: 100%,
  height: 100%,
  inset: (top: top, bottom: bottom, left: x, right: x),
  body,
)

// ─── small primitive: eyebrow ───────────────────────────────────────────────
//
// `eyebrow(text, style: "normal" | "accent" | "bad" | "dark")` — mono uppercase
// label that sits at the top of every body slide. The CSS `.eyebrow` class
// uses 26px JetBrains Mono with letter-spacing 0.02em.

#let eyebrow(body, style: "normal") = {
  let color = if style == "accent" {
    pal.accent
  } else if style == "bad" {
    pal.bad
  } else if style == "dark" {
    pal.fg-dark-dim
  } else {
    pal.fg-dim
  }
  set text(
    font: mono-font,
    size: sz(26pt),
    weight: 500,
    fill: color,
    tracking: 0.02em,
  )
  upper(body)
}

// ─── small primitive: callout ───────────────────────────────────────────────

#let callout(label, body, style: "accent") = {
  let bar-color = if style == "bad" { pal.bad } else { pal.accent }
  let bg-tint = if style == "bad" {
    rgb(196, 79, 62, 15)   // ≈ 6% alpha
  } else {
    rgb(217, 151, 87, 20)  // ≈ 8% alpha
  }
  block(
    width: 100%,
    inset: (left: 16pt, right: 16pt, top: 12pt, bottom: 12pt),
    fill: bg-tint,
    stroke: (left: 2pt + bar-color),
  )[
    // Body text inherits the slide's foreground colour (set by `slide-page`)
    // so the callout reads on both light and dark slides.
    #set text(size: sz(28pt))
    #text(
      font: mono-font,
      size: sz(22pt),
      weight: 500,
      fill: bar-color,
      tracking: 0.06em,
    )[#upper(label)]
    #linebreak()
    #body
  ]
}

// ─── small primitive: signature-card ────────────────────────────────────────

// signature-card: a method-signature panel styled to match `.code-pane` on dark
// slides. Phantom-typestate signatures get `pal.accent` highlighting on the
// state-marked parameter (use `*`pal.accent`*` markup or pre-coloured spans
// within `body`).
#let signature-card(body) = block(
  width: 100%,
  fill: pal.bg-dark-2,
  stroke: 0.5pt + pal.rule-dark-strong,
  radius: sz(8pt),
  inset: (x: sz(28pt), y: sz(22pt)),
)[
  #set text(font: mono-font, size: sz(28pt), fill: pal.fg-dark)
  #show strong: it => text(fill: pal.accent, weight: 500, it.body)
  #set par(leading: 0.45em)
  #body
]

// ─── beat-grid ──────────────────────────────────────────────────────────────
//
// entries: array of (when, what, sub). `when` mono accent (30pt), `what` body
// 34pt, optional `sub` 28pt dim — matches `.beat-grid` from the CSS.

#let beat-grid(entries) = {
  set par(leading: 0.55em)
  grid(
    columns: (140pt, 1fr),
    gutter: sz(28pt),
    row-gutter: sz(48pt),    // inter-row spacing — must clearly exceed intra-row gap
    ..entries.map(((when_, what_, sub)) => (
      {
        set text(
          font: mono-font,
          size: sz(28pt),
          weight: 500,
          fill: pal.accent,
        )
        when_
      },
      {
        set text(size: sz(32pt), weight: 500, fill: pal.fg)
        what_
        if sub != none and sub != [] {
          linebreak()
          set text(size: sz(26pt), weight: 400, fill: pal.fg-dim)
          sub
        }
      },
    )).flatten()
  )
}

// =============================================================================
// SLIDE-CLASS FUNCTIONS
// =============================================================================

// ─── .s-title ───────────────────────────────────────────────────────────────

#let title-slide(eyebrow: none, h1, lede, meta-left, meta-right) = slide-page(
  fill: pal.bg-dark,
  fg: pal.fg-dark,
)[
  #slide-pad[
    #stack(
      dir: ttb,
      spacing: 0pt,
      // Top: optional eyebrow
      if eyebrow != none { eyebrow } else { [] },
      v(1fr),
      // Middle: h1 + lede — lede gap exceeds intra-h1 line spacing
      {
        set text(size: sz(168pt), weight: 300, fill: pal.fg-dark)
        set par(leading: 0.32em)
        h1
      },
      v(sz(120pt)),
      {
        set text(size: sz(44pt), weight: 300, fill: pal.fg-dark-dim)
        set par(leading: 0.25em)
        lede
      },
      v(1fr),
      // Bottom: meta-left + meta-right
      {
        set text(font: mono-font, size: sz(26pt), fill: pal.fg-dark-faint)
        grid(
          columns: (1fr, 1fr),
          align: (left, right),
          meta-left, meta-right,
        )
      },
    )
  ]
]

// ─── .s-incident ────────────────────────────────────────────────────────────

#let incident-slide(role, name, verdict, heading, story, bug-line) = slide-page(
  fill: pal.bg,
  fg: pal.fg,
)[
  #slide-pad[
    #grid(
      columns: (260pt, 1fr),  // 520px @ 0.5 scale
      gutter: sz(88pt),
      // ── Left column: person-block
      {
        // role
        {
          set text(
            font: mono-font,
            size: sz(26pt),
            fill: pal.accent,
            tracking: 0.02em,
          )
          role
        }
        v(9pt)
        // name
        {
          set text(size: sz(112pt), weight: 300, fill: pal.fg)
          set par(leading: -0.08em)
          name
        }
        v(18pt)
        // verdict
        {
          set text(size: sz(30pt), fill: pal.fg-dim)
          verdict
        }
      },
      // ── Right column: story + bug-line
      {
        // heading
        {
          set text(size: sz(38pt), weight: 500, fill: pal.fg)
          heading
        }
        v(14pt)
        // story
        {
          set text(size: sz(30pt), fill: pal.fg-dim)
          story
        }
        v(14pt)
        // bug-line: mono mini-callout w/ bad left bar
        block(
          width: 100%,
          fill: rgb(0, 0, 0, 10),
          stroke: (left: 2pt + pal.bad),
          inset: (x: 16pt, y: 12pt),
        )[
          #set text(font: mono-font, size: sz(28pt), fill: pal.fg)
          #bug-line
        ]
      },
    )
  ]
]

// ─── .s-theory ──────────────────────────────────────────────────────────────

#let theory-slide(eyebrow: none, h2, body, footer: none) = slide-page(
  fill: pal.bg,
  fg: pal.fg,
)[
  #slide-pad[
    #grid(
      columns: 1,
      rows: (auto, gap-title * 1.3, auto, 1fr, auto),
      // ── Row 1: eyebrow (optional) + title block
      {
        if eyebrow != none {
          eyebrow
          v(sz(6pt))
        }
        set text(size: sz(60pt), weight: 400, fill: pal.fg)
        set par(leading: 0.18em)
        h2
      },
      // ── Row 2: gap-title spacer (fixed-height row)
      [],
      // ── Row 3: body content
      body,
      // ── Row 4: fr spacer pushing footer to bottom
      [],
      // ── Row 5: footer pinned to bottom
      if footer != none {
        set text(font: mono-font, size: sz(26pt), fill: pal.fg-dim)
        footer
      } else { [] },
    )
  ]
]

// ─── .s-stage-opener ────────────────────────────────────────────────────────

#let stage-opener-slide(stage-num, h2, lang, one-liner) = slide-page(
  fill: pal.bg-dark,
  fg: pal.fg-dark,
)[
  #slide-pad[
    #grid(
      columns: (sz(220pt), 1fr),
      gutter: sz(48pt),
      align: (left + horizon, left + top),
      // ── Left: stage number block
      {
        set text(
          font: mono-font,
          size: sz(320pt),
          weight: 400,
          fill: pal.accent,
        )
        set par(leading: -0.15em)
        stage-num
      },
      // ── Right: heading + lang + one-liner
      {
        // h2
        {
          set text(size: sz(64pt), weight: 300, fill: pal.fg-dark)
          set par(leading: 0.18em)
          h2
        }
        v(sz(10pt))
        // lang
        {
          set text(
            font: mono-font,
            size: sz(26pt),
            fill: pal.fg-dark-dim,
            tracking: 0.02em,
          )
          lang
        }
        v(sz(14pt))
        // 1px accent-strong rule then one-liner
        block(
          width: 100%,
          stroke: (top: 0.5pt + pal.rule-dark-strong),
          inset: (top: sz(14pt)),
        )[
          #set text(size: sz(32pt), fill: pal.fg-dark)
          #set par(leading: 0.32em)
          #one-liner
        ]
      },
    )
  ]
]

// ─── .s-light ───────────────────────────────────────────────────────────────

#let light-slide(eyebrow: none, h2, body, body-gap: gap-title) = slide-page(
  fill: pal.bg,
  fg: pal.fg,
)[
  #slide-pad[
    #if eyebrow != none {
      eyebrow
      v(sz(6pt))
    }
    #{
      set text(size: sz(type-scale.title), weight: 400, fill: pal.fg)
      set par(leading: 0.18em)
      h2
    }
    #v(body-gap)
    #body
  ]
]

// ─── .s-bignum ──────────────────────────────────────────────────────────────

#let bignum-slide(big, label) = slide-page(
  fill: pal.bg-dark,
  fg: pal.fg-dark,
)[
  #slide-pad[
    #v(1fr)
    #{
      set text(
        font: mono-font,
        size: sz(360pt),
        weight: 300,
        fill: pal.accent,
      )
      set par(leading: -0.10em)
      big
    }
    #v(20pt)
    #{
      set text(size: sz(44pt), weight: 300, fill: pal.fg-dark)
      set par(leading: 0.25em)
      label
    }
    #v(1fr)
  ]
]

// ─── .s-close ───────────────────────────────────────────────────────────────

#let close-slide(big-stmt) = slide-page(
  fill: pal.bg,
  fg: pal.fg,
)[
  #slide-pad[
    #v(1fr)
    #{
      set text(size: sz(54pt), weight: 300, fill: pal.fg)
      set par(leading: 0.4em, justify: false)
      big-stmt
    }
    #v(1fr)
  ]
]

// ─── .s-qa ──────────────────────────────────────────────────────────────────

#let qa-slide() = slide-page(
  fill: pal.bg-dark,
  fg: pal.fg-dark,
)[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #{
        set text(size: sz(280pt), weight: 200, fill: pal.accent)
        set par(leading: 0em)
        [Q&A]
      }
      #v(16pt)
      #{
        set text(size: sz(36pt), weight: 300, fill: pal.fg-dark-dim)
        [Questions, comments, war stories — let's hear them.]
      }
    ]
    #v(1fr)
  ]
]

// =============================================================================
// PATTERNS (Phase 3)
// =============================================================================

// ─── ladder ──────────────────────────────────────────────────────────────────
//
// Three-column DOCUMENTED / TESTED / ENCODED grid. The ENCODED column gets an
// pal.accent background tint when encoded-active is true.

#let ladder(documented, tested, encoded, encoded-active: false) = {
  let enc-fill = if encoded-active { pal.accent.transparentize(80%) } else { none }
  let enc-label-color = if encoded-active { pal.accent } else { pal.fg-dim }
  let sep = 0.5pt + pal.rule

  block(width: 100%, stroke: sep, radius: 3pt, clip: true)[
    #grid(
      columns: (1fr, 1fr, 1fr),
      row-gutter: 0pt,
      column-gutter: 0pt,
      // ── header row
      block(width: 100%, inset: (x: sz(18pt), y: sz(10pt)), stroke: (bottom: sep))[
        #text(font: mono-font, size: sz(20pt), weight: 500, fill: pal.fg-dim, tracking: 0.05em)[DOCUMENTED]
      ],
      block(width: 100%, inset: (x: sz(18pt), y: sz(10pt)), stroke: (bottom: sep, left: sep))[
        #text(font: mono-font, size: sz(20pt), weight: 500, fill: pal.fg-dim, tracking: 0.05em)[TESTED]
      ],
      block(width: 100%, fill: enc-fill, inset: (x: sz(18pt), y: sz(10pt)), stroke: (bottom: sep, left: sep))[
        #text(font: mono-font, size: sz(20pt), weight: 500, fill: enc-label-color, tracking: 0.05em)[ENCODED]
      ],
      // ── body row
      block(width: 100%, inset: (x: sz(18pt), y: sz(16pt)))[
        #set text(size: sz(28pt), fill: pal.fg)
        #documented
      ],
      block(width: 100%, inset: (x: sz(18pt), y: sz(16pt)), stroke: (left: sep))[
        #set text(size: sz(28pt), fill: pal.fg)
        #tested
      ],
      block(width: 100%, fill: enc-fill, inset: (x: sz(18pt), y: sz(16pt)), stroke: (left: sep))[
        #set text(size: sz(28pt), fill: pal.fg)
        #encoded
      ],
    )
  ]
}

// ─── story-strip ─────────────────────────────────────────────────────────────
//
// Four-column chip strip. chips: array of (name, what, state, closed).
// Closed chips: pal.accent border + "CLOSED ✓" state label.
// Open chips: pal.rule-strong border + dim state label.

#let story-strip(chips) = {
  let chip-card(chip) = {
    let (name, what, state, closed) = chip
    let bdr = if closed { 1.5pt + pal.accent } else { 0.5pt + pal.rule-strong }
    let state-color = if closed { pal.accent } else { pal.fg-dim }
    let state-text = if closed { "CLOSED ✓" } else { upper(state) }
    // Chip sizes naturally to its content. Across the row, chips with longer
    // `what` text are slightly taller — the row uses `auto` height (not 1fr)
    // so the strip never overflows when the test-list above is tall.
    block(
      width: 100%,
      inset: (x: sz(16pt), top: sz(14pt), bottom: sz(14pt)),
      stroke: bdr,
      radius: 4pt,
    )[
      #stack(
        dir: ttb,
        spacing: 0pt,
        text(font: mono-font, size: sz(18pt), weight: 500, fill: pal.fg-dim, tracking: 0.04em)[#upper(name)],
        v(sz(8pt)),
        {
          set par(leading: 0.4em)
          text(size: sz(22pt), weight: 400, fill: pal.fg)[#what]
        },
        v(sz(10pt)),
        text(font: mono-font, size: sz(18pt), weight: 500, fill: state-color, tracking: 0.04em)[#state-text],
      )
    ]
  }

  grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    rows: (auto,),
    gutter: sz(16pt),
    ..chips.map(chip-card),
  )
}

// ─── test-list ───────────────────────────────────────────────────────────────
//
// Grid of test rows. items: array of (idx, desc, closes, state).
// state ∈ "active" | "just-gone" | "gone".
// just-gone: pal.good-bg tint + strikethrough in pal.good.
// gone: strikethrough, text faded to pal.fg-faint.

#let test-list(items) = {
  let sep = 0.5pt + pal.rule
  let row-sep = 0.5pt + pal.rule

  let make-header(label, left-sep: false) = block(
    width: 100%,
    inset: (x: sz(12pt), y: sz(8pt)),
    stroke: if left-sep { (bottom: sep, left: sep) } else { (bottom: sep) },
  )[
    #text(font: mono-font, size: sz(18pt), weight: 500, fill: pal.fg-dim, tracking: 0.05em)[#upper(label)]
  ]

  let make-cell(body, state: "active", left-sep: false) = {
    let bg = if state == "just-gone" { pal.good-bg } else { none }
    let text-fill = if state == "gone" { pal.fg-faint } else { pal.fg }
    let stk = if left-sep { (bottom: row-sep, left: sep) } else { (bottom: row-sep) }
    let decorated = if state == "just-gone" {
      strike(body, stroke: 0.6pt + pal.good)
    } else if state == "gone" {
      strike(body)
    } else {
      body
    }
    block(
      width: 100%,
      fill: bg,
      inset: (x: sz(12pt), y: sz(7pt)),
      stroke: stk,
    )[
      #set text(size: sz(26pt), fill: text-fill)
      #decorated
    ]
  }

  let header-cells = (
    make-header("idx"),
    make-header("description", left-sep: true),
    make-header("closes", left-sep: true),
  )

  let data-cells = items.map(item => {
    let (idx, desc, closes, state) = item
    (
      make-cell(idx, state: state),
      make-cell(desc, state: state, left-sep: true),
      make-cell(closes, state: state, left-sep: true),
    )
  }).flatten()

  block(width: 100%, stroke: sep, radius: 3pt, clip: true)[
    #grid(
      columns: (44pt, 1fr, 140pt),
      row-gutter: 0pt,
      column-gutter: 0pt,
      ..header-cells,
      ..data-cells,
    )
  ]
}

// ─── lcube ───────────────────────────────────────────────────────────────────
//
// Pairs a cetz canvas (left, 1fr) with an axis legend (right, fixed).
// axes: array of (tag, label, sub).

#let lcube(canvas-fn, axes) = {
  // Two fixed-width columns sized so the legend left-edge sits at ~62.5% of
  // the slide width. With content width 848pt and pad-x 56pt: legend starts
  // at content-offset 544pt, so canvas column (incl. gutter) is 544pt. The
  // canvas is left-aligned in its column so the cube doesn't get pushed to
  // the right edge.
  grid(
    columns: (524pt, 304pt),
    gutter: 20pt,
    align: (left + horizon, left + horizon),
    canvas-fn,
    stack(
      dir: ttb,
      spacing: sz(40pt),                       // inter-row spacing — must exceed intra-row gap
      // Legend title — "Dependency Directions"
      text(
        font: mono-font, size: sz(24pt), weight: 600,
        fill: pal.fg-dim, tracking: 0.06em,
      )[DEPENDENCY DIRECTIONS],
      // Legend entries
      ..axes.map(axis => {
        let (tag, label, sub) = axis
        grid(
          columns: (sz(64pt), 1fr),
          gutter: sz(16pt),
          align: (left + top, left + top),
          text(font: mono-font, size: sz(28pt), weight: 600, fill: pal.accent)[#tag],
          stack(
            dir: ttb,
            spacing: sz(8pt),                  // intra-row name → sub gap
            text(size: sz(28pt), weight: 500, fill: pal.fg)[#label],
            text(size: sz(22pt), fill: pal.fg-dim)[#sub],
          ),
        )
      }),
    ),
  )
}
