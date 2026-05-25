// Clock: Q&A — Dependent types live demo
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": code-pane

#light-slide(
  eyebrow: eyebrow([Appendix A3 · Live Demo], style: "accent"),
  [Live: Dependent Typing Catching a Mismatch],
  stack(
    dir: ttb,
    spacing: sz(14pt),
    code-pane(filename: "Main.idr", language: "haskell", highlights: ((2, "hl"), (8, "hl-good")))[
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
      #text(fill: pal.bad, weight: 500, size: sz(24pt))[Live edit:] #text(size: sz(24pt), fill: pal.fg-dim)[swap `serverLowRisk` → `serverMediumRisk` in the LowRisk arm:]
    ],
    raw(lang: "text",
      "Error: While processing right hand side of runScenarioFor.\n" +
      "When unifying:\n" +
      "    Assessment LowRisk n c\n" +
      "and:\n" +
      "    Assessment MediumRisk n c\n" +
      "Mismatch between: LowRisk and MediumRisk."
    ),
    [
      #set text(size: sz(24pt), fill: pal.fg-dim)
      Both indices — assessment type and session type — must agree. Restore with ⌘Z.
    ],
  ),
)

#speaker-note[
"Here's how to see the dependent typing doing real work. In `runScenarioFor`, when we pattern-match `snap = MkRiskSnapshot LowRisk _ _ _ refund _`, two things reduce: the assessment type becomes `Assessment LowRisk n c`, and the session-end type becomes `Session (dual (lowRiskProtocol refund n c))`. Both carry the LowRisk index. If I now try to hand them to `serverMediumRisk`, the compiler refuses — the indices don't line up. Watch: swap `serverLowRisk` for `serverMediumRisk` in the LowRisk arm; run `idris2 --build payment.ipkg`. The error reports the first mismatch it finds — between `Assessment LowRisk` and `Assessment MediumRisk`. Restore the original — the program compiles again. Same code shape, different runtime risk classification, different type. That's the third lambda-cube axis firing at every dispatch."
]
