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

#let slide-pad(body, top: pad-top, bottom: pad-bottom, x: pad-x) = pad(
  top: top,
  bottom: bottom,
  left: x,
  right: x,
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
    #set text(size: sz(28pt), fill: pal.fg)
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

#let signature-card(body) = block(
  width: 100%,
  fill: white,
  stroke: 0.5pt + pal.rule,
  radius: 3pt,
  inset: (x: 18pt, y: 16pt),
)[
  #set text(font: mono-font, size: sz(30pt), fill: pal.fg)
  #body
]

// ─── beat-grid ──────────────────────────────────────────────────────────────
//
// entries: array of (when, what, sub). `when` mono accent (30pt), `what` body
// 34pt, optional `sub` 28pt dim — matches `.beat-grid` from the CSS.

#let beat-grid(entries) = {
  set par(leading: 0.4em)
  grid(
    columns: (120pt, 1fr),
    gutter: 28pt,
    row-gutter: 20pt,
    ..entries.map(((when_, what_, sub)) => (
      {
        set text(
          font: mono-font,
          size: sz(30pt),
          weight: 500,
          fill: pal.accent,
        )
        when_
      },
      {
        set text(size: sz(34pt), fill: pal.fg)
        what_
        if sub != none and sub != [] {
          linebreak()
          set text(size: sz(28pt), fill: pal.fg-dim)
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
      // Middle: h1 + lede
      {
        set text(size: sz(168pt), weight: 300, fill: pal.fg-dark)
        set par(leading: -0.08em)
        h1
      },
      v(sz(gap-title)),
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
    #if eyebrow != none {
      eyebrow
      v(12pt)
    }
    {
      set text(size: sz(60pt), weight: 400, fill: pal.fg)
      set par(leading: 0.1em)
      h2
    }
    #v(sz(gap-title))
    #body
    #if footer != none {
      v(1fr)
      set text(font: mono-font, size: sz(26pt), fill: pal.fg-dim)
      footer
    }
  ]
]

// ─── .s-stage-opener ────────────────────────────────────────────────────────

#let stage-opener-slide(stage-num, h2, lang, one-liner) = slide-page(
  fill: pal.bg-dark,
  fg: pal.fg-dark,
)[
  #slide-pad[
    #grid(
      columns: (280pt, 1fr),  // 560px @ 0.5 scale
      gutter: sz(88pt),
      align: (left + horizon, left + horizon),
      // ── Left: stage number block
      {
        set text(
          font: mono-font,
          size: sz(360pt),
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
          set text(size: sz(84pt), weight: 300, fill: pal.fg-dark)
          set par(leading: 0em)
          h2
        }
        v(18pt)
        // lang
        {
          set text(
            font: mono-font,
            size: sz(30pt),
            fill: pal.fg-dark-dim,
            tracking: 0.02em,
          )
          lang
        }
        v(18pt)
        // 1px accent-strong rule then one-liner
        block(
          width: 100%,
          stroke: (top: 0.5pt + pal.rule-dark-strong),
          inset: (top: 16pt),
        )[
          #set text(size: sz(34pt), fill: pal.fg-dark)
          #set par(leading: 0.35em)
          #one-liner
        ]
      },
    )
  ]
]

// ─── .s-light ───────────────────────────────────────────────────────────────

#let light-slide(eyebrow: none, h2, body) = slide-page(
  fill: pal.bg,
  fg: pal.fg,
)[
  #slide-pad[
    #if eyebrow != none {
      eyebrow
      v(12pt)
    }
    {
      set text(size: sz(type-scale.title), weight: 400, fill: pal.fg)
      h2
    }
    #v(sz(gap-title))
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
    {
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
    {
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
    {
      set text(size: sz(92pt), weight: 300, fill: pal.fg)
      set par(leading: 0.05em)
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
      {
        set text(size: sz(280pt), weight: 200, fill: pal.accent)
        set par(leading: 0em)
        [Q&A]
      }
      #v(16pt)
      {
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
    let state-text = if closed { "CLOSED ✓" } else { state }
    block(
      width: 100%,
      inset: (x: sz(16pt), top: sz(14pt), bottom: sz(14pt)),
      stroke: bdr,
      radius: 3pt,
    )[
      #text(font: mono-font, size: sz(22pt), weight: 500, fill: pal.fg-dim, tracking: 0.04em)[#upper(name)]
      #v(sz(6pt))
      #text(size: sz(40pt), weight: 300, fill: pal.fg)[#what]
      #v(sz(8pt))
      #text(font: mono-font, size: sz(20pt), fill: state-color)[#state-text]
    ]
  }

  grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    gutter: sz(20pt),
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
  grid(
    columns: (1fr, 260pt),
    gutter: sz(40pt),
    align: (left + top, left + top),
    canvas-fn,
    stack(
      dir: ttb,
      spacing: sz(20pt),
      ..axes.map(axis => {
        let (tag, label, sub) = axis
        grid(
          columns: (sz(48pt), 1fr),
          gutter: sz(12pt),
          align: (left + top, left + top),
          text(font: mono-font, size: sz(22pt), weight: 500, fill: pal.accent)[#tag],
          stack(
            dir: ttb,
            spacing: sz(4pt),
            text(size: sz(28pt), fill: pal.fg)[#label],
            text(size: sz(22pt), fill: pal.fg-dim)[#sub],
          ),
        )
      }),
    ),
  )
}
