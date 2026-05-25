// Clock: 10:45–11:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../diagrams/lambda-cube.typ": lambda-cube-canvas

#theory-slide(
  [The Lambda Cube],
  lcube(
    lambda-cube-canvas,
    (
      ("t·t", [term on term], [ordinary code — function application (every language)]),
      ("t·T", [term on type], [generics (∀) · authorize[R <: Risk](...)]),
      ("T·T", [type on type], [type operators · List[A], Validator[T], match types]),
      ("T·t", [type on term], [dependent types · protocolFromSnapshot(snap)]),
    ),
  ),
  footer: ["Stages 1–6 move along the first two axes (terms-on-types, types-on-types). Stage 7 crosses into the third (types-on-terms). That third axis is what makes Stage 7 qualitatively different from the others."],
)

#speaker-note[
"Construction in any language can mix terms and types in four ways. Term-on-term — your everyday function application, every language has this. Term-on-type — a function whose definition is parameterised by a type, that's a polymorphic function, generics, Stage 2 onward. Type-on-type — already starts simply with type constructors like `List[A]` (a type that takes a type and returns a type), and gets more sophisticated with type-level computation: match types, type families, even logic expressed at the type level. That's Stage 5 to 6. Type-on-term — a type whose shape is computed from a runtime value — is the third axis and the unique contribution of Stage 7. The lambda cube positions formal type systems by which of these directions they support. We start at simply typed lambda calculus, Stage 1: nominal types, no abstraction over types. We move along the generics axis through Stages 2 to 5. We move along the type-operators axis through Stages 5 to 6. Stage 7 lifts us into the third axis — types depending on values — which Scala and Java cannot reach."
]
