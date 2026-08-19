// Build: typst compile test-code-pane.typ test-code-pane.pdf =================
// ============================================================

#import "theme.typ": pal, sz, type-scale, our-theme, slide-page, mono-font
#import "code-pane.typ": code-pane

#show: our-theme

// ─── Single validation slide ─────────────────────────────────────────────────

#slide-page(fill: pal.bg-dark-2)[
  #set text(fill: pal.fg-dark)
  #pad(x: sz(40pt), y: sz(32pt))[
    #text(font: mono-font, size: sz(24pt), fill: pal.fg-dark-dim)[
      Phase 2 · code-pane validation
    ]
    #v(sz(20pt))

    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: sz(24pt),

      // ── (a) Scala · err highlight on line 4 · hover-pop on line 4 ─────────
      code-pane(
        filename: "Domain.scala",
        language: "scala",
        raw(
          lang: "scala",
          block: true,
          "sealed trait Risk\ncase object Low  extends Risk\ncase object High extends Risk\n\ndef assess(r: Risk): String =\n  r match\n    case Low  => \"ok\"\n    case High => \"refer\"",
        ),
        highlights: ((4, "err"),),
        hover: (4, 4, "found: Unit\nexpected: String"),
      ),

      // ── (b) Java · diag-line --bad strip ──────────────────────────────────
      code-pane(
        filename: "Demo.java",
        language: "java",
        raw(
          lang: "java",
          block: true,
          "sealed interface Risk\n  permits Low, Medium, High {}\n\nswitch (risk) {\n  case Low  l -> authorize(order);\n  case High h -> refer(order);\n}",
        ),
        highlights: ((1, "hl"),),
        diagnostic: ("bad", "error:", "switch is not exhaustive: missing case Medium"),
      ),

      // ── (c) Haskell / Idris fallback · clean ──────────────────────────────
      // Idris uses Haskell grammar; replace if idris.sublime-syntax added.
      code-pane(
        filename: "Main.idr",
        language: "haskell",
        raw(
          lang: "haskell",
          block: true,
          "data Payment\n  = Pending OrderId Amount\n  | Authorised OrderId Amount\n  | Settled OrderId\n\nassess : Payment -> String\nassess (Settled _) = \"done\"",
        ),
      ),
    )
  ]
]
