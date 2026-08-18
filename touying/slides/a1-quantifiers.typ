// A1-quantifiers · cap 1:05 · Act 1 beat 3 of 6
//
// REBUILT 18 Aug. MB's objection, which is the right one and which the previous
// two versions both failed:
//
//   "any function is already a universal quantification over all instances of
//    its input types. Why would generics make a difference?"
//
// Exactly. `assessRisk(Order order)` IS ∀o:Order — a non-dependent function type
// is Π with the body ignoring the binder. So presenting ∀ as the new thing, or
// presenting a generic as "∀ again", tells a room that can follow nothing at
// all, and the sharpest people in it will spot the gap and stop trusting the
// primer.
//
// What generics actually add is that the variable ranges over TYPES rather than
// values — second-order quantification, System F, one level up from Frege. And
// because the body never gets to ask what T is, one piece of code discharges the
// claim for every T at once.
//
// The two levels also set up the third: Π on A1-above is ∀ over values again,
// but with the RESULT TYPE allowed to mention the value. That is the shift that
// makes dependent types what they are, and it now has somewhere to land.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let level(tag, formula, gloss, pane) = {
  grid(
    columns: (sz(210pt), 1fr),
    column-gutter: sz(30pt),
    row-gutter: sz(12pt),
    align: (right + top, left + top),
    text(font: mono-font, size: sz(21pt), fill: pal.accent, weight: 500)[#upper(tag)],
    stack(
      dir: ttb,
      spacing: sz(12pt),
      text(font: mono-font, size: sz(30pt), fill: pal.fg)[#formula],
      pane,
      block[
        #set text(size: sz(23pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        #gloss
      ],
    ),
  )
}

#theory-slide(
  eyebrow: eyebrow([Frege · Begriffsschrift · 1879], style: "accent"),
  [Quantification: over values, then over types],
  body-gap: sz(30pt),
  [
    #block(width: 100%)[
      #set text(size: sz(25pt), fill: pal.fg-dim)
      Frege's move: put a hole in a proposition, then bind it. One sentence then
      covers cases nobody will ever write down.
    ]
    #v(sz(26pt))
    #level(
      [over values],
      [∀ o : Order.#h(sz(20pt))assessRisk(o) : RiskDecision],
      [A function type is a universal quantifier whose body ignores the binder.
       You write one every time you write a signature — one claim, every `Order`,
       including the ones placed tonight.],
      code-pane(filename: "PaymentService.java", language: "java", code-size: 21pt, pad-y: 8pt)[
```java
public static RiskDecision assessRisk(Order order)
```
      ],
    )
    #v(sz(28pt))
    #line(length: 100%, stroke: 0.5pt + pal.rule)
    #v(sz(22pt))
    #level(
      [over types],
      [∀ T.#h(sz(20pt))Predicate\<T\> × String → Validator\<T\>],
      [Here the variable ranges over #text(fill: pal.fg, weight: 500)[types], one
       level above Frege. The body gets no runtime handle on `T`, so one method
       covers every `T`. For the same reason there is little it can do to a `T`
       beyond what `Object` offers — which is why in practice you write
       `<T extends Comparable<T>>`, and get `compareTo` back.],
      code-pane(filename: "Validator.java", language: "java", code-size: 21pt, pad-y: 8pt)[
```java
static <T> Validator<T> check(Predicate<T> predicate, String errorMessage)
```
      ],
    )
    #v(sz(24pt))
    #align(right)[
      #text(size: sz(21pt), fill: pal.fg-faint)[
        #text(font: mono-font)[∃] — the other quantifier. Java's wildcards
        (`List<?>`) are a restricted form of it; the strong version, a value
        handed to you together with evidence about it, comes back at the top.
      ]
    ]
  ],
  footer: act1-rail(lit: ("Frege",)),
)

#speaker-note[
#read("../scripts/06-quantifiers.md")
]
