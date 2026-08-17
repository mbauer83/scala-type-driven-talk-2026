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

#light-slide(
  eyebrow: eyebrow([Four Production Incidents], style: "bad"),
  body-gap: sz(44pt),
  [Four Bugs That Compiled],
  block(width: 100%, height: 100%, stack(
    dir: ttb,
    spacing: sz(54pt),
    incident(
      [Alice], [invoicing · node.js],
      [A CSV export hands the import job amounts as _strings_.
       The aggregation sums them with `+` — which, on two strings, concatenates.],
      [€450,015 invoiced\ #text(fill: pal.fg-faint)[should have been €60]],
    ),
    divider,
    incident(
      [Bob], [fraud & risk · java],
      [A third risk tier is added years after the branch was written.
       `if (risk != HIGH)` was correct for two tiers. Medium falls straight through it.],
      [3DS skipped\ #text(fill: pal.fg-faint)[liability shift lost]],
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
      [Danielle], [KYC onboarding · scala],
      [Compliance adds an evidence step on the server. The client doesn't know.
       Both sides are correct against their own contract — the contracts have drifted.],
      [large uploads hang\ #text(fill: pal.fg-faint)[fine for 3 weeks]],
    ),
    v(sz(40pt)),
    align(center)[
      #text(size: sz(40pt), weight: 400, fill: pal.fg)[
        Four bugs. None of them is stupidity.
        #text(weight: 600, fill: pal.accent)[All four compiled.]
      ]
    ],
  )),
)

#speaker-note[
VERBATIM — this is the part that gets stumbled. Short sentences, one breath each.
Let the €450,015 land; it is the only laugh in the talk, so take the beat.

"Alice's morning starts with a Slack message from accounting. An invoice in the
overnight batch came out at four hundred and fifty thousand euros. It should have
been sixty. The CSV parser had handed the code strings. The aggregation used plus.
In JavaScript, plus on two strings concatenates. The job ran clean.

Bob's team added a medium risk tier to the fraud engine. The original code said:
if risk is not high, take the fast path. That was correct when there were two
tiers. Medium fell straight through it. No 3-D Secure. The liability shift went
to the merchant. Nothing broke. It had always compiled.

Charlie owns the refund approval workflow. Requested, under review, approved,
executed. Only approved refunds reach the payment rail. There is an operator
shortcut for emergencies. It fetches a refund by id and executes it, without
checking the state. A refund nobody had reviewed went back to a customer's card.
Three hours of log archaeology to work out why.

Danielle's was the hardest to see. A KYC service — client and server. Compliance
added an evidence step on the server. The client didn't know. Both sides were
correct according to their own contract. The contracts had drifted. Integration
tests covered the common path. It ran fine for three weeks, until somebody
uploaded a large document.

Four bugs. None of them is stupidity. All four compiled."
]
