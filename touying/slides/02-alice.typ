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
  eyebrow: eyebrow([Alice · Bob · Charlie · Danielle], style: "bad"),
  body-gap: sz(44pt),
  [Four Bugs That Compiled],
  block(width: 100%, height: 100%, stack(
    dir: ttb,
    spacing: sz(54pt),
    incident(
      [Alice], [invoicing · node.js],
      [A CSV export hands the import job amounts as _strings_.
       The aggregation sums them with `+` — which, on two strings, concatenates.],
      [€450,015 draft invoice\ #text(fill: pal.fg-faint)[caught in staging]],
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
      [Danielle], [KYC onboarding · scala],
      [Compliance adds an evidence step on the server. The client doesn't know.
       Both sides are correct against their own contract — the contracts have drifted.],
      [large uploads hang\ #text(fill: pal.fg-faint)[fine for 3 weeks]],
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

"Alice's morning started with a message from accounting. Overnight, the import job
had drafted an invoice for four hundred and fifty thousand euros, against an order
worth about sixty. The amounts came out of a CSV export as strings, and nobody had
converted them. So the aggregation summed them with plus — and plus, given two
strings, concatenates. The job reported success, and accounting caught the invoice
in staging before the batch went out.

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

Danielle's team runs KYC onboarding, with a client and a server written against the
same contract. Compliance added an evidence step on the server for large payout
limits. The client was never told. Both programs were correct by their own lights,
the tests covered the common path, and the new branch only fires on large uploads —
so it ran for three weeks before anyone hit it.

Every one of those compiled without complaint."

Checked facts and the traps, in case you want to rework any of it:

ALICE — the boundary between untyped input and typed code.
  fact: an internal admin tool exports CSV; the lineTotal column is amounts in cents.
  fact: the Node import job reads those cells as JS strings, never coerced.
  fact: `+` on two strings concatenates and throws nothing, so the job exits clean.
  fact: the run produced a draft invoice in the overnight STAGING batch. Accounting
        spotted it before the batch went out. Nothing reached a customer — say so,
        or the story is not credible.
  beat: the type system had no way to distinguish "a string that looks like a
        number" from a number.
  closes: Stage 1. `int` instead of `String` is enough. This is the cheapest rung
        on the whole ladder, which is the point.

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
  fact: KYC onboarding, client and server, Scala.
  fact: compliance added an evidence step on the server for large payout limits.
  fact: the client was not updated; each side satisfies its own contract.
  fact: integration tests covered the common path; the new branch only triggers on
        large uploads, so it ran ~3 weeks before anyone hit it.
  beat: no shared, checkable definition of the conversation existed.
  closes: Stage 5, session types and duality.
  (Do NOT rank this one as the-hardest-to-see. Unverifiable, and it reads as filler.)

CLOSING BEAT: all four passed their compiler. That is the hinge into the next slide.
]
