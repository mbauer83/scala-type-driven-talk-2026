# Type-Driven Payments Talk Repo

This repository now treats the **numbered example ladder** as the only canonical code path for the talk.

## Progression

- `00-js-untyped-payment/`
- `01-java14-simple-types/`
- `02-java5-generics/`
- `03-java8-function-pipelines/`
- `04-java17-records-sealed/`
- `05-java-advanced-generics-typestate/`
- `06-scala3-payment/`
- `07-idris2-payment/`

The older root-level Scala booking example and the older unnumbered Idris booking example have been removed so the repo tells one story only: the staged payment progression.

## Talk Docs

- [PAYMENT_TALK_PLAN.md](PAYMENT_TALK_PLAN.md)
- [TALK_NARRATIVE_GUIDE.md](TALK_NARRATIVE_GUIDE.md)

## Current End States

- `06-scala3-payment/` is the Scala 3 ceiling: strong protocol typing, duality, phantom/indexed evidence, refined values, and a runtime bridge through a fixed protocol menu.
- `07-idris2-payment/` is the Idris 2 payoff: `protocolDerivedFrom : Order n c -> SessionType` and `assessOrder : Order n c -> (lvl ** Assessment lvl n c)` let the protocol shape and the required approval witness come from the same runtime order facts.

## Repo Hygiene

- tracked source should live in the numbered directories and top-level talk docs only
- build outputs (`target/`, Idris `build/`, `.class`, `.ttc`, jars) are not part of the source of truth
- if a future example supersedes an older one, remove the older one instead of keeping two parallel stories alive
