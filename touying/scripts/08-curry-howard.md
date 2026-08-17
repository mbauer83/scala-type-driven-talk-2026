VERBATIM · cap 1:30 · Act 1 beat 5 of 6 · rail: CHURCH · CURRY-HOWARD lit

BEATS — delivery aid; the script is below

- Two more pieces and this closes.
- Church and Turing, 1936, make computation formal. Church's typed lambda
  calculus is the direct ancestor of the Function you wrote in Java 8.
- 1969: Howard writes down what Curry had noticed. The three equations, left
  column of the slide.
  › proposition = type, proof = program, running = simplifying the proof
- Lambek in passing — the same structure turns up a third time in category
  theory. One clause, not a third pillar (Part 10).
- **The C13 block — deliver this one exactly:**
  › your program is the construction; its type says what you constructed a proof
    of; the compiler checks the one against the other
  › true whether or not you write the types down — untyped just means unchecked
- The caveat, as a map and not an apology:
  › the correspondence is with a total, pure calculus, and Java is neither
  › null inhabits every reference type, an exception escapes any signature, a
    loop that never returns inhabits anything at all
  › **and then the correction that matters: effects are not beyond logic.**
    There are calculi for state, exceptions and control. Java is outside *this*
    calculus, which is a statement about where Java sits, not about what logic
    can reach.
- Pivot into the rest of the talk: everything we climb buys a correspondence a
  little closer to exact.

VERBATIM

"Two more pieces and this closes.

Church and Turing, both in nineteen thirty-six, made computation formal, and
Church's typed lambda calculus is the direct ancestor of the
Function-of-String-to-Integer you wrote in Java 8.

In nineteen sixty-nine Howard wrote down what Curry had noticed twenty years
earlier, and it is what I promised you at the start. A proposition corresponds to
a type; a proof of it corresponds to a program of that type; and running the
program is simplifying the proof. Lambek found the same structure a third time in
category theory. Logic, computation and algebra as three descriptions of one
thing — I still find that the most beautiful fact I know.

So: your program is the construction. Its type says what you constructed a proof
of. The compiler is the machine that checks the one against the other. That holds
whether or not you write the types down, because in an untyped language the
proposition is still there and nothing ever checks it.

One honest caveat, and it is the reason this talk has stages. The correspondence
is with a total, pure calculus, and Java is neither: null inhabits every
reference type, an exception escapes any signature, and a loop that never returns
inhabits anything at all. So a Java method from A to B does not yet prove that A
implies B.

Effects are not beyond the reach of logic, though. There are calculi for state,
exceptions and control, and continuations answer to classical reasoning — Java is
simply outside this one. That is the map for the next half hour: everything we
climb buys a correspondence a little closer to exact."

DELIVERY
Three-line equation table on the left, the C13 block on the right; the caveat
across the bottom.

The caveat paragraph is the one to rehearse. Delivered as an apology it makes the
thesis look naive; delivered as a map it is the spine of the talk. The last line
is the pivot into Act 2 — do not drop it.

PART 10/F2 — THE CAVEAT USED TO OVERCLAIM
The earlier wording implied that logic cannot capture imperative, impure
programs. It can. Continuations, monadic translation and effect calculi do
exactly that, and the continuation/classical-logic correspondence is the sharpest
example. The honest limit is **which calculus you are standing in**, not whether
one exists — and stated that way the caveat is a better setup for the ladder,
because each stage is a move toward a calculus that fits. Left as it was, this
was a Part 8/C2 overclaim sitting on the slide that carries the thesis.

C13 CHECK (Part 8)
The three-sentence block — construction / proposition / checker — is the canonical
statement of the distinction and is deliberately verbatim from the standing
correction. It is the single place in the talk where the equivocation is closed
explicitly. Do not paraphrase it on the night.

FACTS
- Church and Turing, 1936, independently; simply-typed lambda calculus 1940.
- Curry noticed the combinatory correspondence from the 1930s-50s; Howard's
  manuscript circulated 1969, published 1980. "Howard wrote down what Curry had
  noticed" is the accurate framing.
- Lambek's correspondence with cartesian closed categories is precise for STLC ↔
  intuitionistic propositional logic ↔ CCC. Extending it to dependent types
  (locally cartesian closed categories) is more delicate — fine to popularise on
  the slide, but know the boundary if it is asked.
- The caveat is discharged as promised on `A0-title`; keep them consistent.
