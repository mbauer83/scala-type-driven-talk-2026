// =============================================================================
// code-pane.typ — IDE-styled code display component.
//
// body: content containing a raw block created with
//       raw(lang: <language>, block: true, "...source...").
//       Plain text content is accepted for backward compat but produces no
//       line-number gutter or highlight tints.
//
// highlights: array of (line-number, kind)
//   kind ∈ "err" | "hl" | "hl-good"
// hover:      (line, col, text) or none — IDE hover-pop overlay
// diagnostic: (kind, label, body) or none — compiler output strip
//   kind ∈ "bad" | "good" | "note"
//
// Idris: pass language: "haskell" as fallback.
// Replace if idris.sublime-syntax is added to touying/themes/.
// =============================================================================

#import "theme.typ": pal, sz, type-scale, mono-font

#let code-pane(
  filename: "Demo.java",
  language: "java",
  body,
  highlights: (),
  hover:       none,
  diagnostic:  none,
  code-size:   type-scale.code-sm,              // default 24pt raw (12pt rendered) — fits more lines per pane
  height:      auto,                            // pass 100% to fill the grid row (equal-height columns)
  pad-y:       20pt,                            // code-area inset y, in slide-plan px. Lower it on a
                                                // slide carrying two panes and a caption strip; the
                                                // default is the comfortable single-pane value.
) = {
  let line-h     = sz(code-size) * 1.5
  let gutter-w   = sz(code-size) * 2.4          // ~2.2em gutter
  let gutter-gap = sz(code-size) * 1.6          // gap after gutter
  let ci-x       = sz(32pt)                     // code-area inset x
  let ci-y       = sz(pad-y)                    // code-area inset y

  // Return highlight kind string for line n, or none.
  let hl-kind(n) = {
    let k = none
    for h in highlights { if h.at(0) == n { k = h.at(1) } }
    k
  }

  block(
    width:  100%,
    height: height,
    fill:   pal.bg-dark-2,
    radius: sz(8pt),
    clip:   true,
    stroke: none,
  )[
    // ── Tab bar ───────────────────────────────────────────────────────────
    #block(
      width:  100%,
      fill:   pal.bg-dark,
      inset:  (x: sz(24pt), y: sz(14pt)),
      stroke: (bottom: 1pt + pal.rule-dark),
    )[
      #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dark-dim)
      #box(width: sz(8pt), height: sz(8pt), fill: pal.accent, radius: 50%)
      #h(sz(12pt))
      #text(fill: pal.fg-dark, weight: 500)[#filename]
    ]

    // ── Code area ─────────────────────────────────────────────────────────
    #block(
      width: 100%,
      inset: (x: ci-x, y: ci-y),
    )[
      #{
        // Dark syntax theme; base text colour for un-highlighted tokens.
        set raw(theme: "themes/dark.tmTheme")
        show raw: set text(font: mono-font, size: sz(code-size), fill: pal.fg-dark)

        // Per-line layout: gutter number + optional highlight tint.
        // Closure variables are inaccessible inside [content blocks] in show
        // rule closures in Typst 0.14 — use content concatenation (+) instead.
        show raw.line: it => {
          let n     = it.number
          let lbody = it.body
          let kind  = hl-kind(n)
          let bg    = if kind == "err"     { pal.bad.transparentize(72%)    }
                 else if kind == "hl"      { pal.accent.transparentize(84%) }
                 else if kind == "hl-good" { pal.good.transparentize(80%)   }
                 else                      { none                            }
          // Space-pad to 2 chars for visual right-alignment in monospace.
          let gnum = text(
            fill: rgb(73, 76, 88),    // #494c58
            size: sz(code-size),
            font: mono-font,
            (if n < 10 { " " } else { "" }) + str(n),
          )
          // Concatenate content in code mode — no nested content blocks.
          block(
            width: 100%, fill: bg, above: 0pt, below: 0pt,
            gnum + h(gutter-gap) + lbody,
          )
        }

        body
      }

      // ── Hover-pop overlay (placed after content; top+left = inside inset)
      #if hover != none {
        let (h-line, h-col, h-text) = hover
        // Position just above the target line.
        let dy = calc.max(0pt, (h-line - 2) * line-h)
        let dx = gutter-w + gutter-gap + h-col * sz(code-size) * 0.62
        place(top + left, dy: dy, dx: dx)[
          #block(
            fill:   rgb(42, 45, 58),    // #2a2d3a
            stroke: 1pt + pal.rule-dark-strong,
            radius: sz(6pt),
            inset:  (x: sz(18pt), y: sz(12pt)),
          )[
            #set text(font: mono-font, size: sz(24pt), fill: pal.fg-dark)
            #h-text
          ]
        ]
      }
    ]

    // ── Diagnostic strip ──────────────────────────────────────────────────
    #if diagnostic != none {
      let (d-kind, d-label, d-body) = diagnostic
      let d-fg  = if d-kind == "good" { pal.good         }
             else if d-kind == "note" { pal.fg-dark-dim  }
             else                     { pal.bad           }
      let lbl-fg = if d-kind == "good" { pal.good         }
              else if d-kind == "note" { pal.accent-soft  }
              else                     { pal.bad           }
      block(
        width:  100%,
        fill:   pal.bg-dark-3,
        inset:  (x: sz(40pt), y: sz(18pt)),
        stroke: (top: 1pt + pal.rule-dark),
      )[
        #set text(font: mono-font, size: sz(24pt), fill: d-fg)
        #text(weight: 700, fill: lbl-fg)[#d-label]
        #h(sz(8pt))
        #d-body
      ]
    }
  ]
}
