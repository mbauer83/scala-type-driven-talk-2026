A3-stage12 · cap 1:15 · Act 3 beat 1 of 8 · MERGE of v1 Stage 1 + Stage 2

TALKING POINTS
1. Back to the floor: Alice's service had no types. Everything here is bought back
2. Stage 1 — a name is a constraint. An Order is not an Authorization
3. The constructor is private; the only way in is the factory
4. And the factory takes the previous step as its argument
5. Stage 2 — generics. You have seen this one already, as for-all
6. Two real wins, and neither of them touched Bob
7. The risk level is a type. Nothing forces you to handle all of it
8. if (risk != HIGH) still compiles — that is the next forty seconds

VERBATIM

"Alice's service had no types at all, so let us buy some back.

Stage one is the oldest idea in the room: give a thing a name, and the name is a
constraint. An Order is not an Authorization, and now the compiler knows it. The
constructor is private, so you cannot fabricate one — the only way in is that
factory, and the factory takes the previous step as its argument. You cannot have
an authorization without having had an order.

Stage two you have already seen, on the Frege slide. Write Validator once, and it
holds for every type it is ever used with.

Two real wins. And neither of them has touched Bob: the risk level is a proper
type, and nothing whatsoever forces you to handle all of it. That line still
compiles."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHY THESE TWO ARE ONE SLIDE
Neither carried a minute alone. Stage 1 is a single idea — a name is a
constraint, and the constructor is private. Stage 2 is one the room met on
`A1-quantifiers` as ∀; showing `Validator<T>` again as though it were new spends
airtime re-teaching. Merged, they are a 1:15 opener that leaves Act 3's real
budget for Stage 3, Stage 4 and the two demos.

THE BOTTOM STRIP IS THE POINT (MB, 18 Aug)
*By the Stage 1 slide we have lost the contrast to Alice's untyped JavaScript.*
Two repairs: `A2-scenario` now states the floor explicitly, and this slide opens
by referring back to it in one clause. Then the strip names what these stages
have **not** bought — Bob's branch, still compiling — so the act opens on tension
rather than on two wins in a row. `A3-gentzen` and `A3-stage3` are the answer.

DO NOT re-explain generics here. One sentence, pointing backwards. If it starts
to feel like a Stage 2 slide, it has already gone wrong.

FACTS — grepped (C1)
- `private Authorization(String orderId, String authCode, int
  authorizedAmountCents, String approvalNote)` and
  `static Authorization from(Order order, String approvalNote)` —
  `01-java-simple-types/Authorization.java:6,17`. The pane elides the field list
  and both bodies with `...`; identifiers and modifiers are verbatim.
- `static <T> Validator<T> check(Predicate<T> predicate, String errorMessage)` —
  `02-java5-generics/Validator.java:21`. Shown with the parameter names
  abbreviated, as on `A1-quantifiers`, so the two slides match.
- Bob's line is `if (risk != HIGH)`, `02-incidents.md`; the real Stage 2 code has
  no exhaustiveness requirement over `RiskDecision`, which is what Stage 3 adds.

LIVE OPTION, if the room is quick
Open `01-java-simple-types/Demo.java` at `gainDemo_SmartConstructors()` and type
`new Authorization(...)` beside the factory call. The squiggle reads
*Authorization() has private access in Authorization*. Ten seconds, and it makes
the private-constructor point without a word. Skip it if Act 1 ran long.
