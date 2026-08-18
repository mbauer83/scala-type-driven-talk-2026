A3-stage3 · cap 1:45 · Act 3 beat 3 of 8

TALKING POINTS
1. Records are products, sealed interfaces are sums — both shipped in Java 17
2. Left: Bob's line, exactly as he wrote it. Correct, for two risk levels
3. Right: the same dispatch once RiskDecision is sealed
4. The compiler refuses the program until every variant has a branch
5. So Bob's bug does not get caught — it stops being a program
6. Same rule again in the return type: Result is Ok or Err
7. A function that can fail says so, and you cannot skip the failure
8. Scala spells it Either, Rust spells it Result. One construction
9. Something the code only promised is now something the type states

VERBATIM

"This is where the shape from the primer arrives in the language. Records give
you products, sealed interfaces give you sums, and Java seventeen ships both.

On the left is Bob's line, as he wrote it — and it was correct, for two risk
levels. On the right is the same dispatch once the risk decision is a sealed
interface, and the difference is that the compiler now refuses the whole program
until every variant has a branch of its own. Notice what that is not: it is not a
better test catching Bob's bug. The bug stops being a program you can write.

The same rule turns up again in the return type. Result is a sealed interface
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

BOB'S LINE IS NARRATIVE, NOT REPOSITORY CODE
`if (risk != HIGH)` appears nowhere in the ladder — it is from `A0-incidents`.
So it is a labelled card with no filename tab, the same treatment and for the
same reason as `RefundRule` on `A1-connectives` (Part 12/R9). Everything in a
pane with a tab is verbatim.

THE LINE THAT HAS TO LAND
*It is not a better test catching Bob's bug — the bug stops being a program.*
That is Device 1's whole argument arriving early, and it is what makes the payoff
slide two beats later a confirmation rather than a claim.

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
