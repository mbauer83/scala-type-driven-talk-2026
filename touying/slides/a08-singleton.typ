// Clock: Q&A — Match types (type-level rewrite system)
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": code-pane

#light-slide(
  eyebrow: eyebrow([Appendix A8 · Type-level Logic], style: "accent"),
  [Match Types — Pattern-Matching at the Type Level],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    [
      #set text(size: sz(26pt), fill: pal.fg-dim)
      #set par(leading: 0.4em)
      Match types stay on the type-operators axis (Fω) but let type-level
      functions #text(weight: 600, fill: pal.fg)[pattern-match on shape]
      and #text(weight: 600, fill: pal.fg)[recurse structurally]. The
      compiler runs a real algorithm — types-in, types-out, never values.
    ],
    grid(
      columns: (1fr, 1fr),
      gutter: sz(36pt),
      align: (left + top, left + top),
      // Left — example: Dual
      code-pane(filename: "Derivation.scala", language: "scala")[
```scala
type Dual[P <: Protocol] <: Protocol = P match
  case End           => End
  case Send[a, n]    => Receive[a, Dual[n]]
  case Receive[a, n] => Send[a, Dual[n]]
  case Choose[l, r]  => Offer[Dual[l], Dual[r]]
```
      ],
      // Right — the mechanism in words
      stack(
        dir: ttb,
        spacing: sz(14pt),
        text(size: sz(22pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)[ι-REDUCTION],
        line(length: 100%, stroke: 0.5pt + pal.rule),
        [
          #set text(size: sz(22pt))
          #set par(leading: 0.4em)
          A match type is a #text(weight: 600)[rewrite rule] the compiler unfolds while
          type-checking. Each case is a pattern on the input type and a result
          type — including recursive calls to itself.
        ],
        v(sz(4pt)),
        [
          #set text(size: sz(22pt), fill: pal.fg-dim)
          #set par(leading: 0.4em)
          Termination is the compiler's responsibility: Scala refuses match-types it
          can't prove to converge. So this is computation, but bounded computation —
          you don't pay the totality price you would for full dependent types.
        ],
      ),
    ),
    callout(
      [What it is _not_],
      [Match types still take only #text(weight: 600)[types] as input. They cannot
      see a runtime `Int` or `String`. To bridge a runtime value into this
      machinery, you need singletons — see next slide.],
      style: "accent",
    ),
  ),
)

#speaker-note[
"Match types are pattern-matching, recursion, and rewriting — at the type level. Scala compiles `Dual[Send[Order, End]]` by unfolding the cases: `Send` matches the second arm, so the result is `Receive[Order, Dual[End]]`. That recursive call unfolds again into `Receive[Order, End]`. The compiler did this without ever seeing a runtime value — it's purely a type-level computation. The technical name is ι-reduction; this is what puts Scala on the Fω + type-operators axis of the lambda cube. Crucially, this is _not_ dependent typing: the match-type input is still a type, never a value. To bridge to runtime values you need singleton types — that's the next slide."
]
