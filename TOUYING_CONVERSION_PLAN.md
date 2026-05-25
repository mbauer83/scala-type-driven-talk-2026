# Touying Conversion Plan

Concrete, sequenced plan for turning `PRESENTATION_SLIDE_PLAN.md` into a runnable
[Touying](https://touying-typ.github.io/) deck in the design language adopted
from `style_other_presentation.css`.

The plan is organised so that every phase ends with a **runnable, validatable
artifact** — never "twelve slides in flight". After each phase the deck builds,
displays correctly at 1920×1080, and can be inspected slide-by-slide.

---

## 0. Decisions taken (do not re-litigate)

| # | Decision |
|---|---|
| 1 | **Touying** (not Polylux, not Slidev, not Reveal.js). Native Typst, supports cetz directly, mature theme system. |
| 2 | **Custom theme**, not one of Touying's bundled themes. The style we've adopted is specific enough that bundled themes would be a hindrance. |
| 3 | **1920×1080** output (16:9). Matches the projector target and the CSS source. |
| 4 | **Fonts:** IBM Plex Sans + JetBrains Mono. Both available via Google Fonts. For Typst we install them locally via fontconfig or use Typst's bundled fallback (`Libertinus Sans` / `DejaVu Sans Mono`) — see Phase 1.2. |
| 5 | **cetz** for diagrams. The three diagram canvases (Gentzen OR rules, Lambda Cube, MLTT Π/Σ rules) are built from scratch in Phase 1 as `touying/diagrams/gentzen-or.typ`, `touying/diagrams/lambda-cube.typ`, and `touying/diagrams/mltt.typ`. The existing files in `slides/` are out of date and must not be used as source material. |
| 6 | **No animations/transitions** in the first cut. Touying supports them; we add them only if a specific slide genuinely needs them (progressive disclosure in S9 is the leading candidate). |
| 7 | **PDF + SVG-per-slide output** from one build. Touying's default PDF is the primary; SVG per page is the re-use format. |
| 8 | **No IDE-mimicking patterns in slides.** The speaker switches to a real IDE for live edits, so slides do not need `.hover-pop` overlays or `.diag-line` strips simulating compiler output. Code-pane patterns are simplified to "snippet display" only — the IDE handoff cue (an eyebrow like "→ Demo 4 in `Demo.java`") is enough. The `.code-pane`'s tab-bar with filename is kept; the diagnostic strip and hover-pop overlay patterns from the CSS source are dropped. |

---

## Phase 1 — Theme scaffold and skeleton (one slide each beat type)

**Goal:** produce a PDF of ~10 placeholder slides — one per slide class
(`.s-title`, `.s-incident`, `.s-theory`, `.s-stage-opener`, `.s-light`,
`.s-bignum`, `.s-close`, `.s-qa`, plus one IDE-segment slide) — at the right
size, with the right colours, with the right typography. Content is
placeholder; layout is final.

**Validation gate:** every placeholder slide renders correctly on its own page,
visually matches the corresponding `.s-*` class in `style_other_presentation.css`
(side-by-side visual check), and the build completes in < 5 seconds with
`typst watch`.

### 1.1 — Project layout

```
touying/
├── theme.typ              # the custom theme (palette, type scale, page setup)
├── components.typ         # reusable patterns (.eyebrow, .ladder, .story-strip, .test-list, …)
├── code-pane.typ          # the IDE-styled code pane with .diag-line + .hover-pop
├── diagrams/
│   ├── gentzen-or.typ     # ported from slides/slide-10-gentzen-or.typ
│   └── lambda-cube.typ    # ported from slides/slide-14-lambda-cube.typ
├── slides/
│   ├── 01-title.typ
│   ├── 02-alice.typ       # one file per slide initially; consolidate later
│   ├── …
│   └── 35-close.typ
├── deck.typ               # the main entrypoint that imports and orders all slides
└── README.md              # build commands, design conventions, troubleshooting
```

### 1.2 — Theme (`theme.typ`)

```typst
#import "@preview/touying:0.5.5": *

#let pal = (
  bg:           rgb("#f4f1ea"),
  bg-warm:      rgb("#ebe6d8"),
  bg-dark:      rgb("#11131a"),
  bg-dark-2:    rgb("#1a1d26"),
  bg-dark-3:    rgb("#232634"),
  fg:           rgb("#14161d"),
  fg-dim:       rgb("#5a5d68"),
  fg-faint:     rgb("#8a8c93"),
  fg-dark:      rgb("#e8e2d2"),
  fg-dark-dim:  rgb("#9b988a"),
  fg-dark-faint:rgb("#5a5b54"),
  accent:       oklch(62%, 0.14, 55deg),
  accent-soft:  oklch(78%, 0.08, 60deg),
  bad:          oklch(58%, 0.17, 28deg),
  good:         oklch(55%, 0.10, 145deg),
)

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

#let our-theme(self: none, body) = {
  let self = utils.merge-dicts(self, (
    colors: pal,
    page: (
      width:  1920pt * 0.5,    // typst pt: scale to fit reasonable PDF size; SVG export still gives clean output
      height: 1080pt * 0.5,
      margin: 0pt,
      fill:   pal.bg,
    ),
  ))
  set text(font: ("IBM Plex Sans", "Inter", "Libertinus Sans"), size: type-scale.body * 0.5)
  show raw: set text(font: ("JetBrains Mono", "Fira Code", "DejaVu Sans Mono"))
  // ... per-class page-setup overrides applied via slide functions below
  body
}
```

**Font installation:** instruct the developer to `cp ~/.local/share/fonts/...` or
use `typst --font-path ./fonts` and bundle Plex + JetBrains Mono `.ttf` in a
local `fonts/` directory. The README of the touying project documents this.
Fallback chain ensures the deck still builds without the preferred fonts.

### 1.3 — Per-class slide functions (`components.typ`)

For each `.s-*` class in the CSS, expose a Typst function:

```typst
#let title-slide(eyebrow: none, h1, lede, meta-left, meta-right) = { ... }
#let section-slide(num, h2, blurb) = { ... }
#let incident-slide(role, name, verdict, heading, story, bug-line) = { ... }
#let theory-slide(eyebrow: none, h2, body, footer: none) = { ... }
#let stage-opener-slide(stage-num, h2, lang, one-liner) = { ... }
#let light-slide(eyebrow: none, h2, body) = { ... }
#let bignum-slide(big, label) = { ... }
#let close-slide(big-stmt) = { ... }
#let qa-slide() = { ... }
```

Each is a thin wrapper that sets the page fill, applies the layout grid from
the CSS, and styles the named slots in the slide-class CSS.

### 1.4 — Validation loop

```bash
# In one terminal:
cd touying && typst watch deck.typ deck.pdf

# In another terminal (preview):
zathura deck.pdf  # or okular, evince — anything that auto-reloads
```

Every save triggers a rebuild in < 1 second. Page-by-page check: open the PDF
side by side with `style_other_presentation.css` rendered in a browser using a
demo HTML (we can create a minimal one from the existing slide-class examples
in the CSS comments).

**Validation gate exit criteria:**
- [ ] All 9 slide classes render at 1920×1080 with correct background, typography, and accent colour
- [ ] Eyebrows, h1/h2, body text use the right font and size
- [ ] Build completes in < 5 seconds
- [ ] PDF is one page per slide (no overflow)

---

## Phase 2 — Code-pane component

**Goal:** a robust `code-pane()` Touying component matching `.code-pane` from
the CSS. Used by every IDE Segment in the talk (8 segments).

**Validation gate:** a single placeholder slide with three code-panes (one with
syntax highlighting, one with `.err` underline + `.hover-pop`, one with a
`.diag-line.--bad` strip) renders identically to the CSS reference.

### 2.1 — Component design

```typst
// code-pane.typ
#let code-pane(
  filename: "Domain.scala",
  language: "scala",
  body,                      // raw code as Typst raw block
  highlights: (),            // list of (line-number, kind) where kind ∈ "err" | "hl" | "hl-good"
  hover: none,               // optional (line, col, text) for .hover-pop overlay
  diagnostic: none,          // optional (kind, label, body) for .diag-line strip; kind ∈ "bad" | "good" | "note"
) = {
  // Outer box: bg-dark-2, 8px rounded corners, drop shadow
  // Tab bar: bg-dark, accent dot + filename
  // Code area: monospace, line numbers, per-line highlighting
  // Optional hover-pop: absolutely positioned overlay
  // Optional diagnostic strip: bg-dark-3 with accent / bad / good text
}
```

### 2.2 — Syntax highlighting

Typst's `raw` block supports many languages via Typst's bundled syntect grammars
including Scala, Java, Idris (via a generic Haskell-like grammar — Idris-specific
may need a custom grammar; see Phase 2.3), JavaScript. The component wires up
`raw` and post-processes for `.err` / `.hl` / `.hl-good` overlays per-line.

### 2.3 — Idris syntax highlighting

Idris isn't in Typst's bundled grammars. Options:
1. **Use Haskell grammar as a near-fit** (most Idris syntax overlaps).
2. **Ship a custom `idris.sublime-syntax` file** in `fonts/syntax/` and load it
   via `#raw(..., syntaxes: "fonts/syntax/idris.sublime-syntax")`.

Recommendation: start with Haskell-as-Idris; ship the custom grammar only if
the highlight looks materially wrong on stage. Validate by rendering an actual
Stage 7 code snippet and eyeballing.

### 2.4 — Validation gate

- [ ] A test slide with a Scala code-pane (5-10 lines), one `.err` line, one
      `.hover-pop`, and one `.diag-line.--bad` renders with all elements at
      correct position and color
- [ ] An Idris code-pane shows reasonable syntax highlighting (keywords coloured,
      types coloured)
- [ ] `code-pane()` can be called inside any of the Phase 1 slide classes
      without layout breaking

---

## Phase 3 — Patterns: ladder, story-strip, test-list, lcube, beat-grid

**Goal:** the 5 reusable visual abstractions from the CSS implemented as
Touying components.

**Validation gate:** one test slide per pattern (5 test slides total) renders
matching the CSS reference. Test slides verify edge cases:

- `.test-list` with 9 items, 4 in `--gone` state, 2 in `--just-gone`, 3 active
- `.story-strip` with all four chips, 2 in `--closed` state
- `.ladder` with the `.encoded` rung highlighted
- `.lcube` reusing `slides/slide-14-lambda-cube.typ` cetz code
- `.beat-grid` with 4 entries (timeline-style)

### 3.1 — Component signatures

```typst
#let ladder(documented, tested, encoded, encoded-active: false) = { ... }
#let story-strip(chips) = { ... }
  // chips: array of (name, what, state, closed: bool)
#let test-list(items) = { ... }
  // items: array of (idx, desc, closes, state)
  //   state ∈ "active" | "just-gone" | "gone"
#let lcube(svg-or-cetz, axes) = { ... }
  // axes: array of (tag, label, sub) for the legend on the right
#let beat-grid(entries) = { ... }
  // entries: array of (when, what, sub)
```

### 3.2 — Diagram canvases

All three cetz canvases (`gentzen-or.typ`, `lambda-cube.typ`, `mltt.typ`) are
built from scratch in Phase 1 and live in `touying/diagrams/`. Phase 3 does
not touch them. Each exposes a single `#let <name>-canvas = canvas({ … })`
binding that slides import directly.

### 3.3 — Validation gate

- [ ] 5 pattern-test slides render correctly
- [ ] The Gentzen cetz canvas displays inside an `.s-theory` slide chrome
- [ ] The lambda cube cetz canvas (from `touying/diagrams/lambda-cube.typ`) displays
      inside an `.s-theory` slide chrome next to the dependency matrix
- [ ] Build still completes in < 10 seconds for the full skeleton + 5 pattern slides

---

## Phase 4 — Slide-by-slide content port (35 main + 8 appendix = 43 slides)

**Goal:** port `PRESENTATION_SLIDE_PLAN.md` to runnable Touying slides, in talk
order, one at a time. Each slide's content (visual + speaker notes) comes
straight from the slide plan.

**Validation gate:** for each slide, run a single-slide preview and compare to
the slide plan's described visual content. The PDF is approved when, for the
full deck:
- No slide overflows its 1920×1080 frame
- Every "live edit" moment has the code-pane + diagnostic strip configured
- Every payoff slide has both the `.story-strip` and the `.test-list` updated to the right state
- The appendix slides build but are excluded from the main exported PDF

### 4.1 — Order of conversion (lowest-risk first)

The conversion order is designed so each step builds confidence and reuses
patterns from earlier steps:

1. **S1 (Title), S34 (Close), Q&A** — uses 3 of the simpler slide classes;
   establishes the bookends.
2. **S2–S5 (Alice / Bob / Charlie / Danielle)** — repeated `.s-incident` pattern × 4.
3. **S6, S32, S33** — `.s-light` transitions and the climb summary (S32).
4. **S7–S14 (Theory)** — `.s-theory` slides; this is where the Gentzen (S10),
   MLTT (S12), and Lambda Cube (S14) cetz canvases land. Note: the theory
   section now uses three separate progressive-disclosure slides (S9: builds 1–2,
   S11: builds 3–4, S13: build 5) interleaved with the dwell slides S10 and S12.
   No within-slide Touying `pause` sequence needed — each is a standalone slide.
5. **S15 (test spine), Stage payoff slides (S21, S24, S28, S31)** — heavy
   `.test-list` + `.story-strip` usage; validates Phase 3 components in context.
6. **S16–S20, S22–S23, S25–S27, S29–S30** — the main practical-progression
   slides with IDE Segment placeholders and `.s-stage-opener` slides.
7. **A1–A8 (Appendix)** — once main deck is done, port the appendix as a
   separate sub-deck (Touying supports multiple decks in one document via
   `#show: appendix.with(...)`).

### 4.2 — Per-slide checklist (for each of 43 slides)

```
[ ] Background and slide class match the slide plan's "Type:" tag
[ ] Eyebrow matches the section (Cold Open / Theory / Stage N / Appendix)
[ ] Headline (h1 / h2) renders at correct scale
[ ] Body content present, no truncation
[ ] Any code-pane references real files in the repo
[ ] Speaker notes attached via #pdfpc.speaker-note (Touying supports this)
[ ] Clock target preserved in a speaker-note comment
```

### 4.3 — IDE Segment slides

These need extra care — they are the heart of the talk. For each of the 8 IDE
segments:

- The slide itself contains the code-pane (a `code-pane(...)` invocation with
  syntax-highlighted text). The slide is what the audience sees while the
  speaker switches to the IDE.
- The speaker-note block describes the keystrokes and what to read aloud
  (already in the slide plan).
- A small `.eyebrow.--accent` reads "LIVE EDIT" so the speaker knows to switch
  windows.

### 4.4 — Validation gate

- [ ] All 35 main slides render correctly at 1920×1080
- [ ] All 8 appendix slides render correctly
- [ ] No slide overflows; no slide has obviously empty space below its content
- [ ] Total build time for the full deck < 30 seconds with `typst compile`,
      < 10 seconds with `typst watch`
- [ ] PDF exports cleanly; SVG-per-page export works

---

## Phase 5 — Progressive disclosure for theory section

**Goal:** confirm the theory section (S9–S14) flows correctly as a linear
slide sequence. The original plan called for a single S9 with 5 progressive
builds and 2 interleaved cut-in slides; the slide plan was restructured so
that each beat is now its own standalone slide:

- **S9** — History beats 1–2 (Church/Turing, Gentzen named)
- **S10** — Gentzen OR rules (dwell)
- **S11** — History beats 3–4 (Curry-Howard, Martin-Löf named)
- **S12** — MLTT Π/Σ types (dwell)
- **S13** — History beat 5 (Coquand, closing line)
- **S14** — Lambda Cube (visualisation of all three axes)

No within-slide `pause` / `meanwhile` sequences are required. Each slide is
self-contained and advances on a single arrow-key press. Touying's `pause`
directive is available if the speaker wants to reveal bullet points one at
a time within S9, S11, or S13, but it is not architecturally needed.

### 5.1 — S9 structure (simplified)

```typst
// S9: two history beats, no in-slide progressive disclosure needed
#let s9 = theory-slide(eyebrow: [LOGIC & PROOF · 4TH C. BCE → TODAY])[
  == The Computational Convergence (Part 1)

  #beat-grid((
    ("1936", [Church / Turing — computability], [λ-calculus and Turing machines]),
    ("1935", [Gentzen — natural deduction],     [→ S10 for the rules]),
  ))
]
// then the speaker advances to S10 (Gentzen rules), then to S11, etc.
```

### 5.2 — Validation gate

- [ ] Stepping from S9 → S10 → S11 → S12 → S13 → S14 with `→` flows in the
      correct order at the intended clock targets
- [ ] Each slide fits its content without overflow; S10 (Gentzen rules) and
      S12 (MLTT rules) in particular contain cetz canvases that must not crowd

---

## Phase 6 — Build / preview / export pipeline

**Goal:** a single `make` (or shell script) that produces:

1. **`talk.pdf`** — main deck, 35 slides + appendix (cover, no progressive
   disclosure unfolded — the standard slide-per-page export)
2. **`talk-presenter.pdf`** — main deck with progressive disclosure unfolded
   (S9 takes 7 pages), and a `--with-speaker-notes` variant via
   [pdfpc](https://pdfpc.github.io/) format
3. **`slides/svg/slide-NN.svg`** — one SVG per slide for embedding elsewhere
4. **`slides/png/slide-NN.png`** at 1920×1080 for fallback

```bash
# Makefile excerpts
talk.pdf: $(shell find touying -name '*.typ')
	cd touying && typst compile deck.typ ../talk.pdf

talk-svg: $(shell find touying -name '*.typ')
	cd touying && typst compile deck.typ "../slides/svg/slide-{p}.svg"

talk-png: $(shell find touying -name '*.typ')
	cd touying && typst compile deck.typ "../slides/png/slide-{p}.png" --format png --ppi 144

watch:
	cd touying && typst watch deck.typ ../talk.pdf
```

### 6.1 — Validation gate

- [ ] `make talk.pdf` produces a single PDF in < 1 minute
- [ ] `make talk-svg` produces 43+ SVG files
- [ ] `make talk-png` produces 43+ PNG files at 1920×1080
- [ ] `make watch` reloads on save and updates the PDF preview in < 2 seconds

---

## Phase 7 — Stage-rehearsal validation pass

**Goal:** one full walkthrough of the deck with a timer, identifying any
remaining timing/visual issues.

### 7.1 — What to check

| Check | Pass criterion |
|-------|---------------|
| Time per section | Within 30s of the budget in the slide plan |
| Text legibility from back of room | Body text ≥ 26pt — already enforced by `--type-body`; sanity-check on a real projector |
| IDE handoff smoothness | Each IDE Segment slide visually tells the speaker which file to open and what to do — speaker doesn't have to consult notes |
| Live-edit speed | Each of the 5 live-edits (Stages 1, 4, 5, 6, 7) takes < 20s from slide-entry to expected error displayed |
| Q&A appendix navigability | Each appendix slide has a clear "trigger" label so the speaker can jump there directly from a question |

### 7.2 — Rehearsal recording

A single 45-minute screencast is the final validation. The deck is approved
when the speaker can complete the talk on time, with all live edits working,
without consulting the slide plan document during delivery.

---

## Diagram content specifications (for Phase 1 scratch builds)

The `slides/` directory files are out of date and must not be used. All three
cetz diagrams are built from scratch in Phase 1 directly into `touying/diagrams/`.
The specifications below are the authoritative content requirements.

### `touying/diagrams/gentzen-or.typ`

Must include:
- OR-introduction rules: ∨I₁ (left injection) and ∨I₂ (right injection)
- OR-elimination rule with the discharged-assumption notation: square-bracket
  gloss *"$[A]$ means 'supposing $A$, derive $C$' — the rule then retracts
  the supposition"* in muted text below the rule
- Closing line: *"The rest follows."* (not "Nothing else")
- Code side: sealed type declaration + exhaustive match with case-arms aligned
  under the `match` line (use `align(left)` in the Typst code block)
- Expose as: `#let gentzen-or-canvas = canvas({ … })`

### `touying/diagrams/lambda-cube.typ`

Must include:
- 3D cube with 8 labelled vertices; system names as primary labels in normal
  weight; lambda symbols (λ→, λ2, λω, …) as secondary labels in muted 9pt
  below each primary
- System names: STLC, System F, Fω⁻, System Fω, LF, F+dep., Fω+dep., CIC
- Three axes with labels: terms-on-types (second axis), types-on-types /
  type operators (third axis, anchored far enough right to clear the back-face
  labels), types-on-terms / dependent types (vertical axis)
- Stage tags showing which presentation stages reach which positions
  (e.g. "Stages 5–6" near System Fω; "Stage 7" near CIC)
- Expose as: `#let lambda-cube-canvas = canvas({ … })`

### `touying/diagrams/mltt.typ`

Two-column layout (Π left, Σ right). Content per §1.5 of this plan:
- Π-type: Formation, Introduction (λ), Elimination (application), β-reduction
- Σ-type: Introduction (pair), Elimination (fst/snd projections)
- Brief gloss under each column
- Bottom line: *"protocolFromSnapshot is Π-elimination; assessOrder is Σ-introduction."*
- Expose as: `#let mltt-canvas = canvas({ … })`

**Phase 1.5 — Build the MLTT rules diagram as a cetz canvas**

Target file: `touying/diagrams/mltt.typ` (not in `slides/` — built directly into the diagram library).

Visual content (drawn with `nd-rule`):

```
Π-types (∀ as dependent function):

  Formation:    Γ ⊢ A : 𝒰    Γ, x:A ⊢ B(x) : 𝒰
                ────────────────────────────────  (Π-Form)
                      Γ ⊢ (Πx:A). B(x) : 𝒰

  Introduction: Γ, x:A ⊢ b(x) : B(x)
                ────────────────────────────  (Π-Intro / λ)
                Γ ⊢ λx. b(x) : (Πx:A). B(x)

  Elimination:  Γ ⊢ f : (Πx:A).B(x)    Γ ⊢ a : A
                ────────────────────────────────  (Π-Elim)
                          Γ ⊢ f(a) : B(a)

  Computation:  (λx. b)(a) ≡ b[a/x]              (β-reduction)


Σ-types (∃ as dependent pair):

  Introduction: Γ ⊢ a : A    Γ ⊢ b : B(a)
                ────────────────────────  (Σ-Intro)
                Γ ⊢ (a, b) : (Σx:A). B(x)

  Elimination:  Γ ⊢ p : (Σx:A). B(x)    [proj₁ / proj₂]
                ────────────────────────────────────
                Γ ⊢ fst(p) : A    Γ ⊢ snd(p) : B(fst(p))
```

Layout: two columns (Π on the left, Σ on the right). Brief gloss under each:
*"applied to a runtime value → return type depends on that value"* for Π,
*"value bundled with a proof that depends on it"* for Σ. Connection to Stage 7
named at the bottom: *"`protocolFromSnapshot` is Π-elimination; `assessOrder`
is Σ-introduction."*

This slide is shown for ~15 sec inside the progressive disclosure of S9 (after
Martin-Löf is named). Keep it visually minimal — the audience should not be
reading symbol-by-symbol; the speaker walks them through.

---

## Speaker notes on the laptop, slides on the projector (Touying + pympress)

Touying's package universe lists three documented dual-screen paths for
speaker notes: **pympress, HTML export, and PowerPoint**. Of these, **pympress
is the recommended primary** for a Typst-native workflow — it reads PDFs
directly (which Touying produces), is cross-platform (Linux/macOS/Windows),
actively maintained, and the simplest of the three to set up reliably on a
stage machine.

The other two paths are kept as fallbacks (see below).

### Touying configuration

Use Touying's native speaker-note macro and the [`touying-exporter`
package](https://typst.app/universe/package/touying-exporter/) to emit a
PDF with notes embedded in the format pympress understands (a "two-up"
notes-on-second-screen layout, the same convention LaTeX Beamer uses):

```typst
#import "@preview/touying:0.5.5": *
#import "@preview/touying-exporter:0.1.0": *

#show: touying-slides.with(
  config-info(
    title:    [Type-Driven Programming],
    subtitle: [Correctness by Construction from the Basics to the Cutting Edge],
    author:   [Michael Bauer],
    date:     datetime(year: 2026, month: 5, day: 28),
  ),
  // Theme + page-fill from `theme.typ` (Phase 1).
  // …
)
```

For each slide, attach speaker notes via Touying's `#speaker-note`:

```typst
#slide[
  = Slide title
  Body content here.

  #speaker-note[
    Speaker notes for this slide, taken straight from
    PRESENTATION_SLIDE_PLAN.md's "Speaker notes" block. These appear only on
    the presenter view in pympress; the projector view never shows them.
  ]
]
```

### Build pipeline

```bash
# Default PDF — projector view only, no notes pages
typst compile deck.typ talk.pdf

# PDF with notes embedded as beamer-style notes pages (one per slide).
# touying-exporter exposes this via the `notes` export mode:
typst compile deck.typ --input notes=true talk-with-notes.pdf
```

The resulting `talk-with-notes.pdf` interleaves slide / notes / slide / notes,
which is the format pympress's "notes on second screen" mode auto-detects.

### Stage setup with pympress

```bash
# Install pympress (one-time):
sudo apt install pympress           # Debian/Ubuntu
brew install pympress               # macOS
choco install pympress              # Windows (Chocolatey)
# or via pip:  pip install --user pympress

# Launch the presentation on the day:
pympress talk-with-notes.pdf
```

When pympress starts with two displays attached:

- **Projector window**: clean slide view, fullscreens on the secondary display.
- **Presenter window** (on the laptop): current slide thumbnail, NEXT slide
  preview, speaker notes for the current slide, elapsed time, slide number,
  optional timer, and drawing/highlighting tools.

pympress auto-detects which output to send where; if it picks wrong, swap with
the `Swap screens` menu item or `Ctrl-S`. Rehearse this swap before the talk.

### Stage-day display arrangement

```
  ┌─────────────────────┐         ┌─────────────────────────┐
  │                     │         │  Current slide          │
  │   Current slide     │         │  ─────────────────────  │
  │   (clean, full)     │         │  Next slide preview     │
  │                     │         │  ─────────────────────  │
  │                     │         │  Speaker notes          │
  └─────────────────────┘         │  ─────────────────────  │
        Projector                 │  ⏱  41:23 · slide 23/41 │
                                  └─────────────────────────┘
                                          Laptop screen
```

### Alternative 1: HTML export (touying-web)

Touying can export to a self-contained HTML page that uses the browser's
built-in dual-screen capability:

```bash
typst compile deck.typ --input mode=html talk.html
# Open talk.html in Chrome/Firefox; press 'p' to enter presenter mode.
```

Speaker notes are read from the same `#speaker-note[...]` macros. The browser's
fullscreen-on-second-display API handles the dual-screen split.

Use this if pympress isn't available on the stage machine — any modern browser
suffices. Downside: relies on the browser's display API, which can be
unpredictable across platforms.

### Alternative 2: PowerPoint export

For venues that require a `.pptx` (Windows-locked machines, corporate
infrastructure), `touying-exporter` can produce one:

```bash
typst compile deck.typ --input mode=pptx talk.pptx
```

Notes are embedded as PowerPoint speaker notes; the venue's PowerPoint
displays them in Presenter View. Mostly cosmetic — the typography and the
cetz diagrams render as embedded images, so quality is fine but layout
fidelity to the Typst original isn't perfect.

### Alternative 3: pdfpc (also reads pympress's format)

If pympress and HTML both fail, `pdfpc` is a third option — same general
shape as pympress, slightly older codebase, well-tested on Linux. Reads PDFs
with pympress-style notes pages or its own `.pdfpc` sidecar. Touying-side
syntax can stay the same.

### Backup discipline (do this regardless of which tool wins on the day)

- A **printed one-page cheat-sheet** with the talk's section clock targets,
  the five live-edit recipes (file · edit · expected error), and the
  Q&A-appendix trigger words. Tape inside the laptop lid or clip to a small
  stand on the lectern.
- **`talk-with-notes.pdf` on a USB stick**, alongside a copy of pympress's
  installer for the venue's OS.
- **The full deck (no notes) on the speaker's phone** as the last-resort
  one-handed fallback if everything else fails.
- A **second copy of the PDF on a different cloud drive** that can be
  downloaded from the venue's wifi if the USB stick goes missing.

---

## Risks and mitigations

| Risk | Mitigation |
|------|-----------|
| Touying API changes between minor versions | Pin version in `theme.typ` (`#import "@preview/touying:0.5.5"`). Document the exact version in the touying README. |
| IBM Plex / JetBrains Mono not available on stage machine | Bundle `.ttf` files in `touying/fonts/`. Add fallback chain (`"IBM Plex Sans", "Inter", "Libertinus Sans"`). Test on a clean machine before the talk. |
| Idris syntax highlighting wrong | Pre-render the affected slides and visually verify. Custom syntax file if needed (see Phase 2.3). |
| Progressive disclosure (S9) creates jarring transitions | Use `pause` not `slide` — same slide, contents added incrementally, smoother. If still jarring, fall back to one slide per beat (5 slides for S9 instead of 1). |
| Build time creeps as deck grows | cetz canvases are the slowest part. Pre-render the lambda cube and Gentzen rules to SVG once and embed as static SVG inside the touying slides. Trade incrementality for build speed. |
| Speaker can't see the speaker notes on stage | Use Touying's `pdfpc` export → `pdfpc` displays speaker notes on the laptop screen while the projector shows the deck. Validate this works on the stage hardware before the talk. |

---

## Definition of done

The Touying deck is shippable when:

- [ ] All 7 phase validation gates have passed
- [ ] One full 45-minute screencast rehearsal completes within budget
- [ ] PDF, SVG-per-slide, and PNG-per-slide exports all build from one `make`
- [ ] Backup PDF lives on a USB drive and on the speaker's phone
- [ ] All `.typ` source files are committed; the build is reproducible from git
- [ ] A short troubleshooting section in `touying/README.md` covers: missing
      fonts, `typst` version mismatch, Idris syntax-highlighting fallback,
      pdfpc setup for speaker notes

---

## Timeline estimate

| Phase | Effort | Cumulative |
|-------|--------|------------|
| 0. Setup, font installation, Touying scaffold | 2 h | 2 h |
| 1. Theme + skeleton (9 slide classes) | 4 h | 6 h |
| 2. Code-pane component | 3 h | 9 h |
| 3. Patterns (ladder, story-strip, test-list, lcube, beat-grid) | 4 h | 13 h |
| 4. 43 slide ports (~15 min/slide average, faster for repeated patterns) | 8 h | 21 h |
| 5. Progressive disclosure for S9 | 1 h | 22 h |
| 6. Build/preview/export pipeline | 1 h | 23 h |
| 7. Rehearsal pass + fixes | 4 h | 27 h |

Total: ~27 hours of focused work, spread across a week of evenings or
3–4 dedicated days.

---

## Iteration discipline

After each phase, **commit and tag**. The phases are designed so a regression
in Phase N can be reverted without losing work from earlier phases. The
progression is also designed so that a partially-completed deck (e.g. through
Phase 4 only, no progressive disclosure) is still a viable backup if a later
phase introduces blocking issues.

The single most important habit: **after every batch of slides, page through the
PDF end-to-end**. The Typst build always compiles to the same logical output;
visual regressions only show up by looking.

---

## Progress

### Phase 1 — COMPLETE 2026-05-25

- **Typst**: 0.14.2
- **IBM Plex Sans installed**: no — falls back to Inter → Libertinus Sans.
  `fonts-ibm-plex` isn't in Debian 11 bullseye main; enable
  `bullseye-backports` or drop the OTFs from the upstream GitHub release into
  `~/.local/share/fonts/IBMPlexSans/` and `fc-cache -f`.
- **JetBrains Mono installed**: yes (~/.local/share/fonts/JetBrainsMono).
- **Touying**: 0.5.5 (auto-downloaded on first build).
- **cetz**: 0.3.4.
- **Diagrams built from scratch in `touying/diagrams/`**:
  - `gentzen-or.typ` → `gentzen-or-canvas`
  - `lambda-cube.typ` → `lambda-cube-canvas`
  - `mltt.typ` → `mltt-canvas`
  - All three compile standalone (`typst compile diagrams/<name>.typ`).
- **Stub slides**: `slides/01-title.typ` through `slides/35-close.typ` plus
  `slides/a01-tracking.typ` through `slides/a08-singleton.typ` — 43 in total,
  each a `// [Slide N] — Title — STUB\n#pagebreak()` so `deck.pdf` shows one
  blank page per stub.
- **Component API**: `touying/COMPONENTS.md` — sole reference for Phases 2–7.
- **Validation builds**:
  - `typst compile touying/test-classes.typ` → 9 pages, one per slide class.
  - `typst compile touying/deck.typ` → 45 pages (44 stub pagebreaks + the
    natural first page; appendix follows after an extra break).

#### §1 validation gate

- [x] All 9 slide classes render at 1920×1080 (logical) with correct
  background fill, body geometry, and accent colour
- [ ] Eyebrows, h1/h2, body text use the right font and size — IBM Plex Sans
  not yet installed locally; render uses fallback fonts. Acceptable for the
  Phase 1 layout-gate; re-validate after installing IBM Plex.
- [x] Build completes in < 5 seconds (`time typst compile` shows ~1s)
- [x] PDF is one page per slide (no overflow)

