// A6-now · cap 1:00 · Act 6 beat 2 of 4 · NEW
//
// MB, 19 Aug: the value of types as hard constraints, as dense signals of
// intent, and as a fast feedback loop for iteration was not landing forcefully
// enough at the end. It was sixty words at the tail of A6-cost, spoken over a
// four-row cost table the room was still reading.
//
// Three claims, MB's own and in his order, one block each. Part 3 merged v1's
// 32-agentic into the cost slide; that merge is partly undone here, flagged in
// scripts/29-now.md. +0:35 across Act 6; nothing was shaved to pay for it.
#import "../theme.typ": *
#import "../components.typ": *

#let claim(head, body) = stack(
  dir: ttb,
  spacing: sz(8pt),
  text(size: sz(28pt), weight: 600, fill: pal.fg)[#head],
  block[
    #set text(size: sz(24pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Why the calculation is moving]),
  body-gap: sz(28pt),
  [When code arrives faster than anyone can read it],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: sz(44pt),
      claim([A hard constraint.],
            [The compiler applies it to every line, from every author, on every
             build. It does not get tired at four in the afternoon, and it does
             not care what wrote the diff.]),
      claim([The densest statement of intent.],
            [A signature says what a thing is for, in a form a person and a model
             both read — and it cannot drift away from the code, because it is
             checked every time. The comment above it can.]),
      stack(
        dir: ttb,
        spacing: sz(16pt),
        claim([An answer in seconds, by name.],
              [The error says which type it wanted and where. That is a review
               comment if a person is reading it, and a specification precise
               enough to act on if something else is.]),
        block(width: 100%, fill: pal.bg-warm, radius: sz(6pt),
              inset: (x: sz(20pt), y: sz(14pt)))[
          #set text(size: sz(20pt), font: mono-font, fill: pal.fg-dim)
          Found:    Approval[LowRisk] \
          Required: Approval[MediumRisk]
        ],
      ),
    ),
  ),
)

#speaker-note[
#read("../scripts/29-now.md")
]
