// Clock: Q&A — Extended History III
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([Appendix A6 · History], style: "accent"),
  [Extended History III · The Computational Convergence],
  beat-grid((
    (
      [1935–36],
      [Church / Turing — Computation Formalised],
      [Typed λ-calculus is the safe sub-language where evaluation terminates. Turing completeness lives outside it.],
    ),
    (
      [1935],
      [Gentzen — Structural Proof Theory],
      [Each connective defined by introduction + elimination rules only. Cut elimination = compiler dead-code removal.],
    ),
    (
      [1969],
      [Howard — Curry-Howard Isomorphism],
      [Proposition = type. Proof = program. A ∧ B is a tuple. A → B is a function. Compilation is theorem proving.],
    ),
    (
      [1972],
      [Martin-Löf — Dependent Type Theory],
      [Types depend on runtime values. Π-type = ∀. Σ-type = ∃. This is Stage 6.],
    ),
    (
      [1988 / 2000s],
      [Coquand — CoC · Voevodsky — HoTT],
      [CoC: minimal kernel for Rocq/Lean/Agda/Idris. HoTT: equality is a path; isomorphic types are equal.],
    ),
  )),
)

#speaker-note[
"Church and Turing formalise computation; the typed lambda calculus is the safe sub-language where evaluation terminates. Gentzen redefines logic as something compositional — every connective has an introduction rule and an elimination rule, no more no less. Howard sees that these two systems — Gentzen's logic and Church's typed code — are the same mathematical structure under different names. Martin-Löf opens up the type system so types can depend on runtime values, which is exactly what we showed in Stage 6. Coquand packages all of this into the small auditable kernels that power modern proof assistants. Voevodsky reformulates equality itself as a topological object — the most aggressive recent move, still working its way into mainstream tooling."
]
