# Idris 2 Payment Demo

This directory is the target end-state for the staged payment examples described in:

- [PAYMENT_TALK_PLAN.md](/home/mb/workspace/scala-type-driven-talk/PAYMENT_TALK_PLAN.md)
- [TALK_NARRATIVE_GUIDE.md](/home/mb/workspace/scala-type-driven-talk/TALK_NARRATIVE_GUIDE.md)

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
