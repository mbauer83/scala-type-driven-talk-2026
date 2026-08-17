// Clock: 10:45–11:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../diagrams/lambda-cube.typ": lambda-cube-canvas

#theory-slide(
  [The Lambda Cube],
  lcube(
    lambda-cube-canvas,
    (
      ("f(x)",  [term on term], [ordinary function call — every language]),
      ("f[A]",  [term on type], [generic function — map[A,B], authorize[R <: Risk](...)]),
      ("F[A]",  [type on type], [type constructor — List[A], Validator[T], match types]),
      ("B(a)",  [type on term], [dependent type — protocolFromSnapshot(snap)]),
    ),
  ),
  footer: ["Stages 1–5 move along the first two axes (terms-on-types, types-on-types). Stage 6 crosses into the third (types-on-terms). That third axis is what makes Stage 6 qualitatively different from the others."],
)

#speaker-note[
"Construction in any language can mix terms and types in four ways. `f(x)` — term-on-term — your everyday function call, every language has this; that's simply-typed lambda calculus, λ→. `f[A]` — term-on-type — a function whose return type is parameterised by a type argument; that's parametric polymorphism, System F, Java and Scala's generics. `F[A]` — type-on-type — a type that takes a type argument and produces a type; `List` is the classic example, Haskell's type classes and Scala's match types are more sophisticated instances. `B(a)` — type-on-term — a type whose *shape* is computed from a runtime *value*; that's the third axis, the unique contribution of Stage 6, and the one Java and Scala cannot reach.

The lambda cube positions formal type systems by which of these directions they support. λ→ (STLC) is Java pre-generics, or the value layer of any dynamically-typed language. λ2 (System F) is Java's generics, Scala's generics, Haskell's core — `f[A]` added. λω adds type operators — `F[A]` — Haskell's type classes, Scala's match types, TypeScript's conditional types; Stages 4 to 5. λP (dependent function types) is Agda, Lean 4, Rocq, Idris 2 — `B(a)` added. λC (the Calculus of Constructions, top of the cube) is Rocq's Gallina kernel and Lean's core.

We start at Stage 1: nominal types, no abstraction. We move along the `f[A]` axis through Stages 2 to 4. We move along the `F[A]` axis through Stages 4 to 5. Stage 6 lifts us into the `B(a)` axis — which changes the nature of what the type checker can verify."
]
