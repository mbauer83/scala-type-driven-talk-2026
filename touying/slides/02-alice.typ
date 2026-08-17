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
MB WRITES THE WORDS. Budget 2:15 — about 260 spoken words at 120 wpm, so roughly
65 per incident. Below are the checked facts and the beat each story has to hit.
Nothing here is delivery prose.

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
  (Do NOT rank this one as "the hardest to see" — unverifiable and it reads as filler.)

CLOSING BEAT: all four passed their compiler. That is the hinge into the next slide.
]
