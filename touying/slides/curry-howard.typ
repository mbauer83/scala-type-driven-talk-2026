// That panel is gone: Gentzen's rule now has its own slide in Act 3
// (`A3-gentzen`), sixty seconds before the compile error it explains, so
// showing it here duplicated it AND overflowed the slide once the C13 block
// and the caveat were added. What replaces it is the C13 block — program /
// type / checker named as three different things.
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
// He is a side note in the left column instead.
  eyebrow: eyebrow([Church/Turing 1936 · Curry-Howard 1969], style: "accent"),
  [Proposition = Type.  Proof = Program.],
  [
    #v(sz(6pt))
    #grid(
      columns: (1fr, sz(800pt)),
      column-gutter: sz(96pt),
      align: (left + top, left + top),

      // ── left: the correspondence itself
      [
        #grid(
          columns: (sz(230pt), sz(40pt), 1fr),
          row-gutter: sz(16pt),
          align: (right + horizon, center + horizon, left + horizon),
          text(size: sz(34pt), fill: pal.fg)[Proposition],
          text(size: sz(30pt), fill: pal.fg-dim)[=],
          text(size: sz(34pt), weight: 600, fill: pal.accent)[Type],
          text(size: sz(34pt), fill: pal.fg)[Proof],
          text(size: sz(30pt), fill: pal.fg-dim)[=],
          text(size: sz(34pt), weight: 600, fill: pal.accent)[Program],
          text(size: sz(34pt), fill: pal.fg)[Running],
          text(size: sz(30pt), fill: pal.fg-dim)[=],
          text(size: sz(34pt), weight: 600, fill: pal.accent)[Simplification],
        )
        #v(sz(22pt))
        #line(length: 100%, stroke: 0.5pt + pal.rule-strong)
        #v(sz(14pt))
        #set text(size: sz(21pt), fill: pal.fg-faint)
        #set par(leading: 0.45em)
        Lambek later found the same structure a third time, over in category
        theory.
      ],

      block(fill: pal.bg-warm, inset: (x: sz(26pt), y: sz(22pt)), radius: sz(4pt))[
        #grid(
          columns: (sz(180pt), 1fr),
          row-gutter: sz(12pt),
          column-gutter: sz(18pt),
          align: (right + top, left + top),
          text(size: sz(25pt), weight: 600, fill: pal.accent)[your program],
          text(size: sz(25pt), fill: pal.fg)[is the construction],
          text(size: sz(25pt), weight: 600, fill: pal.accent)[its type],
          text(size: sz(25pt), fill: pal.fg)[says what you constructed a proof of],
          text(size: sz(25pt), weight: 600, fill: pal.accent)[the compiler],
          text(size: sz(25pt), fill: pal.fg)[checks the one against the other],
        )
        #v(sz(14pt))
        #text(size: sz(22pt), fill: pal.fg-dim)[
          True whether or not you write the types down. Untyped only means unchecked.
        ]
      ],
    )
    #v(sz(28pt))
    #callout(
      [What the arrow actually promises],
      [
        #grid(
          columns: (auto, 1fr),
          column-gutter: sz(54pt),
          row-gutter: sz(14pt),
          align: (left + horizon, left + horizon),
          text(font: mono-font, size: sz(30pt), fill: pal.fg)[A → B],
          text(size: sz(24pt), fill: pal.fg-dim)[the proposition your signature claims],
          text(font: mono-font, size: sz(30pt), fill: pal.fg)[
            A → ( B #text(fill: pal.bad)[| null] ) #text(fill: pal.bad)[throws C]
            #text(fill: pal.bad)[| never]
          ],
          text(size: sz(24pt), fill: pal.fg-dim)[the one Java can actually keep],
        )
        #v(sz(16pt))
        #text(size: sz(25pt), fill: pal.fg)[
          From here the talk repeats one move: something the code only
          #emph[promises] becomes something the type #emph[states].
        ]
      ],
      style: "bad",
    )
  ],
  footer: act1-rail(lit: ("Church", "Curry-Howard")),
)

#speaker-note[
#read("../scripts/08-curry-howard.md")
]
