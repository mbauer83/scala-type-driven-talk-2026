// A3-stage4 · cap 1:45 · Act 3 beat 6 of 8 · REWORK of v1 22-stage4
//
// v1 was a stage-opener with the three-line happy path and a signature card.
// The happy path is not the point: nothing on it can go wrong, so it shows the
// mechanism and hides the argument. Charlie's incident is the argument, and
// Part 3 puts his actual code here, next to the family of signatures that makes
// it unwriteable.
//
// The bridge from Bob is two spoken sentences (Part 4 deleted 21-bridge): Bob's
// bug was a missing CASE; Charlie's is a wrong ORDER, which no sum type catches.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 4 · java · a type parameter that carries no data]),
  body-gap: sz(18pt),
  [The state is in the type],
  stack(
    dir: ttb,
    spacing: sz(24pt),
    grid(
      columns: (1fr, 1.2fr),
      column-gutter: sz(44pt),
      row-gutter: sz(12pt),
      align: (left + top, left + top),

      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.bad)[Charlie's shortcut.] Fetch it, run it.
        Nothing asks what state it was in.
      ],
      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.good)[Each transition demands its input state]
        and hands back the next one.
      ],

      block(width: 100%, fill: pal.bad-bg, radius: sz(6pt),
            inset: (x: sz(24pt), y: sz(20pt)))[
        #show raw: set text(font: mono-font, size: sz(19pt), fill: pal.fg)
        #raw(block: true,
          "var refund = repo.find(id);\ngateway.execute(refund);")
      ],
      signature-card[
        `initiate(Order)` → *`Payment<Initiated>`*\
        `authorizeAuto(`*`Payment<Initiated>`*`)` → *`Payment<Authorized>`*\
        `capture(`*`Payment<Authorized>`*`)` → *`Payment<Captured>`*
      ],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    grid(
      columns: (auto, 1fr),
      column-gutter: sz(40pt),
      align: (left + horizon, left + horizon),
      text(font: mono-font, size: sz(24pt), fill: pal.fg)[
        Payment\<Initiated\> #h(sz(12pt)) ≠ #h(sz(12pt)) Payment\<Authorized\>
      ],
      [
        #set text(size: sz(24pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        Same bytes at runtime — the parameter carries no data at all. What it
        carries is which methods will accept the value, and there is no way to
        reach `Captured` without passing through `Authorized` first.
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/17-stage4.md")
]
