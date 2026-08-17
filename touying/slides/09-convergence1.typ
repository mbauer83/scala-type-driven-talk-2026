// Clock: 8:30–9:05
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  [The Computational Convergence],
  beat-grid(dim_previous: true, (
    ([1936], [Church / Turing], [Formalise execution as reduction. Simply Typed Lambda Calculus (pure STLC): types restrict inputs, and — in the pure calculus — guarantee that every evaluation terminates. Real-world languages relax this to admit general recursion.]),
    ([1935], [Gentzen], [Logic as local interface. Every connective defined by: how you BUILD it (introduction) and how you USE it (elimination). Cut elimination = compiler dead-code removal.]),
  )),
)

#speaker-note[
Beat 1 (Church/Turing, 20 sec): "Church and Turing formalised computation in 1936. Later, Church's typed lambda calculus made it safe — types restrict what a function can be applied to, and in the pure simply-typed calculus guarantee that every evaluation terminates. Industrial languages relax this to admit general recursion; what carries over is the technique of restricting inputs by types."

Beat 2 (Gentzen, 25 sec): "Gentzen, a year earlier, reframed logic itself: every logical connective — AND, OR, IF-THEN — every connective is defined entirely by how you BUILD it and how you USE it. Introduction rules and elimination rules."

→ Advance to Slide 10 (~30 sec dwell on Gentzen's OR rules — the worked example), then advance to Slide 11.
]
