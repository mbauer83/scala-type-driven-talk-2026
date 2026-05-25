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
"Gentzen's insight: a logical connective isn't a primitive thing with semantics attached — it's defined by how you build it and how you use it. Two rule sets, one connective. For OR: you build it by supplying a proof of either side; you use it by handling every case. Worth noticing: these rules represent the constructive reading of disjunction. Classical logic lets you assert 'A or B' without constructing either side — by the Law of Excluded Middle, A∨¬A is simply a given. Constructive logic, and Gentzen's natural deduction, require an actual witness: to assert A∨B you must supply a proof of A or a proof of B. That's why missing the Right branch isn't just incomplete — you haven't provided the witness the elimination rule requires. The compiler enforcing exhaustive matching is enforcing exactly this. Two primitives are going to do most of the heavy lifting for the domain data in this talk: records, which are products — all fields present at once — and sealed types, which are sums — exactly one variant. The rules and protocols that go on top of that data come later."
]
