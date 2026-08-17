// A1-crisis · cap 1:05 · Act 1 beat 4 of 6
// Restored from v1 and reframed: this is the origin story of the word "type",
// plus what a mechanical check can promise. A2-promises cashes the three
// requirements out for type checkers — do not do that work here.
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([Russell 1901 · Hilbert · Gödel 1931], style: "accent"),
  [The crisis, and where the word comes from],
  [
    #v(sz(10pt))
    #align(center)[
      #block(fill: pal.bg-warm, inset: (x: sz(34pt), y: sz(22pt)), radius: sz(4pt))[
        #set text(size: sz(31pt), fill: pal.fg)
        The set of all sets that do not contain themselves —\
        #align(center)[#text(fill: pal.bad, weight: 500)[does it contain itself?]]
      ]
    ]
    #v(sz(34pt))
    #grid(
      columns: (1fr, 1fr),
      column-gutter: sz(56pt),
      align: (left + top, left + top),
      [
        #text(size: sz(25pt), weight: 600, fill: pal.fg)[Russell's own repair]
        #v(sz(10pt))
        #set text(size: sz(26pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        Stratify everything. A predicate may not apply to things at its own level,
        so the self-reference cannot be written down.
        #v(sz(12pt))
        #text(size: sz(27pt), fill: pal.fg)[He called the levels #text(fill: pal.accent, weight: 600)[types].]
      ],
      [
        #text(size: sz(25pt), weight: 600, fill: pal.fg)[What Hilbert wanted of a system]
        #v(sz(10pt))
        #set text(size: sz(26pt), fill: pal.fg-dim)
        #set par(leading: 0.5em)
        #text(font: mono-font, fill: pal.fg)[consistent] — never derives a contradiction\
        #text(font: mono-font, fill: pal.fg)[sound] — anything it proves is true\
        #text(font: mono-font, fill: pal.fg-faint)[complete] — anything true can be proved
        #v(sz(14pt))
        #text(size: sz(26pt), fill: pal.fg)[
          Gödel, 1931: you cannot have all three.
        ]
      ],
    )
  ],
  footer: act1-rail(lit: ("Russell",)),
)

#speaker-note[
#read("../scripts/07-crisis.md")
]
