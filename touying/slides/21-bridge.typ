// Clock: 19:30–21:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Bridge · Stage 3 → Stage 4]),
  [From Records to Typestate],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    [
      #set text(size: sz(34pt), weight: 300)
      ADTs gave us honest domain modelling. But lifecycle state still lives in the
      *class name*, not the *type parameter*.
    ],
    callout(
      [Still possible],
      stack(
        dir: ttb,
        spacing: sz(16pt),
        raw(lang: "java", "Authorization auth = new Authorization(...)  // public record constructor"),
        raw(lang: "java", "Capture cap        = new Capture(...)        // constructible independently"),
      ),
      style: "bad",
    ),
    [
      #set text(size: sz(30pt), fill: pal.fg-dim)
      The lifecycle grammar is implicit — comments and convention. Not the type system.

      #v(sz(12pt))
      #text(weight: 500)[Next: make the state the parameter.]
    ],
  ),
)

#speaker-note[
"Stage 3 gave us algebraic data types: records as product types — all fields present, equality by value — and sealed interfaces as sum types — a closed set of variants the compiler knows in full. ADTs are sums of products. Risk goes from a plain enum to a sealed hierarchy that the compiler checks exhaustively. Payment method is a sealed hierarchy of card / wallet / invoice variants. `Result` is a sum type for error handling. All real, structural gains. But look at how lifecycle is modelled: `Authorization` and `Capture` are separate record classes. A developer can still construct a `Capture` without first constructing an `Authorization` — the type system has no opinion on ordering. The lifecycle grammar lives in documentation and developer memory. Stage 4 changes that by moving the state into the type parameter itself."
]
