// Clock: ~43:30–44:00 (inserted between horizon and close)
// §1.4: "Where to start tomorrow" — actionable investment ladder for the median
// practitioner. The a07 appendix covers the deeper reading list for Q&A.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Where to Start]),
  [What to Do on Monday],
  stack(
    dir: ttb,
    spacing: sz(8pt),
    beat-grid((
      (
        [NOW],
        [Stage 3 in existing Java 17],
        [sealed interfaces + switch expressions — zero new dependencies, one afternoon.],
      ),
      (
        [SOON],
        [Stage 4 in existing Java],
        [Phantom generics — one interface, private constructor. One bounded-context service.],
      ),
      (
        [NEXT],
        [Stage 5: sbt new + Iron library],
        [90-minute port of a bounded-context service. See the Stage 5 repo for the scaffold.],
      ),
      (
        [HORIZON],
        [Stage 6: Idris 2],
        [Read "Type-Driven Development with Idris" (Brady, 2017) — the clearest on-ramp to dependent types with realistic examples.],
      ),
    )),
    v(sz(24pt)),
    align(right)[
      #text(size: sz(22pt), fill: pal.fg-faint, font: mono-font)[
        Full reading list in the appendix → A7
      ]
    ],
  ),
)

#speaker-note[
"The most common post-talk question is: what do I do on Monday? Here is a concrete ladder. NOW: sealed interfaces and switch expressions are in Java 17 today. No dependencies. Stage 3 takes an afternoon. SOON: phantom generics are one interface with a private constructor. You can add them to one bounded-context service without touching anything else. A sprint. NEXT: Scala 3 and Iron. The sbt scaffold is in the Stage 5 repo — it's a 90-minute port of a bounded-context service. That's a focused Friday afternoon or a short hackathon. HORIZON: Idris 2. The Brady book is still the best on-ramp — it builds up to dependent types using payment-domain-style examples. A week of evenings gets you fluent enough to read the session-types code in Stage 6. The full reading list — formal foundations, proofs in practice, language references — is in the appendix on A7. The right question is not 'is this mature?' It is: 'is this invariant expensive enough to encode?'"
]
