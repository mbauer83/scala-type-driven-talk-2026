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
//   stage5-mechanisms.typ— between session-types and stage5-payoff (A4-mechanisms)
// scala3-ceiling.typ MERGED into 27-stage5-payoff -> A4-ceiling (18 Aug)
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
#include "slides/17-stage1.typ"          // A3-stage12 — Stages 1+2 merged
#include "slides/19-stage3.typ"
#include "slides/10-gentzen-or.typ"      // A3-gentzen — sits sixty seconds before the error (P2)
#include "slides/a3-demo1.typ"           // A3-demo1 — live, dark setup card
#include "slides/a3-demo1-edit.typ"      // recorded terminal, frame 1
#include "slides/a3-demo1-out.typ"       // captured output / fallback
#include "slides/20-stage3-payoff.typ"
#include "slides/22-stage4.typ"
#include "slides/a3-demo2.typ"           // A3-demo2 — live, dark setup card
#include "slides/a3-demo2-edit.typ"      // recorded terminal, frame 1
#include "slides/a3-demo2-out.typ"       // captured output / fallback
#include "slides/24-java-ceiling.typ"
#include "slides/25-stage5.typ"          // A4-opens
#include "slides/a4-demo3.typ"             // A4-demo3 — live, dark setup card
#include "slides/a4-demo3-edit.typ"        // recorded terminal, frame 1
#include "slides/a4-demo3-out.typ"         // captured sbt output / fallback
#include "slides/26-session-types.typ"     // A4-sessions
#include "slides/stage5-mechanisms.typ"    // A4-mechanisms
#include "slides/27-stage5-payoff.typ"     // A4-ceiling — MERGE of v1 payoff + scala3-ceiling
#include "slides/28-stage6-bridge.typ"     // A5-mltt — MERGE of v1 bridge + 29-mltt-running
#include "slides/a5-demo4.typ"              // A5-demo4 — live, dark setup card
#include "slides/a5-demo4-edit.typ"         // recorded terminal, frame 1
#include "slides/a5-demo4-out.typ"          // captured idris2 output / fallback
#include "slides/30-stage6-payoff.typ"      // A5-payoff — the dark Unrepresentable slide
// 31-the-climb moved to the appendix (Part 3): the last four minutes otherwise
// carry three summaries — the dark Unrepresentable slide, the climb table and
// the close. The dark slide and the close are the two that work.
// 33-horizon deleted: three lines on A6-monday, as budget.tsv has said since the
// cut list was written.
#include "slides/32-agentic.typ"           // A6-cost
#include "slides/a6-now.typ"               // A6-now — why the calculation is moving
#include "slides/where-to-start.typ"       // A6-monday
#include "slides/34-close.typ"             // A6-close

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
#include "slides/a11-production.typ"  // where these features actually run — Q&A
#include "slides/a12-not-covered.typ" // what the talk leaves out — Q&A
#include "slides/a08-singleton.typ"
#include "slides/a09-singletons.typ"
#include "slides/a10-invariants.typ"
#include "slides/31-the-climb.typ"   // the climb table — Q&A, cut from the main deck
#include "slides/14-lambda-cube.typ"     // full cube — Q&A; the reveals were cut   // the nine-row inventory, out of the main deck

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
