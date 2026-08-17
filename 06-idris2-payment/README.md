# 07-idris2-payment

This directory is the target end-state for the staged payment examples described in:

- [PRESENTATION_SLIDE_PLAN.md](../PRESENTATION_SLIDE_PLAN.md)

## Purpose

This is the most expressive version of the payment story in the repository.

It is meant to demonstrate:

- refined boundary validation for order construction,
- exact line-count tracking with `Vect n`,
- runtime risk classification from order facts,
- a policy DSL with multiple interpretations,
- protocol derivation from runtime values,
- approval witnesses indexed by risk level,
- typestate transitions for authorization, capture, and refund,
- audit trail accumulation inside typed state transitions,
- duality as a theorem over session types.

## Modules

- `PaymentSessionTypes.idr`
  The session-type algebra, duality function, and duality theorem.

- `PaymentDomain.idr`
  The payment domain, refined constructors, approvals, typestate, and indexed audit trail.

- `PaymentRules.idr`
  The policy DSL, policy interpretations, runtime risk snapshot, and protocol derivation.

- `PaymentChannel.idr`
  A small session-typed runtime used by the demos.

- `Main.idr`
  Demo scenarios for low-risk, medium-risk, and high-risk payment flows plus supporting explanations.

## Idris Syntax Note

One parser gotcha is worth calling out explicitly because the error is misleading:

- avoid reserved identifiers such as `proof` in top-level argument names,
- if a declaration suddenly reports a layout or parse error after an innocent rename, check Idris syntax rules before chasing elaboration ghosts,
- start with the official Idris 2 documentation portal: <https://idris2.readthedocs.io/>
- for parser/keyword edge cases, the compiler source in the official Idris repository is often the most reliable reference: <https://github.com/idris-lang/Idris2>

## Stable Business Scenarios

The directory is organized around these stable scenarios:

- low-risk card order,
- medium-risk card order requiring 3DS,
- high-risk invoice order requiring manual review,
- invalid boundary inputs such as zero quantity or empty order.

These scenarios should be preserved as the earlier-language examples are derived from this one.

## Intended Talk Payoff

This example is where the opening incident stories should terminate:

- premature capture becomes unrepresentable through typestate,
- skipped 3DS is prevented by deriving the protocol from the runtime risk result,
- invalid refund paths disappear from flows where refund is not permitted,
- audit evidence is carried by the constructed lifecycle states rather than by convention alone.
