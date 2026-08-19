#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let gain(n, head, body) = stack(
  dir: ttb,
  spacing: sz(15pt),
  grid(
    columns: (auto, 1fr),
    column-gutter: sz(14pt),
    align: (left + horizon, left + horizon),
    text(font: mono-font, size: sz(26pt), weight: 600, fill: pal.accent)[#n],
    text(size: sz(28pt), weight: 500, fill: pal.fg)[#head],
  ),
  block[
    #set text(size: sz(23pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Stages 1 and 2 · java 1–5]),
  body-gap: sz(30pt),
  [A name is a constraint],
  stack(
    dir: ttb,
    spacing: sz(42pt),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(48pt),
      row-gutter: sz(26pt),

      gain([1], [Nominal types, private constructors],
           [An `Order` is not an `Authorization`, and the compiler knows.
            The only way to make one is the factory, which takes the previous
            step as its argument.]),
      gain([2], [Generics — one claim, every type],
           [`Validator<T>`, written once. You met this on the Frege slide, as ∀:
            the signature is the claim, the body is what makes good on it.]),

      code-pane(filename: "Authorization.java", language: "java", code-size: 17pt, pad-y: 10pt,
                highlights: ((2, "err"), (4, "hl-good"), (5, "hl-good")))[
```java
public class Authorization {
    private Authorization(String orderId, String authCode,
                          int cents, String note) { ... }
    static Authorization from(Order order,
                              String approvalNote) { ... }
}
```
      ],
      code-pane(filename: "Validator.java", language: "java", code-size: 17pt, pad-y: 10pt)[
```java
static <T> Validator<T> check(Predicate<T> p, String msg)
```
      ],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    grid(
      columns: (auto, 1fr),
      column-gutter: sz(40pt),
      align: (left + horizon, left + horizon),
      block(fill: pal.bad-bg, inset: (x: sz(22pt), y: sz(14pt)), radius: sz(4pt))[
        #text(font: mono-font, size: sz(24pt), fill: pal.fg)[if (risk != HIGH) { fastPath(order); }]
      ],
      [
        #set text(size: sz(25pt), fill: pal.fg)
        #set par(leading: 0.45em)
        #text(weight: 600)[Bob's bug survives both stages]
        #text(fill: pal.fg-dim)[ — the risk level has a type of its own by now,
        and still nothing makes you handle every case.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/12-stage12.md")
]
