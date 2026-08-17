VERBATIM · cap 1:30 · Act 1 beat 5 of 6 · rail: CHURCH · CURRY-HOWARD lit

"Two more pieces and this closes.

Church and Turing, both in nineteen thirty-six, made computation itself formal,
and Church's typed lambda calculus is the direct ancestor of the
Function-of-String-to-Integer you wrote in Java 8.

Then in nineteen sixty-nine Howard wrote down what Curry had noticed twenty years
earlier, and it is the thing I promised you at the start. A proposition
corresponds to a type. A proof of that proposition corresponds to a program of
that type, and running the program is simplifying the proof. Lambek later added a
third leg — the same structure again, as cartesian closed categories. Logic,
computation and algebra turn out to be three descriptions of one thing, and I
still find that the most beautiful fact I know.

So: your program is the construction. Its type says what you constructed a proof
of. The compiler is the machine that checks the one against the other. That is
true whether or not you write the types down — in an untyped language the
proposition is still there, it is just never checked.

One honest caveat, and it is the reason this talk has stages. The correspondence
is exact for total, pure calculi. Java is neither: null inhabits every reference
type, an exception escapes any signature, and a loop that never returns inhabits
anything at all. So a Java method from A to B does not prove that A implies B.

That is not a disappointment. It is the whole map for the next half hour —
everything we climb buys a correspondence a little closer to exact."

DELIVERY
Three-line equation table on the left, ∨E ≅ exhaustive match on the right; the
existing `curry-howard.typ` layout already does this well and stays.

The caveat paragraph is the one to rehearse. Delivered as an apology it makes the
thesis look naive; delivered as a map it is the spine of the talk. The last line
is the pivot into Act 2 — do not drop it.

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
