// Clock: 0:30–2:45 · cap 2:15 · VERBATIM SCRIPT
//
// v2: the four incidents collapse from four slides into one, and the buggy
// code is gone. Each story keeps exactly one concrete human detail; the code
// itself reappears later, at the stage where it stops compiling.
#import "../theme.typ": *
#import "../components.typ": *

// Part 10 layout pass. Three complaints, three fixes:
//   · name and scenario tag sat too close — spacing 4pt → 12pt
//   · the orange cost line and its grey qualifier ran together — the qualifier
//     is now its own argument with real vertical separation, not a `\` break
//   · the space above the first row was too big and everything below it too
//     tight — see `body-gap` and the row spacing at the call site
#let incident(name, system, story, cost, qualifier) = grid(
  columns: (sz(330pt), 1fr, sz(360pt)),
  column-gutter: sz(36pt),
  align: (left + top, left + top, right + top),
  // `stack` rather than markup: markup paragraphs add their own leading, which
  // floated the label away from its name and into the next row.
  stack(
    dir: ttb,
    spacing: sz(20pt),
    text(size: sz(44pt), weight: 400, fill: pal.fg)[#name],
    text(font: mono-font, size: sz(19pt), fill: pal.fg-faint)[#system],
  ),
  [
    #set text(size: sz(27pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #story
  ],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    block(width: 100%)[
      #set text(font: mono-font, size: sz(23pt), fill: pal.bad)
      #set par(leading: 0.45em)
      #align(right)[#cost]
    ],
    block(width: 100%)[
      #set text(font: mono-font, size: sz(21pt), fill: pal.fg-faint)
      #set par(leading: 0.45em)
      #align(right)[#qualifier]
    ],
  ),
)

#let divider = line(length: 100%, stroke: 0.5pt + pal.rule)

// Domain frame. The four stories use payment vocabulary — authorize, capture,
// risk tier, refund — and without this strip the audience meets the jargon
// before it has anywhere to put it. The full domain slide comes later; this is
// just the shape.
// Domain frame. The four stories use payment vocabulary — authorize, capture,
// risk tier, refund — and without this the audience meets the jargon before it
// has anywhere to put it (C3).
//
// It used to carry a sentence of introduction. That sentence was MB's own
// spoken framing lifted onto the slide, which is not what slide copy is for,
// and it said "one" three times. The label does the same job in two words and
// gives the four rows the vertical space they were short of.
#let domain-strip = block(
  width: 100%,
  fill: pal.bg-warm,
  inset: (x: sz(28pt), y: sz(16pt)),
  radius: sz(4pt),
)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: sz(40pt),
    align: (left + horizon, center + horizon),
    text(font: mono-font, size: sz(21pt), fill: pal.fg-faint, tracking: 0.06em)[THE FLOW],
    [
      #set text(font: mono-font, size: sz(26pt), fill: pal.fg)
      order #h(sz(14pt)) → #h(sz(14pt)) assess risk #h(sz(14pt)) → #h(sz(14pt))
      authorize #h(sz(14pt)) → #h(sz(14pt)) capture
      #h(sz(14pt)) #text(fill: pal.fg-faint)[( → refund )]
    ],
  )
]

#light-slide(
  eyebrow: eyebrow([Alice · Bob · Charlie · Danielle], style: "bad"),
  body-gap: sz(-26pt),
  [Four bugs that compiled],
  block(width: 100%, height: 100%, stack(
    dir: ttb,
    spacing: sz(34pt),
    domain-strip,
    incident(
      [Alice], [reconciliation · node.js],
      [Order-line amounts arrive from a CSV export as _strings_ and are summed with `+`,
       which on two strings concatenates. Single-line orders hide it — `reduce` over one
       element returns that element.],
      [12-digit daily total],
      [survived months of tests],
    ),
    divider,
    incident(
      [Bob], [fraud & risk · java],
      [A third risk tier is added years after the branch was written.
       `if (risk != HIGH)` was correct for two tiers. Medium falls straight through it.],
      [3DS skipped],
      [merchant keeps chargeback liability],
    ),
    divider,
    incident(
      [Charlie], [refund approval · java],
      [An operator shortcut fetches a refund by id and executes it
       without checking its state. Only _approved_ refunds may reach the payment rail.],
      [unreviewed refund paid],
      [3 h of log archaeology],
    ),
    divider,
    incident(
      [Danielle], [checkout ↔ payment · scala],
      [The payment side adds a challenge step above a value threshold, and the checkout
       client is never updated to read it. Each side is correct against its own contract.],
      [checkout hangs on\ high-value orders],
      [3 weeks before anyone hit it],
    ),
    v(sz(40pt)),
    align(center)[
      #text(size: sz(40pt), weight: 400, fill: pal.fg)[
        Every one of these #text(weight: 600, fill: pal.accent)[compiled without complaint.]
      ]
    ],
  )),
)

#speaker-note[
#read("../scripts/02-incidents.md")
]
