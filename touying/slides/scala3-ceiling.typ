// Clock: ~34:00–35:00 (inserted between stage5-payoff and stage6-bridge)
// §1.3: Scala 3 ceiling — mirrors S25 Java ceiling in structure.
// "Scala's ceiling" callout moved here from 28-stage6-bridge.typ.
#import "../theme.typ": *
#import "../components.typ": *

// ── Local ceiling-col helper (same as 24-java-ceiling.typ) ──────────────────

#let ceiling-col(header, mark-color, mark, items) = stack(
  dir: ttb,
  spacing: sz(16pt),
  text(size: sz(24pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)[#header],
  line(length: 100%, stroke: 0.5pt + pal.rule-strong),
  stack(
    dir: ttb,
    spacing: sz(16pt),
    ..items.map(s => grid(
      columns: (sz(36pt), 1fr),
      gutter: sz(12pt),
      align: (center + horizon, left + horizon),
      text(size: sz(28pt), weight: 600, fill: mark-color)[#mark],
      text(size: sz(28pt))[#s],
    )),
  ),
)

#light-slide(
  eyebrow: eyebrow([Threshold]),
  [The Scala 3 Ceiling],
  stack(
    dir: ttb,
    spacing: sz(48pt),
    grid(
      columns: (1fr, 1fr),
      gutter: sz(72pt),
      ceiling-col(
        [WHAT SCALA 3 CAN ENCODE], pal.good, [✓],
        (
          "Phantom typestate",
          "Refined identifiers",
          "Session duality",
          "Exhaustive protocol dispatch",
        ),
      ),
      ceiling-col(
        [WHAT SCALA 3 CANNOT STATE], pal.bad, [✗],
        (
          "Protocol type from runtime value",
          "Channel-must-be-consumed",
          "Proof that dual(dual(P)) = P for all P",
          "Open-ended protocol vocabulary",
        ),
      ),
    ),
    callout(
      [Scala 3 Ceiling],
      [It's not that Scala 3 handles these badly — it's that the lambda cube has a third axis it cannot reach.],
      style: "bad",
    ),
  ),
)

#speaker-note[
"By Stage 5 we have used the best of what Scala 3's type system can do in this domain: phantom typestate, Iron refinements, match types for session duality, path-dependent message types. These are powerful and worth using in production. But there is a ceiling.

The ✗ column is not a list of things Scala 3 makes verbose. These are things Scala 3 cannot state at all. Take the first: `protocolFromSnapshot` takes a runtime risk snapshot and returns a `SessionType` specific to that snapshot value. In Scala 3, `SessionType` must be a sealed ADT — the full menu is written in source at compile time. There is no way to say 'the protocol whose shape depends on this specific runtime value.' The protocol is selected from a fixed menu at runtime, not derived from the runtime data. That's a different kind of ceiling from Java's.

The second: Scala 3 can track whether a value was used by convention and tests; its type system has no mechanism to require exactly-one-use on a binding. The `finish()` call can be forgotten without a type error. Third: Scala 3 can check `Dual[P] =:= Dual[Q]` for specific known P and Q — it cannot prove the general involution property `dual(dual(P)) = P` for all P by structural induction. That requires a proof assistant, not a type checker.

The lambda cube has a third axis: types whose shape is computed from runtime values. Scala 3 covers the first two axes well. Stage 6 crosses into the third."
]
