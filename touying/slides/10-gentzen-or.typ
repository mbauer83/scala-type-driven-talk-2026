// Clock: ~9:05–9:35
#import "../theme.typ": *
#import "../components.typ": *
#import "../diagrams/gentzen-or.typ": gentzen-or-canvas

#theory-slide(
  [Gentzen: Logic as Interface],
  gentzen-or-canvas,
  footer: [Two structural primitives carry most domain data in this talk: records (products — all fields at once) and sealed types (sums — exactly one variant). Stages 4 onwards add the rules and protocols layered on top.],
)

#speaker-note[
"So Gentzen's insight was that a logical connective is defined by how you build it and how you use it. For OR: you build it by supplying a proof of one of the two sides; you use it by providing handling for both cases. Worth noticing: these rules represent the constructive or intuitionistic reading of disjunction. In classical logic, which assumes a fixed universe of truths, the Law of the Excluded Middle lets you assert 'A or not A' without having evidence of either. Constructive logic, and Gentzen's natural deduction, require you to provide actual constructions of witnesses: to assert A∨B you must supply a proof of A or a proof of B. That's what missing the Right-branch means — you haven't provided the handling for all sides, so you can't handle the variant-type (or 'sum' type). The compiler enforcing exhaustive matching is enforcing exactly this. Two primitives are going to do most of the heavy lifting for the domain data in this talk: records, which are products — all fields present at once — and sealed types, which are sums — where any value is exactly one variant. The rules and protocols that go on top of that data come later."
]
