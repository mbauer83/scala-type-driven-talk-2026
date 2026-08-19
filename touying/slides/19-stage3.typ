#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 3 · java 17 · records ⊕ sealed]),
  body-gap: sz(30pt),
  [Sums of products, in the language],
  stack(
    dir: ttb,
    spacing: sz(44pt),
    grid(
            columns: (1fr, 1fr),
      column-gutter: sz(56pt),
      align: (left + horizon, left + top),
      [
        #set text(size: sz(26pt), fill: pal.fg)
        #set par(leading: 0.5em)
        The shape from Boole, now a language feature. #text(fill: pal.fg-dim)[A
        sealed interface is the sum, a record is the product — and the compiler
        refuses the program until every variant has a branch of its own.]
      ],
      code-pane(filename: "PaymentService.java", language: "java", code-size: 17pt, pad-y: 12pt,
                highlights: ((3, "hl-good"),))[
```java
return switch (risk) {
    case RiskDecision.Low l    -> { ... }
    case RiskDecision.Medium m -> { ... }
    case RiskDecision.High h   -> { ... }
};
```
      ],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    grid(
            columns: (1.18fr, 1fr),
      column-gutter: sz(56pt),
      align: (left + top, left + horizon),
      code-pane(filename: "Result.java", language: "java", code-size: 17pt, pad-y: 12pt)[
```java
public sealed interface Result<T, E> {
    record Ok <T, E>(T value) implements Result<T, E> {}
    record Err<T, E>(E error) implements Result<T, E> {}
}
public sealed interface PaymentError {          // the failure, also a sum
    record EmptyOrder()                 implements PaymentError {}
    record NonPositiveQuantity(int got) implements PaymentError {}
}
```
      ],
      [
        #set text(size: sz(25pt), fill: pal.fg)
        #set par(leading: 0.45em)
        #text(weight: 600)[And the same construction in the return type —
        on both sides.]
        #text(fill: pal.fg-dim)[ A function that can fail says so, and you cannot
        reach the value without handling the failure: there is no `.get()` to skip
        past it. The failure has a type of its own, and it is a sum of products
        too, so you switch on it rather than parse a string. Scala spells this
        `Either[E, T]`, Rust spells it `Result<T, E>`.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/14-stage3.md")
]
