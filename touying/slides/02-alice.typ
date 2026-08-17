// Clock: 0:30–2:45 · cap 2:15 · VERBATIM SCRIPT
//
// v2: the four incidents collapse from four slides into one, and the buggy
// code is gone. Each story keeps exactly one concrete human detail; the code
// itself reappears later, at the stage where it stops compiling.
#import "../theme.typ": *
#import "../components.typ": *

#let incident(name, system, story, cost) = grid(
  columns: (sz(280pt), 1fr, sz(330pt)),
  column-gutter: sz(44pt),
  align: (left + top, left + top, right + top),
  // `stack` rather than markup: markup paragraphs add their own leading, which
  // floated the label away from its name and into the next row.
  stack(
    dir: ttb,
    spacing: sz(4pt),
    text(size: sz(44pt), weight: 400, fill: pal.fg)[#name],
    text(font: mono-font, size: sz(19pt), fill: pal.fg-faint)[#system],
  ),
  [
    #set text(size: sz(27pt), fill: pal.fg-dim)
    #set par(leading: 0.45em)
    #story
  ],
  [
    #set text(font: mono-font, size: sz(23pt), fill: pal.bad)
    #set par(leading: 0.45em)
    #cost
  ],
)

#let divider = line(length: 100%, stroke: 0.5pt + pal.rule)

// Domain frame. The four stories use payment vocabulary — authorize, capture,
// risk tier, refund — and without this strip the audience meets the jargon
// before it has anywhere to put it. The full domain slide comes later; this is
// just the shape.
#let domain-strip = block(
  width: 100%,
  fill: pal.bg-warm,
  inset: (x: sz(28pt), y: sz(18pt)),
  radius: sz(4pt),
)[
  #set text(size: sz(24pt), fill: pal.fg-dim)
  One scenario carries the whole talk — one everybody here has used, even if you
  have never built one:
  #v(sz(12pt))
  #align(center)[
    #set text(font: mono-font, size: sz(26pt), fill: pal.fg)
    order #h(sz(14pt)) → #h(sz(14pt)) assess risk #h(sz(14pt)) → #h(sz(14pt))
    authorize #h(sz(14pt)) → #h(sz(14pt)) capture
    #h(sz(14pt)) #text(fill: pal.fg-faint)[( → refund )]
  ]
]

#light-slide(
  eyebrow: eyebrow([Alice · Bob · Charlie · Danielle], style: "bad"),
  body-gap: sz(44pt),
  [Four Bugs That Compiled],
  block(width: 100%, height: 100%, stack(
    dir: ttb,
    spacing: sz(30pt),
    domain-strip,
    incident(
      [Alice], [reconciliation · node.js],
      [Order-line amounts arrive from a CSV export as _strings_ and are summed with `+`,
       which on two strings concatenates. Single-line orders hide it — `reduce` over one
       element returns that element.],
      [12-digit daily total\ #text(fill: pal.fg-faint)[survived months of tests]],
    ),
    divider,
    incident(
      [Bob], [fraud & risk · java],
      [A third risk tier is added years after the branch was written.
       `if (risk != HIGH)` was correct for two tiers. Medium falls straight through it.],
      [3DS skipped\ #text(fill: pal.fg-faint)[merchant keeps chargeback liability]],
    ),
    divider,
    incident(
      [Charlie], [refund approval · java],
      [An operator shortcut fetches a refund by id and executes it
       without checking its state. Only _approved_ refunds may reach the payment rail.],
      [unreviewed refund paid\ #text(fill: pal.fg-faint)[3 h of log archaeology]],
    ),
    divider,
    incident(
      [Danielle], [checkout ↔ payment service · scala],
      [The payment side adds a challenge step above a value threshold, and the checkout
       client is never updated to read it. Each side is correct against its own contract.],
      [checkout hangs on\ high-value orders\ #text(fill: pal.fg-faint)[3 weeks before anyone hit it]],
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
