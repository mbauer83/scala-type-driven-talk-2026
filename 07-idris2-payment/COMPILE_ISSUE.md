# Idris 2 Compile Issue: Resolved

## Outcome

`idris2 --build payment.ipkg` now succeeds on Idris 2 `0.8.0-214eb4547`, and the
`paymentdemo` executable runs through demos 1–7.

## Actual causes

The original `"Not the end of a block entry"` / `"Couldn't parse declaration"` errors
were misleading. Two separate issues were involved:

1. `proof` was used as a top-level function argument name in `Main.idr`.
   In Idris 2, `proof` is a reserved identifier, so declarations such as
   `finishMediumRiskRefundable assessment proof afterProof = ...`
   were parsed incorrectly and reported as malformed declarations.

2. `commonSettlement` and `postCapture` in `PaymentRules.idr` were `private`.
   That prevented `Main.idr` from normalizing protocol tails like
   `commonSettlement True n c` into the concrete `Receive`/`Send` chain needed by
   the client and server helpers. The result was a cascade of stuck unification
   errors after the parser issue was removed.

## Fixes applied

1. Kept runtime protocol derivation intact:
   - `protocolDerivedFrom : Order n c -> SessionType`
   - `riskSnapshotFor : Order n c -> RiskSnapshot`
   - `assessOrder : Order n c -> (lvl ** Assessment lvl n c)`

2. Indexed the assessment by risk level:
   - `Assessment lvl n c`
   - `authorize : Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c`

   This preserves the point of the example: both the protocol shape and the
   authorization witness are derived from runtime order facts.

3. Renamed the reserved `proof` argument to `threeDSProof`.

4. Made settlement helpers visible for normalization:
   - `public export postCapture`
   - `public export commonSettlement`

5. Restored the server helpers to ordinary `do`-notation so the visible example
   stays readable.

## Where to check next time

When Idris reports a parse or layout error that appears disproportionate to the edit:

- check the official Idris 2 documentation portal first:
  <https://idris2.readthedocs.io/>
- for parser and reserved-word edge cases, check the official compiler source:
  <https://github.com/idris-lang/Idris2>
- in this repository, keep `Main.idr` free of top-level argument names that may
  collide with Idris syntax, especially `proof`

## Why the smaller booking-shaped example compiled more easily

The booking demo only needs runtime values to choose a protocol. The payment demo
also needs runtime values to determine which approval witness is legal:

- `AutoApproved : Approval LowRisk`
- `ThreeDSApproved : ThreeDSProof -> Approval MediumRisk`
- `ReviewerApproved : ManualReviewApproval -> Approval HighRisk`

So the payment example is strictly richer: the session shape and the value-level
evidence both depend on runtime classification.

## Remaining design note

The example now compiles without giving up the talk’s core claim:
runtime order data selects the protocol, and Idris checks the rest of the flow
against that derived protocol and the matching risk witness.
