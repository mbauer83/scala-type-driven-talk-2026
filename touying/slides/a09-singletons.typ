// Clock: Q&A — Singletons / literal types as a bridge to dependent typing
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": code-pane

#light-slide(
  eyebrow: eyebrow([Appendix A9 · Simulated Dependent Types], style: "accent"),
  [Singletons — Pretending to Depend on a Value],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    [
      #set text(size: sz(26pt), fill: pal.fg-dim)
      #set par(leading: 0.4em)
      A literal singleton type contains exactly #text(weight: 600, fill: pal.fg)[one value].
      That razor-thin type lets a runtime literal flow into a place
      that normally only accepts a type — the value→type bridge.
    ],
    grid(
      columns: (1fr, 1fr),
      gutter: sz(36pt),
      align: (left + top, left + top),
      // Left — the singleton example
      code-pane(filename: "Singletons.scala", language: "scala")[
```scala
// Literal type — only `1234` has this type
def openGate(code: 1234.type): OpenGate
def openGate(code: Int):       ClosedGate

// Combine with match types to "depend" on a literal
type Level = "Low" | "Medium" | "High"
type Pricing[L <: Level] = L match
  case "Low"    => FastPath
  case "Medium" => Reviewed
  case "High"   => Manual
```
      ],
      // Right — what's actually happening
      stack(
        dir: ttb,
        spacing: sz(14pt),
        text(size: sz(22pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)[THE BRIDGE],
        line(length: 100%, stroke: 0.5pt + pal.rule),
        [
          #set text(size: sz(22pt))
          #set par(leading: 0.4em)
          Pair a #text(weight: 600)[singleton] (a literal whose only inhabitant is itself) with
          a #text(weight: 600)[match type] (a type-level pattern-matcher) and the literal can
          steer a type-level result.
        ],
        v(sz(4pt)),
        [
          #set text(size: sz(22pt), fill: pal.fg-dim)
          #set par(leading: 0.4em)
          Dependent-type _behaviour_ achieved entirely at compile time. The
          runtime value-space is still untouched — only literals make it across.
        ],
      ),
    ),
    callout(
      [Why not climb to the actual summit (CIC / λΠ)?],
      [
        #set text(size: sz(22pt))
        Full dependent types erase the compile/runtime boundary — any term can
        appear in a type, so the compiler must EVALUATE arbitrary programs while
        type-checking. That forces #text(weight: 600)[totality checking] — every
        function proven to terminate — onto ordinary code. Scala / TypeScript decline
        the bargain. Idris / Agda / Lean / Rocq pay the price.
      ],
      style: "bad",
    ),
  ),
)

#speaker-note[
"Singletons close the value-to-type gap without paying for dependent types. A literal `1234` gets the type `1234.type`, which contains only that one value. Plug that singleton into a match-type, and a runtime literal can now steer a compile-time computation — so a function's return type becomes a function of its argument's _value_. That's dependent-type behaviour, achieved entirely at compile time. The trade-off: only literals cross the bridge — there's no general way to lift an arbitrary runtime `Int` or `String` into a type. So why not climb the rest of the way to Idris / Agda / Lean? Because real dependent types erase the boundary completely: a type can depend on any term, so the compiler must be able to evaluate any program while type-checking. That forces totality — every function must terminate — and that puts a proof burden on ordinary code. Stage 7's `believe_me` casts are the honest acknowledgement that even there, the transport layer still steps outside what's proven."
]
