// Clock: Q&A — Dependent types live demo
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": code-pane

#light-slide(
  eyebrow: eyebrow([Appendix A3 · Live Demo], style: "accent"),
  [Live: dependent typing catching a mismatch],
  // The pane, the cue and the error block are one unit and they overflowed the
  // page: the error block's background stopped after its first line and the rest
  // spilled onto the page. Pull the whole stack up under the title.
  body-gap: sz(34pt),
  stack(
    dir: ttb,
    spacing: sz(18pt),
    code-pane(filename: "Main.idr", language: "haskell",
              code-size: 20pt,
              highlights: ((2, "hl"), (8, "hl-good")))[
```haskell
runScenarioFor refundRequested order
    (MkRiskSnapshot LowRisk _ _ _ refund _) clientEnd serverEnd = do
  let assessment : Assessment LowRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverLowRisk refund assessment serverEnd)
           (clientLowRisk refund refundRequested order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot MediumRisk _ _ _ refund _) clientEnd serverEnd = do
  let assessment : Assessment MediumRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverMediumRisk refund assessment serverEnd)
           (clientMediumRisk refund refundRequested order clientEnd)
  pure ()
```
    ],
    [
      #text(fill: pal.bad, weight: 500, size: sz(22pt))[Live edit:] #text(size: sz(22pt), fill: pal.fg-dim)[ swap `serverLowRisk` → `serverMediumRisk` in the LowRisk arm — the compiler reports:]
    ],
    block(width: 100%, fill: pal.bg-dark-2, radius: sz(6pt), inset: (x: sz(20pt), y: sz(14pt)))[
      #set text(font: mono-font, size: sz(18pt), fill: pal.fg-dark)
      #set par(leading: 0.35em)
      Error: While processing right hand side of runScenarioFor. \
      #h(1em) When unifying #text(fill: pal.bad)[Assessment LowRisk n c] and #text(fill: pal.bad)[Assessment MediumRisk n c] \
      #h(1em) Mismatch between: LowRisk and MediumRisk.
    ],
  ),
)

#speaker-note[
"Here's how to see the dependent typing doing real work. In `runScenarioFor`, when we pattern-match `snap = MkRiskSnapshot LowRisk _ _ _ refund _`, two things reduce: the assessment type becomes `Assessment LowRisk n c`, and the session-end type becomes `Session (dual (lowRiskProtocol refund n c))`. Both carry the LowRisk index. If I now try to hand them to `serverMediumRisk`, the compiler refuses — the indices don't line up. Watch: swap `serverLowRisk` for `serverMediumRisk` in the LowRisk arm; run `idris2 --build payment.ipkg`. The error reports the first mismatch it finds — between `Assessment LowRisk` and `Assessment MediumRisk`. Restore the original — the program compiles again. Same code shape, different runtime risk classification, different type. That's the third lambda-cube axis firing at every dispatch."
]
