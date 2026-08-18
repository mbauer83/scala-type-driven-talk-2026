// A3-stage12 · cap 1:15 · Act 3 beat 1 · MERGE of v1 17-stage1 + 18-stage2
//
// Two stage-opener slides became one. Neither carried a minute of content on its
// own: Stage 1 is "a name is a constraint, and the constructor is private", and
// Stage 2 the room has already met on `A1-quantifiers` as ∀ — showing
// `Validator<T>` again as though it were new spends time re-teaching.
//
// The bottom strip is the point of the slide. MB, 18 Aug: by here the contrast
// to Alice's untyped service had gone cold, and Stage 1 landed against nothing.
// `A2-scenario` restores the floor; this slide names what these two stages have
// NOT touched — Bob's branch, still compiling — which is what Gentzen and
// Stage 3 then close. Without it the act opens on two wins and no tension.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let gain(n, head, body) = stack(
  dir: ttb,
  spacing: sz(10pt),
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
  body-gap: sz(24pt),
  [A name is a constraint],
  stack(
    dir: ttb,
    spacing: sz(26pt),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(48pt),
      row-gutter: sz(16pt),

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
        #text(weight: 600)[Neither stage touched Bob.]
        #text(fill: pal.fg-dim)[ The risk level is a proper type. Nothing forces
        you to handle all of it.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/12-stage12.md")
]
