// A3-stage3 · cap 1:45 · Act 3 beat 3 of 8 · REWORK of v1 19-stage3
//
// v1 opened with a Function/map/lambda pane demonstrating type inference. It is
// real Stage 3 content and it is a distraction here: the slide's job (Part 3) is
// records + sealed = sums of products, with Bob's actual code beside the sealed
// version, and `Result<T>` as the same rule applied again. Lambdas get a clause.
//
// Bob's `if (risk != HIGH)` exists nowhere in the repository — it is narrative,
// from `A0-incidents`. So it is a labelled card, not a file pane (Part 12/R9),
// exactly as `RefundRule` is on `A1-connectives`. Everything in a pane with a
// filename tab is verbatim, bodies elided with `...`.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 3 · java 17 · records ⊕ sealed]),
  body-gap: sz(24pt),
  [Sums of products, in the language],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    grid(
      columns: (1fr, 1.2fr),
      column-gutter: sz(48pt),
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
      columns: (1.2fr, 1fr),
      column-gutter: sz(48pt),
      align: (left + top, left + horizon),
      code-pane(filename: "Result.java", language: "java", code-size: 17pt, pad-y: 12pt)[
```java
public sealed interface Result<T> permits Result.Ok, Result.Err {
    record Ok<T>(T value)          implements Result<T> {}
    record Err<T>(String message)  implements Result<T> {}
}
```
      ],
      [
        #set text(size: sz(25pt), fill: pal.fg)
        #set par(leading: 0.45em)
        #text(weight: 600)[And the same construction in the return type.]
        #text(fill: pal.fg-dim)[ A function that can fail says so, and you cannot
        reach the value without handling the failure — there is no `.get()` to
        skip past it. Scala spells this `Either`, Rust spells it `Result`.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/14-stage3.md")
]
