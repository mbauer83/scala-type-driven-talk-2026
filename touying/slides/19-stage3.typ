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
  body-gap: sz(20pt),
  [Sums of products, in the language],
  stack(
    dir: ttb,
    spacing: sz(24pt),
    grid(
      columns: (1fr, 1.15fr),
      column-gutter: sz(44pt),
      row-gutter: sz(12pt),
      align: (left + top, left + top),

      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.bad)[Bob wrote this.] Correct, for two risk levels.
      ],
      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.good)[The compiler will not accept the gap.]
        Every variant, or it does not build.
      ],

      block(
        width: 100%, fill: pal.bad-bg, radius: sz(6pt),
        inset: (x: sz(24pt), y: sz(20pt)),
      )[
        #show raw: set text(font: mono-font, size: sz(19pt), fill: pal.fg)
        #raw(block: true,
          "if (risk != HIGH) {\n    return fastPath(order);\n}")
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
      columns: (1.15fr, 1fr),
      column-gutter: sz(44pt),
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
        #set text(size: sz(24pt), fill: pal.fg)
        #set par(leading: 0.45em)
        #text(weight: 600)[The same rule, in the return type.]
        #text(fill: pal.fg-dim)[ A function that can fail says so, and you cannot
        reach the value without handling the failure. No `.get()` to skip it.
        Scala spells this `Either`, Rust spells it `Result`.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/14-stage3.md")
]
