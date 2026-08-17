// =============================================================================
// test-classes.typ — Phase 1 validation target.
//
// Renders one slide per slide-class with lorem placeholder content, so each
// of the 9 layout variants can be visually inspected side-by-side with the
// CSS reference in style_other_presentation.css.
//
// Build:
//   typst compile test-classes.typ test-classes.pdf
// =============================================================================

#import "theme.typ": *
#import "components.typ": *
#import "code-pane.typ": code-pane

#show: our-theme

// ─── .s-title ───────────────────────────────────────────────────────────────

#title-slide(
  eyebrow: eyebrow([Java Meetup Cologne · 2026-05-28]),
  [Type-Driven #text(fill: pal.accent)[Programming]],
  [Correctness by construction — from the basics to the cutting edge.],
  [Michael Bauer · up2parts],
  [github.com/example/scala-type-driven-talk],
)

// ─── .s-incident ────────────────────────────────────────────────────────────

#incident-slide(
  [On-call · 2025-11-14],
  [Alice],
  [3 AM page. Stripe webhook stuck retrying after captures completed.],
  [Forgotten branch returned `undefined` for MEDIUM risk],
  [The risk classifier handled LOW and HIGH but silently fell off MEDIUM. Stripe saw nothing useful in the response body and kept retrying.],
  [`if (risk === "LOW")  authorize();
else if (risk === "HIGH") refer();
// MEDIUM ⇒ returns undefined  ← bug still compiles`],
)

// ─── .s-theory ──────────────────────────────────────────────────────────────

#theory-slide(
  eyebrow: eyebrow([Logic & Proof · 4th c. BCE → today], style: "accent"),
  [The Computational #text(fill: pal.accent)[Convergence]],
  beat-grid((
    ([1935], [Gentzen — natural deduction], [Each connective defined by intro/elim rules.]),
    ([1936], [Church / Turing — computability], [λ-calculus and Turing machines, equivalent.]),
    ([1969], [Curry–Howard — propositions ≡ types], [Proofs are programs; running ≡ simplifying.]),
    ([1972], [Martin-Löf — dependent types], [Types compute over values; Π and Σ types.]),
  )),
  footer: [→ S10 / S13 / S15 for the worked examples.],
)

// ─── .s-stage-opener ────────────────────────────────────────────────────────

#stage-opener-slide(
  [4],
  [Sealed types + exhaustive #text(fill: pal.accent)[switch]],
  [java · --enable-preview --release 21],
  [Forgetting a branch becomes a #text(fill: pal.bad)[compile error], not a 3 AM page.],
)

// ─── .s-light ───────────────────────────────────────────────────────────────

#light-slide(
  eyebrow: eyebrow([Stage 5 · Payoff]),
  [What the type checker just #text(fill: pal.accent)[closed]],
  [
    Authorization state now travels with the order's type. Calling
    `capture` on something that wasn't `authorized` is a compile error,
    not a runtime exception in production.

    #callout(
      "TAKEAWAY",
      [Lifecycle bugs in this domain are now structurally impossible — the type checker enforces what was previously enforced by hope and code review.],
    )

    #v(8pt)

    #signature-card[
      ```scala
      def capture[O <: Authorized](order: O): Captured[O]
      ```
    ]
  ],
)

// ─── .s-bignum ──────────────────────────────────────────────────────────────

#bignum-slide(
  [4 / 4],
  [Four incidents. Four classes of bug. All four now structurally impossible — verified by the test spine going to zero.],
)

// ─── .s-close ───────────────────────────────────────────────────────────────

#close-slide(
  [Pick the strongest type system #text(fill: pal.accent)[your domain can afford] — and write the bug you were going to write into the type.],
)

// ─── .s-qa ──────────────────────────────────────────────────────────────────

#qa-slide()

// ─── IDE-segment placeholder (light slide hosting a code-pane) ──────────────

#light-slide(
  eyebrow: eyebrow([Live edit · → Demo 4 in Demo.java], style: "accent"),
  [What we're about to #text(fill: pal.accent)[break]],
  [
    #code-pane(
      filename: "Demo.java",
      language: "java",
      [sealed interface Risk permits Low, Medium, High {}
switch (risk) {
    case Low    l -> authorize(order);
    case High   h -> refer(order);
}],
      highlights: ((4, "err"),),
    )
  ],
)
