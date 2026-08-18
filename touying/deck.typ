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


#show: our-theme

// ─── Main deck ──────────────────────────────────────────────────────────────
//
// Stage numbering (0–6, seven stages):
//   Stage 0  JS untyped baseline         S17
//   Stage 1  Java simple types            S18
//   Stage 2  Java generics                S19
//   Stage 3  Function types + sealed      S20  (merged: was Stage 3 + Stage 4)
//   Stage 4  Phantom typestate            S23
//   Stage 5  Scala 3 refinement/session   S26
//   Stage 6  Idris 2 / MLTT / QTT        S31+
//
// New slides added (§1.1, §1.3, §1.4, §2.5):
//   curry-howard.typ     — between convergence2 and mltt
//   scala3-ceiling.typ   — between stage5-payoff and stage6-bridge
//   stage5-mechanisms.typ— between session-types and stage5-payoff
//   where-to-start.typ   — between horizon and close

#include "slides/01-title.typ"
#include "slides/02-alice.typ"
#include "slides/06-pattern.typ"
#include "slides/07-toolkit.typ"
#include "slides/a1-connectives.typ"
#include "slides/a1-quantifiers.typ"
#include "slides/08-crisis.typ"
#include "slides/curry-howard.typ"
#include "slides/a1-above.typ"
#include "slides/15-test-spine.typ"
#include "slides/a2-promises.typ"         // Act 2 — what a checker actually promises
#include "slides/17-stage1.typ"
#include "slides/18-stage2.typ"
#include "slides/19-stage3.typ"
#include "slides/20-stage3-payoff.typ"
#include "slides/21-bridge.typ"
#include "slides/22-stage4.typ"
#include "slides/23-stage4-payoff.typ"
#include "slides/24-java-ceiling.typ"
#include "slides/25-stage5.typ"
#include "slides/26-session-types.typ"
#include "slides/stage5-mechanisms.typ"    // §2.5 — mechanisms reference slide
#include "slides/27-stage5-payoff.typ"
#include "slides/scala3-ceiling.typ"       // §1.3 — Scala 3 ceiling slide
#include "slides/28-stage6-bridge.typ"
#include "slides/29-mltt-running.typ"
#include "slides/30-stage6-payoff.typ"
#include "slides/31-the-climb.typ"
#include "slides/32-agentic.typ"
#include "slides/33-horizon.typ"
#include "slides/where-to-start.typ"       // §1.4 — Where to start tomorrow
#include "slides/34-close.typ"

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
#include "slides/a10-invariants.typ"   // the nine-row inventory, out of the main deck

// ─── pdfpc sidecar generation ────────────────────────────────────────────────
//
// Collects all <pdfpc> metadata (NewSlide boundaries + Note elements) and
// packages them into a single <pdfpc-file> metadata node.  Extract with:
//
//   typst query touying/deck.typ "<pdfpc-file>" --field value --one \
//     > talk.pdfpc
//
// pympress reads talk.pdfpc automatically when it opens talk.pdf (same dir,
// same stem).  The Makefile `talk.pdfpc` target runs this command.

#context pdfpc.pdfpc-file(here())
