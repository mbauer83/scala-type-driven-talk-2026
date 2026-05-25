// Clock: Q&A — Extended History II
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([Appendix A5 · History], style: "accent"),
  [Extended History II · The Great Synthesis and the Crisis of Consistency],
  beat-grid((
    (
      [1879],
      [Frege — Begriffsschrift],
      [Decouples syntax from semantics. Introduces ∀ and ∃ — the apparatus Cantor's principle would break.],
    ),
    (
      [~1900],
      [Cantor — Set Theory],
      [Any definable property defines a set. Ground that Frege builds on — and Russell breaks.],
    ),
    (
      [1901],
      [Russell — The Paradox + Fix],
      ["Set of all sets not containing themselves" loops. Fix: types as a strict hierarchy blocking self-reference.],
    ),
    (
      [~1910],
      [Constructivists — Brouwer, Heyting, Kolmogorov],
      [Truth requires construction. A ∨ ¬A needs an active proof of one side — it is a tagged union.],
    ),
    (
      [~1930],
      [Hilbert + Gödel],
      [Hilbert demands completeness. Gödel proves it is impossible — the field pivots to soundness.],
    ),
  )),
  footer: ["We don't try to be complete; we try to be sound. And that we can deliver."],
)

#speaker-note[
"Frege builds the modern apparatus of formal logic. Cantor builds the modern apparatus of set theory. Russell shows the combination is inconsistent unless you restrict self-reference — and the restriction is types. The constructivists, in parallel, argue that 'true' should mean 'constructible.' Hilbert tries to nail down what a perfect system would have to look like. Gödel proves the strongest version of Hilbert's demand is impossible — which is, paradoxically, what gives modern type theory its scope: we don't try to be complete, we try to be sound, and that we can deliver."
]
