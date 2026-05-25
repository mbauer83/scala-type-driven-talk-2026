# Touying deck — component API

Authoritative reference for every public binding exported by `theme.typ`,
`components.typ`, `code-pane.typ`, and `diagrams/*.typ`. Phases 2–7 work from
this file; the underlying `.typ` sources are not consulted unless an entry
here is missing or ambiguous.

All sizes in this file are stated as raw "slide-plan px" values (e.g. `32pt`).
The on-page render multiplies them by `scale` (= 0.5).

---

## `theme.typ`

### Constants

| Name | Type | Description |
|------|------|-------------|
| `pal` | dict | OKLCH / hex colour tokens. Keys: `bg`, `bg-warm`, `bg-dark`, `bg-dark-2`, `bg-dark-3`, `fg`, `fg-dim`, `fg-faint`, `fg-dark`, `fg-dark-dim`, `fg-dark-faint`, `rule`, `rule-strong`, `rule-dark`, `rule-dark-strong`, `accent`, `accent-soft`, `accent-deep`, `bad`, `bad-bg`, `good`, `good-bg`, `c-key`, `c-type`, `c-str`, `c-num`, `c-com`, `c-fn`. |
| `type-scale` | dict | Size tokens. Keys: `jumbo`, `display`, `title`, `subtitle`, `body`, `small`, `code`, `code-sm`. |
| `scale` | float | Page-scale multiplier (= `0.5`). |
| `page-width` / `page-height` | length | `1920pt * scale` / `1080pt * scale`. |
| `pad-top` / `pad-bottom` / `pad-x` | length | Slide-chrome padding. |
| `gap-title` / `gap-item` | length | Vertical gaps. |
| `body-font` / `mono-font` | array | Font fallback chains. |

### Functions

| Signature | Renders |
|-----------|---------|
| `sz(t)` | `t * scale` — scale a slide-plan length to its on-page value. |
| `our-theme(self: none, body)` | Top-level show-transformer. Applied via `#show: our-theme` in `deck.typ` / `test-classes.typ`. Sets page geometry, body fill, body & raw font fallbacks. |
| `slide-page(fill: pal.bg, fg: pal.fg, body)` | Wraps `body` in a single `page(...)` element with the given fill/fg; used internally by every slide-class function. |

---

## `code-pane.typ`

| Signature | Renders |
|-----------|---------|
| `code-pane(filename: "Demo.java", language: "java", body, highlights: (), hover: none, diagnostic: none)` | Dark `pal.bg-dark-2` block. **Tab bar** (`pal.bg-dark`): accent dot + mono filename. **Code area**: `themes/dark.tmTheme` syntax highlighting via `show raw.line:`; space-padded line-number gutter (colour `#494c58`). Per-line background tints per `highlights`. **Hover-pop**: `pal.bg-dark-3` tooltip `place`d above the specified line. **Diagnostic strip**: `pal.bg-dark-3` band with bad/good/note colouring. |

`body` — content containing a `raw(lang: …, block: true, "…")` element. Plain-text content is accepted but produces no gutter or tints (backward-compat only).

`highlights` — array of `(line-number, kind)` where `kind ∈ "err" | "hl" | "hl-good"`.
`hover` — `(line, col, text)` or `none`. Tooltip placed above the given line.
`diagnostic` — `(kind, label, body)` where `kind ∈ "bad" | "good" | "note"`, or `none`.

**Syntax theme** — `touying/themes/dark.tmTheme` (TextMate theme). Idris: use `language: "haskell"` as fallback; replace if `idris.sublime-syntax` is added.

**Known Typst 0.14 scoping constraint** — closure-local variables are inaccessible inside nested `[content blocks]` in show rule closures. Use content concatenation (`+`) or pre-build content values in code mode.

---

## `components.typ` — slide-class functions

Every function applies the correct background fill, padding, and column grid
from `style_other_presentation.css`. The signatures are final; Phase 4 may
refine the *bodies* (typography, slot styling) but not the shape.

| Signature | Renders |
|-----------|---------|
| `title-slide(eyebrow: none, h1, lede, meta-left, meta-right)` | `.s-title`. Dark bg. Top: optional eyebrow. Middle: jumbo h1 (168pt, 300-weight) + lede (44pt). Bottom: meta-left / meta-right in mono 26pt. |
| `incident-slide(role, name, verdict, heading, story, bug-line)` | `.s-incident`. Light bg. Two-column grid (260pt + 1fr, 88pt gutter). Left: role (mono 26pt accent), name (112pt 300-weight), verdict (30pt dim). Right: heading (38pt 500-weight), story (30pt dim), bug-line (mono 28pt callout with bad left-bar). |
| `theory-slide(eyebrow: none, h2, body, footer: none)` | `.s-theory`. Light bg. Top: optional eyebrow. h2 (60pt 400-weight). Body slot. Optional bottom footer (mono 26pt). |
| `stage-opener-slide(stage-num, h2, lang, one-liner)` | `.s-stage-opener`. Dark bg. Two-column grid (280pt + 1fr). Left: stage-num as 360pt mono accent. Right: h2 (84pt 300-weight) + lang (mono 30pt dim) + one-liner (34pt) with a top rule. |
| `light-slide(eyebrow: none, h2, body)` | `.s-light`. Light bg. Optional eyebrow → h2 (68pt 400-weight) → body slot. |
| `bignum-slide(big, label)` | `.s-bignum`. Dark bg. 360pt mono accent number, 44pt label below. |
| `close-slide(big-stmt)` | `.s-close`. Light bg. 92pt 300-weight statement centred vertically. |
| `qa-slide()` | `.s-qa`. Dark bg. 280pt accent "Q&A" + 36pt blurb below, centred. |

## `components.typ` — primitives & reusable patterns

| Signature | Renders |
|-----------|---------|
| `eyebrow(body, style: "normal")` | Mono uppercase label, 26pt, 500-weight. `style ∈ "normal" \| "accent" \| "bad" \| "dark"`. |
| `callout(label, body, style: "accent")` | Left-bar callout. Mono uppercase label (22pt, 0.06em tracking), body 28pt. `style ∈ "accent" \| "bad"`. |
| `signature-card(body)` | White card with mono body (30pt), border + light shadow. Used for IDE method signatures. |
| `beat-grid(entries)` | Two-column grid (120pt mono accent `when` + body `what` with optional `sub`). `entries: array of (when, what, sub)`. |

### Phase 3 pattern stubs (signatures final; bodies placeholder)

| Signature | Phase-3 behaviour |
|-----------|-------------------|
| `ladder(documented, tested, encoded, encoded-active: false)` | DOCUMENTED / TESTED / ENCODED 3-column grid; encoded rung highlighted in accent when `encoded-active`. |
| `story-strip(chips)` | Four-column chip strip. `chips: array of (name, what, state, closed: bool)` — closed chips flip border to accent and state to "CLOSED ✓". |
| `test-list(items)` | 9-row test grid. `items: array of (idx, desc, closes, state)` where `state ∈ "active" \| "just-gone" \| "gone"`. |
| `lcube(svg-or-cetz, axes)` | Pairs the lambda-cube cetz canvas with an axis legend on the right. `axes: array of (tag, label, sub)`. |

---

## `diagrams/*.typ`

Each diagram exposes a single canvas binding consumable by any slide-class
function (typically `theory-slide(..., body: <canvas-name>)`). All three
compile standalone via the trailing-`#<name>-canvas` guard, so they can be
inspected one-at-a-time with `typst compile diagrams/<name>.typ`.

| File | Exported binding | Content |
|------|------------------|---------|
| `diagrams/gentzen-or.typ` | `gentzen-or-canvas` | OR-introduction rules `∨I₁`, `∨I₂` + elimination `∨E` with discharged-assumption gloss. Code side: sealed `Either` + exhaustive `match` (case arms left-aligned under `match`). Closing line: "The rest follows." |
| `diagrams/lambda-cube.typ` | `lambda-cube-canvas` | 3D cube with 8 labelled vertices (STLC, System F, F$\omega$⁻, System F$\omega$, LF, F+dep., F$\omega$+dep., CIC), three labelled axes (terms-on-types, types-on-types, types-on-terms), stage tags on the talk's path (Stage 1 → Stage 2 → Stages 5–6 → Stage 7), red highlight path. |
| `diagrams/mltt.typ` | `mltt-canvas` | Two-column Π / Σ rules. Π: Formation, Introduction (λ), Elimination (application), β-reduction. Σ: Introduction (pair), Elimination (fst, snd). Brief gloss per column. Bottom line: "`protocolFromSnapshot` is Π-elimination; `assessOrder` is Σ-introduction." |

A trailing `#<name>-canvas` line at the bottom of each file is the
standalone-compile guard. `#import` only binds names, so the trailing canvas
expression does **not** render in importing documents.

---

## Build entrypoints

| File | Purpose |
|------|---------|
| `theme.typ` | Theme (palette, type-scale, page setup, fonts). Re-exports nothing — import explicitly. |
| `components.typ` | All slide-class functions and reusable primitives. |
| `code-pane.typ` | The `code-pane` component (Phase 2 — full implementation). |
| `themes/dark.tmTheme` | TextMate syntax-highlighting theme for dark code panes. |
| `test-code-pane.typ` | Phase 2 validation slide (3 panes: Scala+err+hover, Java+diag, Haskell/Idris). |
| `diagrams/{gentzen-or,lambda-cube,mltt}.typ` | The three cetz canvases. |
| `slides/NN-*.typ` | 43 per-slide stub files (35 main + 8 appendix). Each is a `#pagebreak()` so the deck shows one blank page per stub. |
| `deck.typ` | Main entrypoint. Imports theme/components/code-pane, applies `our-theme`, includes all 43 slide files in order. Build with `typst compile deck.typ deck.pdf`. |
| `test-classes.typ` | Phase-1 validation deck — one example slide per slide class. Build with `typst compile test-classes.typ test-classes.pdf`. |

---

## Conventions

- **Sizes**: pass raw slide-plan values (e.g. `32pt`) and call `sz(...)` at the
  use-site. Never bake `* 0.5` into a function body.
- **Colours**: always read from `pal`; do not introduce hard-coded RGB values
  in slide files.
- **Fonts**: use `body-font` and `mono-font` directly, never literal font
  names. The fallback chain absorbs missing IBM Plex / JetBrains Mono.
- **Per-slide page-fill** is handled by each slide-class function via
  `slide-page(fill: ...)`. Slide files should not call `set page(...)`.
