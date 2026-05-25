// Clock: 25:00–26:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Threshold]),
  [The Java Ceiling],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    grid(
      columns: (1fr, 1fr),
      gutter: sz(32pt),
      stack(
        dir: ttb,
        spacing: sz(16pt),
        text(size: sz(26pt), weight: 500, font: mono-font, fill: pal.fg-dim)[WHAT JAVA CAN ENCODE],
        line(length: 100%, stroke: 0.5pt + pal.rule-strong),
        stack(
          dir: ttb,
          spacing: sz(14pt),
          ..("Nominal types", "Parametric polymorphism", "Sum types + exhaustive match", "Phantom lifecycle state").map(s =>
            grid(
              columns: (1fr, auto),
              text(size: sz(28pt))[#s],
              text(size: sz(28pt), fill: pal.good)[✓],
            )
          ),
        ),
      ),
      stack(
        dir: ttb,
        spacing: sz(16pt),
        text(size: sz(26pt), weight: 500, font: mono-font, fill: pal.fg-dim)[WHAT JAVA CANNOT STATE],
        line(length: 100%, stroke: 0.5pt + pal.rule-strong),
        stack(
          dir: ttb,
          spacing: sz(14pt),
          ..("Approval indexed by risk level", "Predicate carried in the type", "Types computed from types", "Path-dependent message types").map(s =>
            grid(
              columns: (1fr, auto),
              text(size: sz(28pt))[#s],
              text(size: sz(28pt), fill: pal.bad)[✗],
            )
          ),
        ),
      ),
    ),
    callout(
      [Ceiling],
      [It's not just hard to express these invariants in Java — the type system lacks the machinery to state them at all.],
      style: "bad",
    ),
  ),
)

#speaker-note[
"By Stage 5 we've used most of what modern Java's type system offers in this domain: sealed types, records, phantom generics, explicit lifecycles. These are all real, all worth using in production. But there's a ceiling — and the things on the other side of it are not just verbose to encode in Java, they are not expressible. Take one example: the risk level. It's a runtime value — the output of `assessRisk(order)`. Java's type system has no mechanism to carry that runtime information into the shape of the next method call's signature. Once we classify an order as medium-risk, the developer can still call `authorizeAuto`; the connection between the risk classification and the required authorization method lives in convention and documentation, not in the type-checker. Same story for refined types — a predicate like 'this string is non-empty' is a runtime check in Java, not part of the type. Same story for types computed from other types. It's not just hard to express this in Java — we need a more expressive type system. Let's see what that looks like."
]
