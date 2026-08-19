// A6-now · cap 1:00 · Act 6 beat 2 of 4 · NEW
//
// MB, 19 Aug: the value of types as hard constraints, as clear signals of
// intent, and as a fast feedback loop was not landing forcefully enough at the
// end. It was sixty words at the tail of A6-cost, spoken over a four-row cost
// table the room was still reading.
//
// MB again, same day: an earlier version of this slide never named agentic
// software development once, and hedged with "whoever wrote the line". This is
// the one slide whose whole purpose is that argument. Name it. And the old
// headline — "when code arrives faster than anyone can read it" — implied
// nobody reviews, which is untrue and insulting to this room; the real claim is
// volume and iteration speed.
//
// Three claims, MB's own and in his order, one block each. Part 3 merged v1's
// 32-agentic into the cost slide; that merge is partly undone here, flagged in
// scripts/29-now.md. +0:35 across Act 6; nothing was shaved to pay for it.
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
        // Two across, then one: three narrow columns made the type small and the
    // claims cramped, and these are the practical argument (MB, 19 Aug).
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(72pt),
      row-gutter: sz(46pt),
      claim([A hard constraint.],
            [It holds on every line, from every author, on every build, and it
             does not care whether a person or a model wrote it. A test only ever
             covers the case somebody thought of.]),
      claim([The clearest statement of intent.],
            [A signature says what a thing is for, in a form a model can read,
             and it cannot drift away from the code, because it is checked every
             time. The comment above it can.]),
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
