// Clock: ~10:05–10:20
#import "../theme.typ": *
#import "../components.typ": *
#import "../diagrams/mltt.typ": mltt-canvas

#theory-slide(
  [MLTT: Π and Σ Types],
  mltt-canvas,
  footer: [
    #text(fill: pal.accent)[Γ ⊢] reads "in some context Γ (variable assignments and type annotations in scope), we can derive that..." — Γ accumulates as you move under binders. \
    #v(sz(4pt))
    Idris 2 runs these rules at every call site. I'll show them in action in Stage 6.
  ],
)

#speaker-note[
"Two rules: Π-elimination — the return type is computed from the argument value. Σ-introduction — a value bundled with a proof that depends on that value. Both are rules of predicate logic — where ∀ and ∃ quantify over values, not just propositions. A proposition is a statement that's either true or false; a predicate is a property that a value may or may not have. Dependent types add that distinction to the type system."
]
