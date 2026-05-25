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
// PATTERN STUBS (Phase 3)
//
// Final signatures, empty bodies. Each emits a labelled placeholder block so
// Phase 1 test slides that reference them still render something visible.
// =============================================================================

// TODO Phase 3 — render DOCUMENTED / TESTED / ENCODED columns with the
// encoded rung optionally highlighted in accent.
#let ladder(documented, tested, encoded, encoded-active: false) = block(
  width: 100%,
  inset: 12pt,
  stroke: 0.5pt + pal.rule,
)[
  #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dim)
  // TODO(phase-3): ladder() — 3-column DOCUMENTED / TESTED / ENCODED grid
  ladder() · encoded-active = #encoded-active
]

// TODO Phase 3 — render four chips for Alice / Bob / Charlie / Danielle with
// `.--closed` flipping the border to accent and the state to "CLOSED ✓".
//   chips: array of (name, what, state, closed: bool)
#let story-strip(chips) = block(
  width: 100%,
  inset: 12pt,
  stroke: 0.5pt + pal.rule,
)[
  #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dim)
  // TODO(phase-3): story-strip() — chips: #chips.len() entries
  story-strip() · chips = #chips.len()
]

// TODO Phase 3 — render 9 test rows with idx / desc / closes columns and
// state ∈ "active" | "just-gone" | "gone".
//   items: array of (idx, desc, closes, state)
#let test-list(items) = block(
  width: 100%,
  inset: 12pt,
  stroke: 0.5pt + pal.rule,
)[
  #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dim)
  // TODO(phase-3): test-list() — items: #items.len() rows
  test-list() · items = #items.len()
]

// TODO Phase 3 — pair the lambda-cube cetz canvas with the axis legend on the
// right; axes is an array of (tag, label, sub).
#let lcube(svg-or-cetz, axes) = block(
  width: 100%,
  inset: 12pt,
  stroke: 0.5pt + pal.rule,
)[
  #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dim)
  // TODO(phase-3): lcube() — axes: #axes.len() rows
  lcube() · axes = #axes.len()
]
