// Clock: 10:20–10:45
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  [The Computational Convergence],
  beat-grid((
    ([1936], [Church / Turing], [Formalise execution as reduction. Simply Typed Lambda Calculus: types restrict inputs and guarantee termination in the pure calculus.]),
    ([1935], [Gentzen], [Logic as local interface. Every connective defined by introduction and elimination. Cut elimination = compiler dead-code removal.]),
    ([1969], [Curry-Howard], [Proposition = Type. Proof = Program. Running = Simplifying a proof. Writing code that compiles = Constructing a proof.]),
    ([1972], [Martin-Löf], [Dependent types: return type computed from argument value. ∀ → Π-type. ∃ → Σ-type.]),
    ([1988], [Coquand], [Calculus of Constructions: dependent types unified with polymorphism in a small, auditable kernel — the engine behind Rocq, Lean, Agda, and Idris.]),
  )),
  footer: ["Under the Curry-Howard correspondence, well-typed code in a sufficiently expressive calculus IS a proof of the proposition its type expresses. Mainstream type checkers verify weaker, calculus-specific structural guarantees built on the same foundations."],
)

#speaker-note[
Beat 5 (Coquand, 20 sec): "Coquand, in 1988, unified Martin-Löf's dependent types with polymorphism in a small, auditable type-theory kernel — the Calculus of Constructions, extended to the Calculus of Inductive Constructions. That kernel is what powers proof-assistants Rocq, Lean, Agda, and Idris today."

Closing line, before advancing to S14: "In a calculus expressive enough to host the propositions you care about, well-typed code IS a proof of the corresponding statement. Each stage of this talk moves to a calculus that can host more interesting propositions about your code."
]
