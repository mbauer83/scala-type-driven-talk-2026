A3-stage3 · cap 1:25 · Act 3 beat 2 of 8 · ends on the refusal 13-gentzen names

TALKING POINTS
1. You have seen BOTH halves already — the shapes at Boole, the refusal at the
   colours slide. Here they meet, and on Bob's actual type
2. What is NEW is the return type
3. Do not re-tell Bob here. He was named one slide ago and returns in the demo
4. Same construction in the RETURN type: Ok or Err — and the error side is a
   type too, PaymentError, itself a sum of products
5. A function that can fail says so, and you cannot skip the failure
6. throws does that too — but it leaves by a different door, jumping somewhere
   you cannot see from here. Result hands the failure back as a value
7. Scala: Either[E, T]. Rust: Result<T, E>
8. THE MOVE: something the code only promised is something the type states
9. End on the refusal — the next slide opens on the word

VERBATIM

"You have already seen both halves of this. The shapes were on the Boole slide,
as a sealed interface over three records; the compiler refusing a switch with a
case missing was two slides ago, on the colours. Here they meet, and they meet on
Bob's actual type — the risk decision his branch got wrong is the sealed one now,
and the switch will not build without all three.

What is new here is the return type. `Result` is sealed over `Ok` and `Err`, so a
function that can fail says so, and you cannot reach the value without dealing
with it. And the failure is typed too: a `PaymentError` you switch on. Java's `throws` puts failure in the signature too, but it leaves by a different
door: control jumps somewhere you cannot see, where `Result` hands it back to the
caller as a value.

That is the move this evening describes: what the code only promised, the type
now states — backed by a compiler that refuses to build until
every variant has a branch."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

BOB IS NOT RE-TOLD HERE
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
- `Result<T, E>` is `03-java-function-types-sealed/Result.java`, and the error
  channel `PaymentError` is `PaymentError.java` in the same directory — four
  variants, one of which carries the capture id. `Ok` carries
  `value`, `Err` carries `message` — both verbatim.
- `RiskDecision` is the same sealed interface the room met on `A1-connectives`;
  do not re-read the declaration, they have seen it.

JOIN
Backwards: Gentzen's elimination rule, sixty seconds old. Forwards: Demo 1 breaks
it live. Do not pre-empt the demo by describing the error message.
