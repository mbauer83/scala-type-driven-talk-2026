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
"So Gentzen's insight was that a logical connective is defined by how you build it and how you use it. For OR: you build it by supplying a proof of one of the two sides — ∨I₁ or ∨I₂; you use it by providing handling for both cases — ∨E.

The introduction rules are directly relevant for developers: when you write `new RiskDecision.Low()` or `new RiskDecision.Medium()` in Java, you are applying ∨I₁ or ∨I₂. You are constructing a witness that one specific variant holds. The sealed interface's `permits` clause is exactly what `A ∨ B` declares — those and only those variants exist. The introduction rules say: to assert A∨B, you must supply an actual proof of A, or an actual proof of B. You can't say 'I assert that one of these holds' without committing to which one and constructing it. That's the intuitionistic or constructive reading of disjunction — no free lunch, no assumed universal truths, just explicit witnesses.

This is what distinguishes constructive from classical logic. Classical logic has the Law of the Excluded Middle: you can assert 'A or not A' without producing evidence for either. Constructive logic — and Gentzen's natural deduction, and the compilers enforcing sealed-type exhaustiveness — require you to provide the actual construction. The ∨E rule is the dual: to draw any conclusion from a disjunction, you must handle every branch. The compiler enforcing exhaustive matching is enforcing ∨E. Together, ∨I is 'how you build a sealed-type value'; ∨E is 'how the compiler ensures you handle every one.'

Two primitives carry most of the domain data in this talk: records (products — all fields at once) and sealed types (sums — exactly one variant). The rules and protocols layered on top come later."
]
