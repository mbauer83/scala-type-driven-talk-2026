// Clock: 35:30–36:00
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#theory-slide(
  eyebrow: eyebrow(style: "accent")[→ DEMO 7 in `Main.idr`],
  [MLTT Rules Running as Programs],
  grid(
    columns: (1fr, 1fr),
    gutter: sz(36pt),
    stack(
      dir: ttb,
      spacing: sz(20pt),
      stack(
        dir: ttb,
        spacing: sz(10pt),
        text(size: sz(22pt), weight: 500, font: mono-font, fill: pal.fg-dim)[Π-elimination],
        block(
          fill: pal.bg-warm,
          radius: 3pt,
          inset: sz(16pt),
          width: 100%,
          stack(
            dir: ttb,
            spacing: sz(8pt),
            text(size: sz(26pt), font: mono-font)[f : (Πx:A). B(x)    a : A],
            line(length: 100%, stroke: 0.5pt + pal.rule-strong),
            text(size: sz(26pt), font: mono-font)[f(a) : B(a)],
          ),
        ),
      ),
      code-pane(filename: "PaymentRules.idr", language: "haskell")[
```haskell
protocolFromSnapshot : RiskSnapshot -> SessionType

-- Apply to a runtime risk snapshot
-- → get a SessionType whose shape depends on snap.level
-- openSession then accepts that value and returns
-- channel endpoints indexed by it
openSession (protocolFromSnapshot snapshot n c)
```
      ],
    ),
    stack(
      dir: ttb,
      spacing: sz(20pt),
      stack(
        dir: ttb,
        spacing: sz(10pt),
        text(size: sz(22pt), weight: 500, font: mono-font, fill: pal.fg-dim)[Σ-introduction],
        block(
          fill: pal.bg-warm,
          radius: 3pt,
          inset: sz(16pt),
          width: 100%,
          stack(
            dir: ttb,
            spacing: sz(8pt),
            text(size: sz(26pt), font: mono-font)[a : A     b : B(a)],
            line(length: 100%, stroke: 0.5pt + pal.rule-strong),
            text(size: sz(26pt), font: mono-font)[(a, b) : (Σx:A). B(x)],
          ),
        ),
      ),
      code-pane(filename: "PaymentDomain.idr", language: "haskell")[
```haskell
assessOrder : Order n c
           -> (lvl ** Assessment lvl n c)
-- Returns a pair: the risk level lvl,
-- AND an assessment whose TYPE includes lvl.
-- Value and proof, bundled.
```
      ],
    ),
  ),
  footer: ["The formal rules from the theory section are what Idris 2's type checker runs at every call site. The slide earlier was the specification; this code is its implementation."],
)

#speaker-note[
"Here's where the theory section pays off. The Π and Σ rules we looked at briefly in Slide 12 — in the abstract, as formation rules — reappear here as ordinary Idris functions, in the same payment domain we've been building through all seven stages. `protocolFromSnapshot snapshot` applies Π-elimination: the return type is a SessionType whose shape is computed from the runtime risk level in the snapshot. `assessOrder order` is Σ-introduction: a dependent pair where the risk level is both the returned value and an index into the type of the second component. Slide 12 was the specification; these functions are its implementation."

→ Navigate to key signatures (60 sec):
Open `07-idris2-payment/src/PaymentRules.idr` and navigate to `protocolFromSnapshot`. Show its signature: `RiskSnapshot -> SessionType`. Say: "SessionType is a first-class type in Idris — this function returns one, computed from a runtime risk snapshot." Show the case-split on `snap.level` that selects the protocol shape. Say: "That case-split is what makes the return type dependent on the runtime value."

Then `assessOrder` in `PaymentDomain.idr`: show `(lvl : RiskLevel ** Assessment lvl n c)` — say: "That `**` is Idris's Σ-type syntax. `lvl` is both the returned value and the index into the type of the second component."

`authorize`: show `Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c` — say: "The assessment carries the risk level as a type parameter; the required approval is indexed by the same level. `AutoApproved` cannot satisfy `Approval MediumRisk`."

Finally, `Main.idr` `runOrderScenario`: show the `openSession (protocolFromSnapshot snapshot n c)` line — say: "One call. `protocolFromSnapshot` computes the protocol type from the snapshot; `openSession` indexes the channel endpoints by it. The same result in Scala requires selecting from a pre-declared ADT — here it's derived directly from the runtime value."

→ Show linearity in action (45 sec):
Open `PaymentChannel.idr` and point at the `(1 _ : Session ...)` annotations on `send`, `receive`, `finish`. Say: "Read that `1` as 'consume exactly once' — the multiplicity annotation from Idris 2's Quantitative Type Theory." Then demonstrate: open `Main.idr`, comment out a `finish done` line in one handler, save, run `idris2 --build payment.ipkg`. Show the error: "There are 0 uses of linear name done. Suggestion: linearly bounded variables must be used exactly once." Say: "Forgetting to close the channel is no longer a code-review issue. It's a compile error." Restore the file.

→ Run the demo (90 sec):
Run `./build/exec/paymentdemo` in the terminal (pre-built). Show demo1 (low-risk), demo2 (medium-risk with 3DS), demo3 (high-risk with manual review). Say: "No bridge ADT. The protocol is a value computed from the runtime snapshot and passed directly to `openSession`. The compiler tracks the result."

→ Show the duality involution proof (30 sec):
Navigate to `dualInvolution : (p : SessionType) -> dual (dual p) = p` in `PaymentSessionTypes.idr`. Say: "Scala's `summon[Dual[P] =:= ...]` checks one concrete protocol. This proves the same property for every protocol by structural induction. A proof rather than a test."

→ Show what's still open (30 sec):
Briefly show the `believe_me` casts in `PaymentChannel.idr`. Say: "Honest gap: serialisation relies on unsafe casts. A type mismatch in the transport layer is still a runtime error. The remaining frontier."

→ Return to slides.
]
