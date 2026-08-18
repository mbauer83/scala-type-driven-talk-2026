A3-stage3 · cap 1:45 · Act 3 beat 3 of 8

TALKING POINTS
1. The shape from Boole is now a language feature — Java 17 ships both
2. The compiler refuses the program until every variant has a branch
3. Do not re-tell Bob here. He was named one slide ago and returns in the demo
4. Same construction in the RETURN type: Result is Ok or Err
5. A function that can fail says so, and you cannot skip the failure
6. There is no .get() to reach past it
7. Scala spells it Either, Rust spells it Result. One construction, three names
8. Something the code only promised is now something the type states

VERBATIM

"The shape you saw at Boole is a language feature here. Records give you
products, sealed interfaces give you sums, Java seventeen ships both — and once
the risk decision is sealed, the compiler refuses the whole program until every
variant has a branch of its own.

The same construction turns up again in the return type. Result is a sealed interface
over Ok and Err, so a function that can fail says so in its signature, and you
cannot get at the value without handling the failure — there is no dot-get to
skip past it. Scala spells this Either and Rust spells it Result; it is one
construction with three names.

Which is the move I promised you: something the code only promised has become
something the type states."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHAT CHANGED FROM v1
v1 opened with a `Function<String,Integer>` / `map` / inference pane. Real Stage 3
content, and a distraction here — Part 3 gives this slide records + sealed = sums
of products, Bob's code beside the sealed version, and `Result<T>` as the same
rule again. Lambdas get a clause in the eyebrow and nothing more.

BOB IS NOT RE-TOLD HERE (MB, 18 Aug)
He was on `A0-incidents`, his line is on `A3-stage12`'s bottom strip, the demo
deletes his case and the payoff slide resolves him. A fifth appearance here — his
`if` beside the sealed switch — was redundant, and the ADT shape itself was
already taught at Boole. So this slide is short on the sum and spends its budget
on **`Result`**, which is the one genuinely new thing in Stage 3.

That rebalance is the point: Act 3 was giving roughly seven minutes to
exhaustiveness and five to everything else.

FACTS — grepped (C1)
- The switch is `03-java-function-types-sealed/PaymentService.java:58-68`,
  qualified case labels verbatim (`case RiskDecision.Low l ->`), bodies elided.
- `Result` is `03-java-function-types-sealed/Result.java:6-12`; `Ok` carries
  `value`, `Err` carries `message` — both verbatim.
- `RiskDecision` is the same sealed interface the room met on `A1-connectives`;
  do not re-read the declaration, they have seen it.

JOIN
Backwards: Gentzen's elimination rule, sixty seconds old. Forwards: Demo 1 breaks
it live. Do not pre-empt the demo by describing the error message.
