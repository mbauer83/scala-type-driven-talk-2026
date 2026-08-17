// Clock: 25:00–26:00
#import "../theme.typ": *
#import "../components.typ": *

#let ceiling-col(header, mark-color, mark, items) = stack(
  dir: ttb,
  spacing: sz(16pt),
  text(size: sz(24pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)[#header],
  line(length: 100%, stroke: 0.5pt + pal.rule-strong),
  stack(
    dir: ttb,
    spacing: sz(16pt),
    ..items.map(s => grid(
      columns: (sz(36pt), 1fr),
      gutter: sz(12pt),
      align: (center + horizon, left + horizon),
      text(size: sz(28pt), weight: 600, fill: mark-color)[#mark],
      text(size: sz(28pt))[#s],
    )),
  ),
)

#light-slide(
  eyebrow: eyebrow([Threshold]),
  [The Java Ceiling],
  stack(
    dir: ttb,
    spacing: sz(56pt),  // generous vertical break between table and ceiling callout
    grid(
      columns: (1fr, 1fr),
      gutter: sz(72pt),
      ceiling-col(
        [WHAT JAVA CAN ENCODE], pal.good, [✓],
        ("Nominal types", "Parametric polymorphism", "Sum types + exhaustive match", "Phantom lifecycle state"),
      ),
      ceiling-col(
        [WHAT JAVA CANNOT REACH], pal.bad, [✗],
        ("Type index derived from a *runtime* value", "Predicate carried in the type", "Types computed from types", "Path-dependent message types"),
      ),
    ),
    callout(
      [Ceiling],
      [Java can encode more than it looks like — phantom generics and witness encodings go a long way. What it has no mechanism for is deriving a type from a value the program only learns at runtime.],
      style: "bad",
    ),
    // ── Concrete counter-example: risk level not carried in type ──────────
    callout(
      [Still compiles after Stage 4],
      raw(lang: "java",
        "RiskDecision risk   = assessRisk(mediumOrder);    // MEDIUM at runtime
" +
        "Payment<Initiated>  init = Payment.initiate(mediumOrder);
" +
        "Payment<Authorized> auth = Payment.authorizeAuto(init); // ← wrong method
" +
        "// The type of init does not carry MEDIUM.
" +
        "// Java has no mechanism to express that constraint."
      ),
      style: "bad",
    ),
  ),
)

#speaker-note[
"By Stage 4 we've used most of what modern Java's type system offers in this domain: sealed types, records, phantom generics, explicit lifecycles. These are all real, all worth using in production. But there is a ceiling. Be careful how I put this, because Java can encode more than people expect — you can index approvals by a phantom risk parameter, and with a witness encoding you can even connect a sealed type to its own index. What Java has no mechanism for is taking a value the program only learns at runtime and deriving a type from it. Take one example: the risk level. It's a runtime value — the output of `assessRisk(order)`. Java's type system has no mechanism to carry that runtime information into the shape of the next method call's signature. Once we classify an order as medium-risk, the developer can still call `authorizeAuto`; the connection between the risk classification and the required authorization method lives in convention and documentation, not in the type-checker. Same story for refined types — a predicate like 'this string is non-empty' is a runtime check in Java, not part of the type. Same story for types computed from other types. So the honest ceiling is narrower than 'Java can't do this', and it still holds: no type index from a runtime value, no predicate inside the type, no computing types from types. Let's see what a system with those looks like."
]
