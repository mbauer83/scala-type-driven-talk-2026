// =============================================================================
// deck.typ — main entrypoint that imports theme/components/code-pane and the
// full 35-main + 8-appendix slide sequence.
//
// Phase 1: most slides are blank stubs. They compile to a blank page each, so
// stepping through deck.pdf shows the talk's spine.
//
// Build:
//   typst compile deck.typ deck.pdf
// Watch:
//   typst watch deck.typ deck.pdf
// =============================================================================

#import "theme.typ": *
#import "components.typ": *
#import "code-pane.typ": code-pane

// TODO Phase 6 — speaker-note export. Plan in TOUYING_CONVERSION_PLAN.md
// §"Speaker notes on the laptop, slides on the projector".
// #import "@preview/touying-exporter:0.1.0": *

#show: our-theme

// ─── Main deck (S1 — S35) ───────────────────────────────────────────────────

#include "slides/01-title.typ"
#include "slides/02-alice.typ"
#include "slides/03-bob.typ"
#include "slides/04-charlie.typ"
#include "slides/05-danielle.typ"
#include "slides/06-pattern.typ"
#include "slides/07-toolkit.typ"
#include "slides/08-crisis.typ"
#include "slides/09-convergence1.typ"
#include "slides/10-gentzen-or.typ"
#include "slides/11-convergence2.typ"
#include "slides/12-mltt.typ"
#include "slides/13-convergence3.typ"
#include "slides/14-lambda-cube.typ"
#include "slides/15-test-spine.typ"
#include "slides/16-stage0.typ"
#include "slides/17-stage1.typ"
#include "slides/18-stage2.typ"
#include "slides/19-stage3.typ"
#include "slides/20-stage4.typ"
#include "slides/21-stage4-payoff.typ"
#include "slides/22-bridge.typ"
#include "slides/23-stage5.typ"
#include "slides/24-stage5-payoff.typ"
#include "slides/25-java-ceiling.typ"
#include "slides/26-stage6.typ"
#include "slides/27-session-types.typ"
#include "slides/28-stage6-payoff.typ"
#include "slides/29-stage7-bridge.typ"
#include "slides/30-mltt-running.typ"
#include "slides/31-stage7-payoff.typ"
#include "slides/32-the-climb.typ"
#include "slides/33-agentic.typ"
#include "slides/34-horizon.typ"
#include "slides/35-close.typ"

// ─── Appendix (A1 — A8) ─────────────────────────────────────────────────────
//
// 36-qa.typ is the Q&A title card — first page of the appendix section.
//
// Marked with a pagebreak + a section header in Phase 1; Phase 6 wires this
// to Touying's appendix marker so the appendix is exportable as a separate
// PDF for Q&A use.
//
// // TODO Phase 6 — use touying's appendix mechanism so appendix slides can
// // be excluded from the main exported PDF.

#pagebreak()

#include "slides/36-qa.typ"
#include "slides/a01-tracking.typ"
#include "slides/a02-tracking.typ"
#include "slides/a03-tracking.typ"
// Extended history (A4–A6) removed — did not add value over the main theory section.
#include "slides/a07-tracking.typ"
#include "slides/a08-singleton.typ"
#include "slides/a09-singletons.typ"
