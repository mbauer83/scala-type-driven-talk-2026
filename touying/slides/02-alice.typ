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
VERBATIM · budget 2:15 · 268 words. Checked facts follow the script.

"Everything tonight runs on one scenario, and it is one every person here has used,
even if you have not built one: ordering something, paying for it, and sometimes
getting your money back. An order is placed, its risk is assessed, the payment is
authorized, and later captured — sometimes refunded afterwards. All four of these
bugs sit somewhere on that spine.

Alice's team owns the job that reconciles the day's order lines. The amounts arrive
from a CSV export as strings, nobody converts them, and JavaScript's plus, given two
strings, concatenates. It survived for months because almost every fixture used a
single-line order, and reduce over one element just hands that element back. The
first two-line order in the test data produced a daily total with twelve digits.

Bob's team added a medium risk tier to their fraud engine. The branch that handled
risk had been written when there were only two tiers, and it said: if risk is not
high, take the fast path. Medium satisfies that condition. So medium-risk orders
took the fast path too and skipped 3-D Secure, which meant the liability for those
chargebacks stayed with the merchant instead of moving to the issuer.

Charlie owns the refund approval workflow. A refund moves from requested, through
review, to approved, and only then out to the payment rail. There is an operator
shortcut for urgent cases, which looks a refund up by id and executes it without
reading its state. One that nobody had reviewed went back to a customer's card.
Charlie spent about three hours in the logs working out how.

Danielle owns the integration between checkout and the payment service. The payment
side added a challenge step for orders above a value threshold, and the checkout
client was never updated to read the extra message. Each side was correct against
its own contract. The tests covered the common path, and the new branch only fires
above the threshold, so it ran for three weeks before anyone hit it.

Every one of those compiled without complaint."

Checked facts and the traps, in case you want to rework any of it:

ALICE — the boundary between untyped input and typed code.
  fact: a CSV export carries order-line amounts in cents; the Node job reads them
        as JS strings and never coerces them.
  fact: `+` on two strings concatenates and throws nothing, so the job exits clean.
  fact: THE REASON IT SURVIVES — `[x].reduce((a,b) => a+b)` returns `x` unchanged,
        so any single-line order looks correct. The bug needs two or more lines,
        which is exactly what the fixtures did not have. This is the load-bearing
        detail; without it the story reads as implausible.
  fact: found in test, not in production. Do not upgrade it to an issued invoice.
  beat: the type system had no way to distinguish a string that looks like a number
        from a number.
  closes: Stage 1. `int` instead of `String` is enough — the cheapest rung on the
        whole ladder, which is the point.

BOB — a branch that was correct when it was written.
  fact: risk tiers were Low and High; the code read `if (risk != HIGH) fastPath()`.
  fact: a Medium tier was added later, and satisfied `!= HIGH`, so it took fastPath.
  fact: Medium-risk card orders are the ones that require 3-D Secure.
  fact: CORRECTION on the v1 note — completing 3DS shifts chargeback liability TO
        THE ISSUER. Skipping it means no shift happens and the MERCHANT keeps the
        liability. The v1 note had this backwards.
  beat: nothing in the language required anyone to revisit that branch.
  closes: Stage 3, sealed types + exhaustive switch.

CHARLIE — a lifecycle that lived in documentation.
  fact: refunds go Requested → UnderReview → Approved → Executed.
  fact: an operator-tooling shortcut fetches by id and executes, without reading state.
  fact: a Requested refund reached the payment rail and posted back to a card.
  fact: ~3 hours of log reading to reconstruct what happened.
  beat: the state machine existed in the wiki and in three developers' heads.
  closes: Stage 4, phantom typestate.

DANIELLE — two correct programs that disagree.
  fact: the integration between checkout and the payment service, in Scala.
  fact: the payment side added a challenge step above a value threshold; the
        checkout client was never updated to read the extra message.
  fact: each side satisfies its own contract; neither is individually wrong.
  fact: tests covered the common path, the branch only fires above the threshold,
        so it ran ~3 weeks before anyone hit it.
  beat: no shared, checkable definition of the conversation existed.
  closes: Stage 5, session types and duality.
  (Was KYC onboarding in v1. Moved inside the payment frame: KYC is jargon not
   everyone in the room shares, it was the only story outside the domain spine, and
   the Scala session-type code models the payment protocol anyway — so v1 had the
   story and the code that closes it describing different systems.)
  (Do NOT rank this one as the-hardest-to-see. Unverifiable, and it reads as filler.)

CLOSING BEAT: all four passed their compiler. That is the hinge into the next slide.
]
