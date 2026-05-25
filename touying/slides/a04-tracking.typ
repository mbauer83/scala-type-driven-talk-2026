// Clock: Q&A — Extended History I
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([Appendix A4 · History], style: "accent"),
  [Extended History I · The Pre-History of Formal Structure],
  beat-grid((
    (
      [4th c. BCE],
      [Aristotle — Formal Logic],
      [Establishes the foundational concept of formal logic. By replacing concrete terms with variables, he shows that the validity of an argument can be evaluated entirely by its structural form, independent of semantic context. → plato.stanford.edu/entries/aristotle-logic/],
    ),
    (
      [17th c.],
      [Leibniz — Logic as Calculation],
      [Links logic directly to calculation. Unifies truth with consistency: "false" means "leads to a contradiction." Conceives a universal notation (_characteristica universalis_) and a mechanical calculus (_calculus ratiocinator_) to reduce reasoning to arithmetic. → plato.stanford.edu/entries/leibniz/],
    ),
    (
      [1847],
      [Boole — Logic as Algebra],
      [Realises the algebraic engine. Proves propositional logic — including implication — is modelled completely using only AND, OR, NOT; logical operations obey strict algebraic laws. → plato.stanford.edu/entries/boole/],
    ),
    (
      [1847],
      [DeMorgan — Structural Dualities],
      [Exposes the structural dualities within Boolean algebra (the laws bearing his name). Treats relations as first-class composable mathematical objects, and uses the formal language to map the mechanics of mathematical induction. → plato.stanford.edu/entries/demorgan/],
    ),
  )),
  footer: ["What we now call type-checking is the descendant of a 2,400-year argument about what makes inference valid."],
)

#speaker-note[
"The thread we'll follow is one specific question: what does it take to make valid inference explicit? Aristotle gave the first clean answer: validity comes from the structural form of an argument, not its content. Replace the words with variables; the form holds or it doesn't. Leibniz, two thousand years later, pushed this further — if valid inference is purely structural, then in principle it could be reduced to calculation, performed by a machine. He sketched both the notation and the calculus he thought would do it. The programme failed in his lifetime, but the idea is the line we're still walking. Boole and DeMorgan turned propositional logic into algebra. At every step, the move is the same: tighten what counts as a valid step, so more kinds of invalid judgements can be identified and excluded."
]
