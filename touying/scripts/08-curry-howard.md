VERBATIM · cap 1:45 · Act 1 beat 5 of 6 · rail: CHURCH · CURRY-HOWARD lit

TALKING POINTS
1. Why a compiler can take that deal at all is the last piece
2. Church and Turing 1936 — the ancestor of the Function you wrote in Java 8
3. 1969 — Howard writes down what Curry noticed
4. Proposition = type · proof = program · running = simplifying the proof
5. Lambek: the same structure again in category theory
6. Your program is the construction; its type says what you proved
7. The compiler checks the one against the other — proofs compose, via types
8. Every value has a type — declared, inferred, or carried at runtime
9. So the program is a construction either way; what changes is who checks it
9. A → B is an implication: give me an A, I always give you a B
10. Null, exceptions, non-termination — so the signature is not always truthful
11. But Java already has A → B throws C
12. One move, repeated: what the code only promises, the type states

VERBATIM

"Why a compiler can take that deal at all is the last piece.

Church and Turing made computation formal in nineteen thirty-six, and Church's
typed lambda calculus is the direct ancestor of the Function you wrote in Java 8.

In nineteen sixty-nine Howard wrote down what Curry had noticed twenty years
earlier, and it is what I promised you at the start. A proposition corresponds to
a type; a proof of it corresponds to a program of that type; and running the
program is simplifying the proof. Lambek later found the same structure in
category theory — proofs, programs and mathematical structures as three descriptions of one
thing. That's honestly still one of the most mind-blowing and beautiful facts I know.

So: your program is the construction. Its type says what you constructed a proof
of. The compiler checks the one against the other - and proofs, like programs,
compose, with the types governing how. None of that depends on writing the types
down: declared, inferred, or carried at runtime, every value has one. What
changes is whether anything checks it before you run.

There is a caveat, and it is the reason this talk has stages. A function type from A to B is an
implication: give me an A and I will always give you a B. In Java that is not
quite truthful, because of nullability, exceptions, and loops that never return —
so what you can actually get is the second line. And notice that Java already
gives you one way to close part of that gap: A arrow B throws C.

And a good part of our climb from here is that one move, repeated: something the
code only promises becomes something the type states."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

BEATS — delivery aid; the script is below

- Join from the crisis: why a compiler can take that deal at all.
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
- The caveat, as a map and not an apology. **Java does construct a proof** — of a
  weaker proposition than its arrows suggest:
  › null in every reference type, exceptions that escape any signature, loops
    that never return
  › so `A → B` really proves: given an A, a B **or** null **or** a throw **or**
    nothing, ever. True, and nearly free
  › the slide also carries the machinery point — say it only if you have room
- Pivot into the rest of the talk: everything we climb buys a correspondence a
  little closer to exact.

TWO THINGS TO CHECK IN MB'S 18 AUG REWRITE (not changed — flagged)

**1. The C13 triple had lost its third member in speech — MERGED, flagged (C11).**
The line *the compiler is the machine that checks the one against the other* had
been replaced by *proofs — and programs — compose via types and how they relate*.
The composition point is new and good and earns its place beside Lambek, but the
slide's block still shows three rows, and the C13 note below says this is the one
place in the talk where the equivocation is closed **out loud**: mouth naming two,
screen naming three. Both now survive in one sentence, for eight words:

    The compiler checks the one against the other — and proofs, like programs,
    compose, with the types governing how.

This also cleared a `monotone` error: the compose sentence was the fourth short
declarative in a row. Revert freely — but if the compiler clause goes again, the
C13 check at the bottom of this file needs revising to match.

**2. The caveat's framing moved, and `A0-title` should be checked against it.**
It now says a signature `A → B` *is not necessarily truthful*. The earlier
framing was that Java *proves a weaker proposition* — `A ⇒ (B ∨ null ∨ throw ∨
⊥)` — which is what Part 13/A used to reconcile the caveat with slide 1's claim
that a program which type-checks *is* a proof. Both are defensible and MB's is
crisper for the room. Worth one deliberate decision: under *not truthful*, slide
1's promise is discharged by the ladder rather than by the caveat, so the caveat
no longer does that job on its own.

DELIVERY
Three-line equation table on the left, the C13 block on the right; the caveat
across the bottom.

The caveat paragraph is the one to rehearse. Delivered as an apology it makes the
thesis look naive; delivered as a map it is the spine of the talk. The last line
is the pivot into Act 2 — do not drop it.

THE CAVEAT, AND WHY IT IS NOW A POSITIVE CLAIM (MB, 18 Aug — supersedes F2)

Two earlier versions of this caveat were wrong in the same direction. The first
implied that logic cannot capture imperative programs (Part 10/F2). The second
said *a Java method from A to B does not prove that A implies B*, which sounds
like no proof happens at all — and that contradicts the promise on `A0-title`.

The correct statement, and it is stronger than either:

> **Java does construct a proof. It proves a weaker proposition than its arrows
> suggest.** Under the standard monadic reading of an impure language, a method
> written `A → B` really has type `A → T(B)`, where `T` carries nullability,
> thrown exceptions and non-termination. So what it proves is
> `A ⇒ (B ∨ null ∨ throw ∨ ⊥)` — a genuine proposition, genuinely constructed,
> and nearly free, because the diverging term already inhabits it.

Everything the ladder does is cut that disjunction down. Stage 3 removes a case
from a different disjunction; Stage 4 removes wrong-order transitions; Stage 5
adds the predicate; Stage 6's totality checker is what finally lets you delete
`⊥` and make the arrow mean what it says. **Read this way, the caveat is the
spine of the talk rather than a retraction of slide 1**, and slide 1 needs no
hedging.

WHAT THE MACHINERY POINT IS FOR (on the slide; speak it only if there is room)
The measure of how much an impure language is doing silently is what a pure one
needs in order to say the same thing. Moggi's monads give you state and
exceptions. Full non-local control needs first-class continuations, and Griffin
showed in 1990 that `call/cc` has the type of Peirce's law — that is, the step
from intuitionistic to **classical** logic. So the implicit content of imperative
code is not nothing; it is an unstated, unchecked effect structure that costs
real logical strength to make explicit.

PRECISION, IF THIS IS CHALLENGED
- Java's `try`/`catch` is upward-only and one-shot, so it is modelled by a monad
  (`A + E`) and stays intuitionistic. **Do not claim Java's exceptions are
  classical logic.** The `call/cc` ↔ Peirce's law result is about *first-class*
  continuations, which Java does not have. "In the limit" carries that.
- Unrestricted general recursion makes the naive reading inconsistent: `Y` gives
  an inhabitant of every type. That is why the honest word for the proposition
  Java proves is *nearly free* rather than merely *weak*.
- In a genuinely untyped language the proposition is not fixed by the language;
  it is fixed by whatever discipline you retrofit. Saying *the proposition is
  still there, just never checked* is fair for a talk — if pressed, concede that
  what is there is the intended contract, and the typing judgment is the thing
  that would make it precise.

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
