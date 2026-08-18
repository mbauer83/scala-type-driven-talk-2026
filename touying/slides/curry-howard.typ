// A1-curry-howard · cap 1:30 · Act 1 beat 5 of 6 · the fulcrum
//
// v1 paired the three equations with a ∨E ≅ exhaustive-match panel. That panel
// is gone: Gentzen's rule now has its own slide in Act 3 (`A3-gentzen`), sixty
// seconds before the compile error it explains, so showing it here duplicated
// it AND overflowed the slide once the C13 block and the caveat were added.
//
// What replaces it is the C13 block — program / type / checker named as three
// different things. See Part 8/C13: this is the one place in the talk where the
// equivocation is closed explicitly.
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  // Lambek is off the eyebrow on purpose (Part 10): listed beside Church/Turing
  // and Curry-Howard he reads as a co-equal third pillar. He is a side note in
  // the left column instead.
  eyebrow: eyebrow([Church/Turing 1936 · Curry-Howard 1969], style: "accent"),
  [Proposition = Type.  Proof = Program.],
  [
    #v(sz(6pt))
    #grid(
      columns: (sz(560pt), 1fr),
      column-gutter: sz(52pt),
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

      // ── right: C13, the distinction the whole primer rests on
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
    // MB, 18 Aug: the caveat was 85 words of prose in a callout. It is a
    // comparison, so show the comparison — the claim the signature makes, and
    // the one Java can actually keep. The monad / continuations point that used
    // to be here is in the script's PREPARATION block; it is Q&A material.
    #callout(
      [The honest caveat — *which proposition*, not whether],
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
          Every stage from here deletes one of those alternatives.
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
