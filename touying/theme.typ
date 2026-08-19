// ============================================================================
// = theme.typ — palette, type-scale, page setup for the Type-Driven
// Programming talk (Java Meetup Cologne, 28 May 2026). The deck targets a
// 1920×1080 logical stage. To keep the rendered PDF a reasonable file size
// while preserving SVG fidelity, every size unit defined in the slide plan
// (e.g. "32px") is stored in this file at its raw value and scaled by `scale`
// (= 0.5) at the point of use. The on-page geometry is therefore 960×540pt;
// sizes the audience perceives are 1× of the slide-plan numbers because the
// projector itself drives the final magnification. Font availability note: IBM
// Plex Sans  — install with `sudo apt install fonts-ibm-plex` on Debian 11+ /
// Ubuntu 22.04+. Falls back to Inter, then to Typst's bundled Libertinus Sans.
// JetBrains Mono — not packaged in Debian 11 main. On bookworm and Ubuntu
// 22.04+ use `sudo apt install fonts-jetbrains-mono`. Else unzip the GitHub
// release into ~/.local/share/fonts/ and run `fc-cache -f`. Falls back to Fira
// Code, then to Typst's bundled DejaVu Sans Mono. The build succeeds without
// the preferred fonts; only typography fidelity suffers. =====================
// ========================================================

#import "@preview/touying:0.7.4": *

// ─── Palette (OKLCH where the slide plan uses OKLCH) ────────────────────────

#let pal = (
  bg:                rgb("#f4f1ea"),
  bg-warm:           rgb("#ebe6d8"),
  bg-dark:           rgb("#11131a"),
  bg-dark-2:         rgb("#1a1d26"),
  bg-dark-3:         rgb("#232634"),
  fg:                rgb("#14161d"),
  fg-dim:            rgb("#5a5d68"),
  fg-faint:          rgb("#8a8c93"),
  fg-dark:           rgb("#e8e2d2"),
  fg-dark-dim:       rgb("#9b988a"),
  fg-dark-faint:     rgb("#5a5b54"),
  rule:              rgb(0, 0, 0, 26),         // ≈ 10% alpha black
  rule-strong:       rgb(0, 0, 0, 56),         // ≈ 22% alpha black
  rule-dark:         rgb(255, 255, 255, 26),
  rule-dark-strong:  rgb(255, 255, 255, 51),
  accent:            oklch(62%, 0.14, 55deg),
  accent-soft:       oklch(78%, 0.08, 60deg),
  accent-deep:       oklch(48%, 0.12, 50deg),
  bad:               oklch(58%, 0.17, 28deg),
  bad-bg:            oklch(93%, 0.04, 28deg),
  good:              oklch(55%, 0.10, 145deg),
  good-bg:           oklch(93%, 0.03, 145deg),
  c-key:             oklch(78%, 0.10, 60deg),
  c-type:            oklch(80%, 0.10, 200deg),
  c-str:             oklch(78%, 0.10, 130deg),
  c-num:             oklch(78%, 0.10, 25deg),
  c-com:             oklch(58%, 0.02, 100deg),
  c-fn:              oklch(80%, 0.10, 80deg),
)

// ─── Type-scale (raw "slide-plan px" values; multiply by `scale` at use) ────

#let type-scale = (
  jumbo:    220pt,
  display:  124pt,
  title:    68pt,
  subtitle: 46pt,
  body:     32pt,
  small:    26pt,
  code:     28pt,
  code-sm:  24pt,
)

// ─── Page / layout constants ────────────────────────────────────────────────

#let scale       = 0.5
#let page-width  = 1920pt * scale
#let page-height = 1080pt * scale
#let pad-top     = 100pt * scale
#let pad-bottom  =  88pt * scale
#let pad-x       = 112pt * scale
#let gap-title   =  80pt * scale     // headline → body — generous breathing room
#let gap-item    =  28pt * scale

// ─── Font fallback chains ───────────────────────────────────────────────────

#let body-font = ("IBM Plex Sans", "Inter", "Libertinus Sans")
#let mono-font = ("JetBrains Mono", "Fira Code", "DejaVu Sans Mono")

// Convenience: convert a raw slide-plan size token (e.g. type-scale.body) into
// the scaled length used on the rendered page.
#let sz(t) = t * scale

// ─── Theme entry-point ──────────────────────────────────────────────────────
//
// `our-theme` is a top-level show-transformer applied to deck.typ /
// test-classes.typ. It sets the page geometry, applies the body fill, and
// configures the global text + raw fonts. Per-slide page-fill overrides
// (dark backgrounds, etc.) are handled by the individual slide-class
// functions in components.typ via the `slide-page` helper.

#let our-theme(self: none, body) = {
  set page(
    width:  page-width,
    height: page-height,
    margin: 0pt,
    fill:   pal.bg,
  )
  set text(
    font: body-font,
    size: sz(type-scale.body),
    fill: pal.fg,
  )
  show raw: set text(font: mono-font)
  body
}

// ─── Per-slide page wrapper ─────────────────────────────────────────────────
//
// Each slide-class function in components.typ calls `slide-page` to produce a
// single self-contained page with the right fill colour. This avoids the
// "next slide inherits the previous slide's set page" footgun and lets a deck
// be assembled as a simple concatenation of slide-class invocations.
//
// pdfpc slide-boundary markers (NewSlide / Idx / LogicalSlide) are injected
// at the top of every page so that `typst query "<pdfpc-file>"` can build a
// correct .pdfpc sidecar understood by pympress.

#let _slide-counter = counter("__pdfpc_slide__")

#let slide-page(fill: pal.bg, fg: pal.fg, body) = page(
  width:  page-width,
  height: page-height,
  margin: 0pt,
  fill:   fill,
)[
  #_slide-counter.step()
  #context {
    let n = _slide-counter.get().first()
    [#metadata((t: "NewSlide"))<pdfpc>]
    [#metadata((t: "Idx", v: n - 1))<pdfpc>]
    [#metadata((t: "LogicalSlide", v: n))<pdfpc>]
  }
  #set text(fill: fg)
  #body
]
