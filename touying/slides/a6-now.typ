#import "../theme.typ": *
#import "../components.typ": *

#let claim(head, body) = stack(
  dir: ttb,
    spacing: sz(16pt),
  text(size: sz(33pt), weight: 600, fill: pal.fg)[#head],
  block[
    #set text(size: sz(28pt), fill: pal.fg-dim)
    #set par(leading: 0.5em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Why the arithmetic is changing]),
  body-gap: sz(28pt),
  [What agentic software development changes],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(72pt),
      row-gutter: sz(46pt),
      claim([A type is a hard constraint.],
            [It holds at every use, from every author, on every build, and it
             does not care whether a person or a model wrote it. A test only ever
             covers the case somebody thought of.]),
      claim([A type signature is the clearest statement of intent.],
            [It says what a thing is for, in a form a model can read, and it
             cannot drift away from the code, because it is checked every time.
             The comment above it can.]),
            grid.cell(colspan: 2)[
        #grid(
          columns: (1fr, auto),
          column-gutter: sz(60pt),
          align: (left + horizon, left + horizon),
          claim([A loop measured in seconds, answering by name.],
                [The error says which type it wanted and where — precise enough
                 for a model to act on. A red test says only that something is
                 wrong.]),
          block(fill: pal.bg-warm, radius: sz(6pt),
                inset: (x: sz(24pt), y: sz(18pt)))[
            #set text(size: sz(23pt), font: mono-font, fill: pal.fg-dim)
            Found:    Approval[LowRisk] \
            Required: Approval[MediumRisk]
          ],
        )
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/29-now.md")
]
