A2-promises · cap 1:25 · Act 2 beat 2 of 2 · VERBATIM

TALKING POINTS
1. Hilbert wanted three things — ask the same three of your compiler
2. Consistent — no well-typed program produces a value of an impossible type
3. Sound — if it compiles the property holds, as far as the hatches let it
4. Complete — every safe program accepted. Given up, on purpose
4b. Colour is an enum of exactly three values — RED, GREEN, BLUE, and no fourth
5. Left: a switch STATEMENT, every case returns. javac: missing return statement
6. Exhaustive, safe, rejected — the approximation, in their own language
7. Right: the same three cases as a switch EXPRESSION. Java 14. It compiles
8. Identical logic. The difference is which construct the checker reasons about
9. Java 14 moved its own line between safe and accepted

VERBATIM

"Hilbert wanted three things of a formal system. Let's see how those translate to compilers.

Consistency - means no program it accepts hands you a value of a type that has no values
— Scala's `Nothing`, say. A logician would say: you cannot derive a falsehood.

Soundness - means if it compiles, what the types claim is true of the values at runtime — as
far as the escape hatches allow, and `null` is the big one.

Completeness - means every safe program gets accepted. That is the one we gave up, on
purpose.

Here is where you feel it. `Colour` is an enum of exactly three values. On the
left, a switch covering all three, every case returning, and javac says: missing
return statement.
Exhaustive, safe, rejected — because a check that has to terminate has to
approximate, and it approximates on the side that says no.

On the right, the same three cases as a switch expression, which Java fourteen
gave exhaustiveness checking. Identical logic, and it compiles. Java moved what
it can safely conclude from the types, which is exactly what this talk is about."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE ANSWER, AND IT IS BETTER THAN THE THEOREM
An exhaustive `switch` statement over an enum, every case returning, is rejected
with *missing return statement*. Every Java developer in the room has hit it and
sworn at it. It is exhaustive, it is safe, and javac says no — the approximation,
in one screen, in their own language.

And the second half is the better half: written as a `switch` **expression**, the
same program compiles, because Java 14 gave switch expressions exhaustiveness
checking over enums and sealed types. **The boundary moved inside their careers.**
That is the talk's thesis demonstrated by javac rather than asserted by me, and
it hands straight to `A6-cost`'s *the tools keep getting cheaper*.

VERIFIED (C1) — javac 21.0.11, actually compiled, not remembered:

    int f(Colour c) { switch (c) { case RED: return 1; case GREEN: return 2;
                                   case BLUE: return 3; } }
    → error: missing return statement

    int g(Colour c) { return switch (c) { case RED -> 1; case GREEN -> 2;
                                          case BLUE -> 3; }; }
    → compiles

FOR Q&A ONLY — none of this is spoken
- **Why the checker approximates at all.** Type checking decides the language's
  own typing judgment, exactly and always; what is undecidable is the property
  you actually wanted — no null dereference, no stuck state — and the judgment is
  a decidable approximation of it. Rice's theorem (1953) is the general statement:
  every non-trivial semantic property of programs is undecidable. Say this only if
  asked, and never as a correction of something nobody said.
- **Other Java incompleteness, if someone wants more.** Definite assignment
  (`int x; for (...) { x = 1; } use(x);` → *might not have been initialized*);
  generic invariance, where a read-only `List<String>` is not a `List<Object>`
  without a wildcard; and erasure blocking overloads on `List<String>` versus
  `List<Integer>`.
- **Array covariance.** `Object[] a = new String[1]; a[0] = 42;` compiles and
  throws `ArrayStoreException` (JLS §10.5). It is a genuinely interesting story —
  the static rule is unsound, so the JVM pays for it on every reference-array
  store — but it is about *soundness*, and putting it on a slide about
  *completeness* is what made this one incoherent. It belongs in Q&A, or on
  `A6-cost` as a cost anecdote.

DO NOT SAY
- **Not Gödel, and not Rice either** — not unprompted. The example does the work.
- **Do not claim the audience feels incompleteness constantly.** They feel this
  one, mildly, and they have learned to write the redundant `default`. The hard
  version arrives when they try to encode a stronger invariant, which is what
  `A6-cost` is for.
