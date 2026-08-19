// A5-mltt · cap 1:45 · Act 5 beat 1 of 3 · MERGE of v1 28-stage6-bridge + 29-mltt-running
//
// This slide pays off three of the four rows A1-above put on the wall at minute
// nine, with the SAME code fragments the primer showed, beside the real
// signatures they came from:
//
//   Π  Approval : RiskLevel -> Type              a type indexed by a runtime value
//   Σ  (lvl : RiskLevel ** Assessment lvl n c)   a value paired with a proof
//   1  (1 _ : Session p) -> ...                  a binding used exactly once
//   ⇄  Send[Order, Receive[RiskSnapshot, ...]]   ALREADY PAID OFF at A4-sessions
//
// So the row order here is Π, Σ, 1 — the primer's order, minus the one already
// spent. `1` is set up and NOT fired; Demo 4 fires it.
//
// v1's 29-mltt-running is gone: it re-taught the Π and Σ inference rules as
// rule-cards, which Act 1 already did, carried 315 words against no cap, and
// its note was a nine-item IDE runbook.
//
// GREPPED (rule 9). protocolFromSnapshot takes THREE parameters —
// PaymentRules.idr:212-214; the one-argument story is protocolDerivedFrom (:224)
// and takes an Order, so it is not a substitute. openSession is
// PaymentChannel.idr:73, the call site Main.idr:277, assessOrder
// PaymentDomain.idr:255, Approval PaymentDomain.idr:264, finish
// PaymentChannel.idr:146.
//
// KEEP `: RiskLevel` IN THE DEPENDENT PAIR. Dropping it is legal Idris sugar
// and it hides the index type, which is the entire point of the Σ row.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

// The language change gets a filled chip rather than the 21px grey eyebrow every
// other slide carries. MB, 18 Aug: nothing made it prominent that the talk had
// moved language. This and A4-opens are the only two slides that use it, because
// they are the only two places the syntax on the wall changes — stages 1 to 4
// are all Java. Two dark stage-opener slides were built for this and cut again;
// scripts/20-stage5.md records why.
#let lang-chip(lang, rest) = {
  box(fill: pal.accent, inset: (x: sz(14pt), y: sz(8pt)), radius: sz(4pt))[
    #text(font: mono-font, size: sz(26pt), weight: 700, fill: pal.bg, tracking: 0.08em)[#upper(lang)]
  ]
  h(sz(18pt))
  text(font: mono-font, size: sz(26pt), weight: 500, fill: pal.fg-dim, tracking: 0.02em)[#upper(rest)]
}

#let row(sym, gloss, body) = grid(
  columns: (sz(52pt), 1fr),
  column-gutter: sz(20pt),
  align: (center + top, left + top),
  text(size: sz(38pt), weight: 300, fill: pal.accent)[#sym],
  stack(
    dir: ttb,
    spacing: sz(16pt),
  text(size: sz(22pt), fill: pal.fg-dim)[#gloss],
    body,
  ),
)

#light-slide(
  eyebrow: lang-chip([idris 2], [stage 6 · two of the four, running]),
  body-gap: sz(20pt),
  [The protocol is the argument],
  stack(
    dir: ttb,
    spacing: sz(38pt),
    row([Π], [a type indexed by a runtime value #h(sz(10pt)) #text(fill: pal.fg-faint)[`L1` / `LPair` are linear plumbing — watch `p` cross from left to right]],
      code-pane(filename: "PaymentRules.idr · PaymentChannel.idr · Main.idr",
                language: "haskell", code-size: 19pt, pad-y: 12pt,
                highlights: ((1, "hl-good"), (6, "hl-good")))[
```haskell
data Session : SessionType -> Type      -- a TYPE, indexed by a VALUE

protocolFromSnapshot : (snap : RiskSnapshot) -> (n : Nat) -> (c : Currency)
                    -> SessionType      -- an ordinary function, ordinary value

openSession : (p : SessionType) -> L1 IO (LPair (Session p) (Session (dual p)))

-- one expression, at the call site:
(clientEnd # serverEnd) <- openSession (protocolFromSnapshot snapshot n c)
```
      ],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(44pt),
      align: (left + top, left + top),
      row([Σ], [a value paired with a proof about that value #h(sz(10pt)) #text(fill: pal.fg-faint)[PaymentDomain.idr]],
        block(width: 100%, fill: pal.bg-dark-2, radius: sz(6pt),
              height: sz(108pt), inset: (x: sz(18pt), y: sz(16pt)))[
          #show raw: set text(font: mono-font, size: sz(18pt), fill: pal.fg-dark)
          #raw(block: true,
            "assessOrder : Order n c\n  -> (lvl : RiskLevel ** Assessment lvl n c)")
        ],
      ),
      row([1], [a binding that must be used exactly once #h(sz(10pt)) #text(fill: pal.fg-faint)[PaymentChannel.idr]],
        block(width: 100%, fill: pal.bg-dark-2, radius: sz(6pt),
              height: sz(108pt), inset: (x: sz(18pt), y: sz(16pt)))[
          #show raw: set text(font: mono-font, size: sz(18pt), fill: pal.fg-dark)
          #raw(block: true,
            "finish : (1 _ : Session End) -> L IO ()")
        ],
      ),
    ),
  ),
)

#speaker-note[
#read("../scripts/25-mltt.md")
]
