// Clock: 9:35–10:05
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  [The Computational Convergence],
  beat-grid((
    ([1936], [Church / Turing], [Formalise execution as reduction. Simply Typed Lambda Calculus: types restrict inputs and guarantee termination in the pure calculus.]),
    ([1935], [Gentzen], [Logic as local interface. Every connective defined by introduction and elimination. Cut elimination = compiler dead-code removal.]),
    ([1969], [Curry-Howard], [Proposition = Type. Proof = Program. Running = Simplifying a proof. Writing code that compiles = Constructing a proof.]),
    ([1972], [Martin-Löf], [Dependent types: return type computed from argument value. ∀ → Π-type (dependent function). ∃ → Σ-type (dependent pair).]),
  )),
)

#speaker-note[
Beat 3 (Curry-Howard, 20 sec): "Howard, in 1969, showed these two worlds are the same world. A logical proposition corresponds to a type. A proof corresponds to a program. Running a program is simplifying a proof. Writing code that compiles is, structurally, constructing a proof."

Beat 4 (Martin-Löf, 30 sec): "Martin-Löf went further: types can depend on values. The Π-type — read as 'for every x of type A, I can produce a y whose type is specific to that x'. The Σ-type — read as 'here's a value, paired with a proof that depends on that value'. These are the building blocks of dependent types."

→ Advance to Slide 12 (~15 sec dwell on Π and Σ formation rules), then advance to Slide 13.
]
