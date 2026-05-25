// Clock: 43:00–43:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Further Horizon]),
  [Beyond What We Have Shown Today],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    callout(
      [Lean 4],
      [Proof-heavy verification used in Mathlib and Mathematics 4. The type checker discharges the proofs you write, with growing tactic automation. The most accessible on-ramp: interactive in-browser proof games (Natural Number Game, Logic Game, Set Theory Game — adam.math.hhu.de).],
      style: "accent",
    ),
    callout(
      [Cubical Agda],
      [Richer equality and constructive reasoning; homotopy type theory as a programming language. Isomorphism between types is promoted to equality — the mathematical justification for refactoring.],
      style: "accent",
    ),
    callout(
      [HoTT / ∞-categories],
      [The landscape of types as spaces, isomorphism as equality, topology meeting proof theory. The active research frontier; working its way into mainstream proof-assistant tooling.],
      style: "accent",
    ),
    [
      #set text(size: sz(28pt), fill: pal.fg-dim, weight: 300)
      The right question is not "is this fancy?" It is:
      #text(fill: pal.fg, weight: 500)[is this invariant expensive enough to encode?]
    ],
  ),
)

#speaker-note[
"Lean, Agda, homotopy type theory — that's where the active frontier is. The reason to know they exist isn't to adopt them next sprint. It's to know there's considerably more headroom than what we've shown today, and that the tooling is maturing."
]
