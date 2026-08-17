// Clock: 35:30–36:00
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#let rule-card(title, top, bot) = stack(
  dir: ttb,
  spacing: sz(8pt),
  text(size: sz(22pt), weight: 500, font: mono-font, fill: pal.fg-dim)[#title],
  block(
    fill: pal.bg-warm,
    radius: 3pt,
    inset: (x: sz(20pt), y: sz(14pt)),
    width: 100%,
    align(center)[
      #set text(size: sz(24pt), font: mono-font)
      #stack(
        dir: ttb,
        spacing: sz(6pt),
        text[#top],
        line(length: 100%, stroke: 0.5pt + pal.rule-strong),
        text[#bot],
      )
    ],
  ),
)

#theory-slide(
  eyebrow: eyebrow(style: "accent")[→ DEMO 6 in `Main.idr`],
  [MLTT Rules Running as Programs],
  stack(
    dir: ttb,
    spacing: sz(22pt),
    // ── Row 1: Π-elimination ────────────────────────────────────────────
    grid(
      columns: (sz(380pt), 1fr),
      gutter: sz(28pt),
      align: (left + horizon, left + horizon),
      rule-card([Π-elimination], [f : (Πx:A). B(x)    a : A], [f(a) : B(a)]),
      code-pane(filename: "PaymentRules.idr", language: "haskell")[
```haskell
protocolFromSnapshot : RiskSnapshot -> SessionType

-- Apply to a runtime risk snapshot ⇒ get a SessionType whose
-- shape depends on snap.level. openSession then accepts that
-- value and returns channel endpoints indexed by it.
openSession (protocolFromSnapshot snapshot n c)
```
      ],
    ),
    // ── Row 2: Σ-introduction ───────────────────────────────────────────
    grid(
      columns: (sz(380pt), 1fr),
      gutter: sz(28pt),
      align: (left + horizon, left + horizon),
      rule-card([Σ-introduction], [a : A     b : B(a)], [(a, b) : (Σx:A). B(x)]),
      code-pane(filename: "PaymentDomain.idr", language: "haskell")[
```haskell
assessOrder : Order n c -> (lvl ** Assessment lvl n c)

-- Returns a pair: the risk level lvl, AND an assessment whose
-- TYPE includes lvl. Value and proof, bundled together.
```
      ],
    ),
  ),
  footer: ["The formal rules from the theory section are what Idris 2's type checker runs at every call site. The slide earlier was the specification; this code is its implementation."],
)

#speaker-note[
"The Π and Σ rules from Slide 13 reappear here as ordinary Idris functions in the same payment domain. `protocolFromSnapshot snapshot` is Π-elimination: the return type is a `SessionType` computed from the runtime risk level in the snapshot. `assessOrder order` is Σ-introduction: a dependent pair bundling the risk level with an assessment whose type depends on that level. The rules were the specification; these functions are the implementation."

→ Navigate to key signatures (60 sec):
Open `06-idris2-payment/src/PaymentRules.idr` and navigate to `protocolFromSnapshot`. Show its signature: `RiskSnapshot -> SessionType`. Say: "SessionType is a first-class type in Idris — this function returns one, computed from a runtime risk snapshot." Show the case-split on `snap.level` that selects the protocol shape. Say: "That case-split is what makes the return type dependent on the runtime value."

Then `assessOrder` in `PaymentDomain.idr`: show `(lvl : RiskLevel ** Assessment lvl n c)` — say: "That `**` is Idris's Σ-type syntax. `lvl` is both the returned value and the index into the type of the second component."

`authorize`: show `Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c` — say: "The assessment carries the risk level as a type parameter; the required approval is indexed by the same level. `AutoApproved` cannot satisfy `Approval MediumRisk`."

Finally, `Main.idr` `runOrderScenario`: show the `openSession (protocolFromSnapshot snapshot n c)` line — say: "One call. `protocolFromSnapshot` computes the protocol type from the snapshot; `openSession` indexes the channel endpoints by it. The same result in Scala requires selecting from a pre-declared ADT — here it's derived directly from the runtime value."

→ Show linearity in action (45 sec):
Open `PaymentChannel.idr` and point at the `(1 _ : Session ...)` annotations on `send`, `receive`, `finish`. Say: "Read that `1` as 'consume exactly once' — the multiplicity annotation from Idris 2's Quantitative Type Theory." Then demonstrate: open `Main.idr`, comment out a `finish done` line in one handler, save, run `idris2 --build payment.ipkg`. Show the error: "There are 0 uses of linear name done. Suggestion: linearly bounded variables must be used exactly once." Say: "Forgetting to close the channel is no longer a code-review issue. It's a compile error." Restore the file.

→ Run the demo (60 sec):
Run `./build/exec/paymentdemo` in the terminal (pre-built). Show demo1 (low-risk), demo2 (medium-risk with 3DS visible in the log), demo3 (high-risk with manual review). The logs are annotated — focus on the outcome lines for demos 1–3, then point at the demo7 summary output: `protocolFromSnapshot snapshot : SessionType`. Say: "No bridge ADT. The protocol is a value computed from the runtime snapshot and passed directly to `openSession`. The compiler tracks the result."

→ Duality involution (10 sec, no navigation):
Say: "There's also `dualInvolution` in `PaymentSessionTypes.idr` — it proves `dual (dual p) = p` for every protocol by structural induction. Scala's `summon[Dual[P] =:= ...]` checks one concrete instance; Idris proves the general case."

→ Still open (10 sec, no navigation):
Say: "One honest gap: serialisation in `PaymentChannel.idr` relies on `believe_me` casts. A type mismatch in the transport layer is still a runtime error. The remaining frontier."

→ Return to slides.
]
