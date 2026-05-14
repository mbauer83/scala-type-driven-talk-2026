# 06-scala3-payment

This is the Scala 3 ceiling in the payment progression.

## Purpose

It demonstrates:

- session protocols as types,
- match-type duality,
- path-dependent protocol evidence,
- refined boundary values with `iron`,
- approval witnesses indexed by risk,
- typed authorization/capture/refund transitions,
- a policy DSL with multiple interpretations,
- runtime selection among a fixed set of pre-declared protocol variants.

## Run

```bash
sbt run
sbt compile
```

## Why this stage matters

Scala 3 can make many invalid payment programs unrepresentable, but it still needs a runtime-to-type bridge:

- the protocol menu is fixed ahead of time,
- runtime risk analysis selects among those variants,
- the protocol type itself is not computed directly from a runtime order value.

That remaining bridge is exactly what `07-idris2-payment/` removes.
