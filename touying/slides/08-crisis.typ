// A1-crisis · cap 1:05 · Act 1 beat 4 of 6
// Restored from v1 and reframed: this is the origin story of the word "type",
// plus what a mechanical check can promise. A2-promises cashes the three
// requirements out for type checkers — do not do that work here.
//
// Part 10 rebuild, four corrections:
//   · the headline said "where the word comes from", which is an unintelligible
//     forward reference until the reader reaches "types" halfway down. It now
//     names the word.
//   · the slide posed the paradox and jumped straight to the repair without
//     saying what the paradox DESTROYS. The damage line is now on screen.
//   · Hilbert's three requirements arrived unmotivated. They are kept, and the
//     column head is now the question they answer.
//   · the barber sits above the set-theoretic form as the intuitive version.
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([Russell 1901 · Hilbert · Gödel 1931], style: "accent"),
  [The crisis that gave us the word *type*],
  body-gap: sz(56pt),
  [
    #v(sz(4pt))
    #align(center)[
      #block(fill: pal.bg-warm, inset: (x: sz(34pt), y: sz(20pt)), radius: sz(4pt))[
        #set text(size: sz(27pt), fill: pal.fg-dim)
        The barber shaves everyone who does not shave themselves.
        #h(sz(10pt)) #text(fill: pal.bad, weight: 500)[Who shaves the barber?]
        #v(sz(14pt))
        #line(length: 100%, stroke: 0.5pt + pal.rule)
        #v(sz(14pt))
        #set text(size: sz(29pt), fill: pal.fg)
        The set of all sets that do not contain themselves.
        #h(sz(10pt)) #text(fill: pal.bad, weight: 500)[Does it contain itself?]
      ]
    ]
    #v(sz(44pt))
    #align(center)[
      #set text(size: sz(26pt), fill: pal.fg)
      Either answer contradicts, and set theory was the ground being laid under
      arithmetic, analysis and proof itself.
    ]
    #v(sz(60pt))
    #grid(
      columns: (1fr, 1fr),
      column-gutter: sz(56pt),
      align: (left + top, left + top),
      [
        #text(size: sz(25pt), weight: 600, fill: pal.fg)[Russell's own repair]
        #v(sz(10pt))
        #set text(size: sz(25pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        Put everything on a level, and forbid anything from talking about things
        on its own level — so the sentence that breaks it cannot be written down.
        #v(sz(12pt))
        #text(size: sz(27pt), fill: pal.fg)[He called the levels #text(fill: pal.accent, weight: 600)[types].]
      ],
      [
        #text(size: sz(25pt), weight: 600, fill: pal.fg)[So what may we still ask of a formal system?]
        #v(sz(10pt))
        #set text(size: sz(25pt), fill: pal.fg-dim)
        #set par(leading: 0.5em)
        #text(font: mono-font, fill: pal.fg)[consistent] — never derives a contradiction\
        #text(font: mono-font, fill: pal.fg-faint)[complete] — anything true can be proved\
        #text(font: mono-font, fill: pal.fg)[checkable] — a machine can settle whether it is a proof
        #v(sz(12pt))
        #text(size: sz(25pt), fill: pal.fg)[
          Gödel, 1931: any consistent system big enough
          for arithmetic gives up #text(weight: 600)[complete].
        ]
      ],
    )
  ],
  footer: act1-rail(lit: ("Russell",)),
)

#speaker-note[
#read("../scripts/07-crisis.md")
]
