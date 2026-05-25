// =============================================================================
// test-patterns.typ — Phase 3 validation: one slide per pattern component.
//
// Slide 1: test-list  — 9 items: 4 gone, 2 just-gone, 3 active
// Slide 2: story-strip — 4 chips (Alice/Bob/Charlie/Danielle), 2 closed
// Slide 3: ladder     — encoded-active: true
// Slide 4: lcube      — lambda-cube-canvas with 3-axis legend
// Slide 5: beat-grid  — 4 entries with when/what/sub
//
// Build: cd touying && typst compile test-patterns.typ test-patterns.pdf
// =============================================================================

#import "theme.typ": *
#import "components.typ": *
#import "diagrams/lambda-cube.typ": lambda-cube-canvas

#show: our-theme

// ─── Slide 1 — test-list ─────────────────────────────────────────────────────

#light-slide(
  eyebrow: eyebrow([Phase 3 · test-list], style: "accent"),
  [Test Coverage Grid],
  test-list((
    // gone (4)
    ([T1], [payment serialises to JSON correctly],         [S03], "gone"),
    ([T2], [null reference in MEDIUM risk branch],         [S06], "gone"),
    ([T3], [undefined return on missing risk case],        [S09], "gone"),
    ([T4], [Stripe retries on empty webhook response],     [S12], "gone"),
    // just-gone (2)
    ([T5], [risk enum exhaustiveness — no missing branch], [S15], "just-gone"),
    ([T6], [illegal payment state transitions rejected],   [S18], "just-gone"),
    // active (3)
    ([T7], [type-safe order id prevents mix-up],           [S22], "active"),
    ([T8], [linear session prevents double-charge],        [S28], "active"),
    ([T9], [protocol derivation matches specification],    [S32], "active"),
  ))
)

// ─── Slide 2 — story-strip ───────────────────────────────────────────────────

#light-slide(
  eyebrow: eyebrow([Phase 3 · story-strip], style: "accent"),
  [Persona Status],
  story-strip((
    ("Alice",    [checkout flow],     "ACTIVE",    false),
    ("Bob",      [payment api],       "RESOLVED",  true),
    ("Charlie",  [fraud detection],   "IN REVIEW", false),
    ("Danielle", [reporting],         "RESOLVED",  true),
  ))
)

// ─── Slide 3 — ladder ────────────────────────────────────────────────────────

#light-slide(
  eyebrow: eyebrow([Phase 3 · ladder (encoded-active)], style: "accent"),
  [The Climb],
  ladder(
    [
      #list(
        [Domain model reviewed],
        [API contract documented],
        [Edge cases catalogued],
      )
    ],
    [
      #list(
        [Unit tests pass],
        [Integration tests pass],
        [Property tests added],
      )
    ],
    [
      #list(
        [`OrderId` newtype],
        [Sealed `Payment` trait],
        [Session protocol type],
      )
    ],
    encoded-active: true,
  )
)

// ─── Slide 4 — lcube ─────────────────────────────────────────────────────────

#theory-slide(
  eyebrow: eyebrow([Phase 3 · lcube], style: "accent"),
  [Lambda Cube — System Classification],
  lcube(
    lambda-cube-canvas,
    (
      ("Y→", [terms-on-types], [polymorphism · System F]),
      ("Z↑", [types-on-types], [type operators · Fω]),
      ("X↗", [types-on-terms], [dependent types · CIC]),
    ),
  )
)

// ─── Slide 5 — beat-grid ─────────────────────────────────────────────────────

#theory-slide(
  eyebrow: eyebrow([Phase 3 · beat-grid], style: "accent"),
  [Historical Milestones],
  beat-grid((
    ([1935], [Gentzen — natural deduction],          [Each connective defined by intro/elim rules.]),
    ([1969], [Curry–Howard — propositions ≡ types],  [Proofs are programs; types are propositions.]),
    ([1972], [Martin-Löf — dependent types],         [Types that compute over values; Π and Σ.]),
    ([1989], [Coquand — Calculus of Constructions],  [Foundation for Coq, Lean, Agda, Idris 2.]),
  ))
)
