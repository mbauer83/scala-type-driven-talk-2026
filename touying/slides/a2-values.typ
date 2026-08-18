// A2-values · cap 0:50 · Act 2 beat 2 of 3 · NEW
//
// The hinge between the logic primer and the code ladder, and the slide the
// "sounds expensive" reflex gets pre-empted on. Deliberately light.
//
// Two things must land here without being conflated (Part 3):
//   1. The value of types in this talk is mostly INDEPENDENT of erasure. They
//      are a design-time and compile-time tool, and most of the payoff arrives
//      before the program runs. The argument must not rest on erasure.
//   2. Dependent types are the deliberate exception. Stage 6 works precisely
//      because a runtime value flows INTO a type, and flattening that into
//      "types are erased anyway" destroys the Idris payoff before it arrives.
//      Hence the footnote — the exception is marked here and paid at A5.
//
// Gradual typing is NOT here. It is an adoption argument, not a claim about
// what a type is, and it belongs on A6-cost.
//
// C13 risk (Part 8): keep type/value distinct throughout. Never "types are
// values" or "values are types".
#import "../theme.typ": *
#import "../components.typ": *

#let defn(term, body) = grid(
  columns: (sz(240pt), 1fr),
  column-gutter: sz(28pt),
  align: (right + top, left + top),
  text(size: sz(28pt), weight: 500, fill: pal.fg)[#term],
  block[
    #set text(size: sz(27pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #body
  ],
)

#theory-slide(
  eyebrow: eyebrow([The ground floor], style: "normal"),
  [Types, values, references],
  [
    #v(sz(12pt))
    #stack(
      dir: ttb,
      spacing: sz(16pt),
      defn([a value], [a bit pattern, plus an agreement about how to read it]),
      defn([a reference], [a value that denotes a location]),
    )
    #v(sz(14pt))
    #block(width: 100%, inset: (left: sz(268pt)))[
      #set text(size: sz(23pt), fill: pal.fg-faint)
      #set par(leading: 0.45em)
      In Java the primitives are values and everything else is a reference, which
      is why `==` compares the reference and `.equals` compares the value — and why
      `record` exists, to give you value semantics over one.
    ]
    #v(sz(26pt))
    #block(
      width: 100%,
      fill: pal.bg-warm,
      inset: (x: sz(30pt), y: sz(22pt)),
      radius: sz(4pt),
    )[
      #set text(size: sz(28pt), fill: pal.fg)
      #set par(leading: 0.5em)
      A type is the compiler's #text(weight: 500)[reasoning about which values may
      flow where]. Most of what it buys is already spent before the program runs:
      while you model the domain, while the checker turns down a bad call, while
      somebody reads a signature and infers the contract from it.
      #v(sz(14pt))
      #align(center)[
        #text(font: mono-font, size: sz(26pt), fill: pal.fg-dim)[
          Payment\<Initiated\> #h(sz(20pt)) and #h(sz(20pt)) Payment\<Authorized\>
          #h(sz(20pt)) #text(fill: pal.accent)[are the same bytes.]
        ]
      ]
    ]
    #v(sz(26pt))
    #grid(
      columns: (1fr, 1fr),
      column-gutter: sz(48pt),
      align: (left + top, left + top),
      [
        #text(size: sz(24pt), weight: 600, fill: pal.fg)[Which is why it is affordable]
        #v(sz(8pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        A type parameter like the `<Initiated>` above carries no data at all.
        Scala's opaque types are plain `String`s at runtime, and Idris's
        use-once markers are gone before the program starts. You pay in
        compile-time expressiveness.
      ],
      [
        #text(size: sz(24pt), weight: 600, fill: pal.fg)[And what it costs]
        #v(sz(8pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        What you erase, you cannot ask about later.
        `x instanceof List<String>` does not compile, and that is the reason.
      ],
    )
    #v(sz(20pt))
    #align(center)[
      #text(size: sz(21pt), fill: pal.fg-faint)[
        Stage 6 runs the other way: there, a runtime value flows _into_ a type.
      ]
    ]
  ],
)

#speaker-note[
#read("../scripts/10-values.md")
]
