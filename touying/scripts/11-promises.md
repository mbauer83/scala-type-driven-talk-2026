A2-promises · cap 1:05 · Act 2 beat 3 of 3 · VERBATIM

TALKING POINTS
1. Hilbert's three, asked of the compiler on your laptop
2. Consistent — no well-typed program produces a value of an impossible type
3. Sound — if it compiles, the property holds
4. Complete — every program that is in fact safe is accepted. Given up on purpose
5. Given up for DECIDABILITY, and that is Rice, not Gödel
6. The checker decides its own rules exactly
7. What is undecidable is the property you wanted — never dereferences null
8. So it approximates, on the safe side, and turns down some good programs
9. Soundness holds as far as the hatches let it — null, casts, believe_me
10. Java's arrays are different: the static rule is unsound, the JVM pays
11. Every store into a reference array, checked, for ever
12. You feel the missing completeness when you encode a STRONGER invariant

VERBATIM

"Hilbert's three, asked of the compiler on your laptop. No well-typed program can
produce a value of an impossible type. If it compiles, the property holds. And
every program that is in fact safe gets accepted — that last one we gave up, on
purpose.

We gave it up for decidability, and the theorem there is Rice's, not Gödel's. The
checker decides its own rules exactly. What is undecidable is the property you
actually wanted — this never dereferences null — so a check that always
terminates has to approximate it, on the safe side, turning down some programs
that would have been fine.

Soundness then holds as far as the escape hatches let it. Java's arrays are the
interesting case: the static rule permits this assignment, and the JVM pays for
it instead, checking every store into a reference array, for ever.

When the compiler says no it is usually right, so you feel the missing
completeness only when you try to encode a stronger invariant — and what that
costs is the last question of the talk."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

TREATMENT
Cues, not a verbatim script (Part 6b/T). The landing line at the bottom should
be exact, because it is the hand-off to `A6-cost`.

BEATS

- Call back to Russell's slide in one clause: the same three questions, asked of
  the compiler on your laptop.
- Walk the table left to right, one row at a time. Do not read the logic column
  aloud twice — say the checker column and let the logic column sit there.
  › consistent — no well-typed program can produce a value of an impossible type
  › sound — if it compiles, the property holds
  › complete — every program that is in fact safe is accepted, and this one goes
- **The correction, and say it plainly because someone in the room may know it.**
  Completeness goes for *decidability*, and the theorem is Rice's, not Gödel's.
  › the checker decides its own rules exactly — that part is not the problem
  › what is undecidable is the property you wanted, like *never dereferences null*
  › so a check that always terminates approximates it, on the safe side
- Then soundness, which is the one people actually trip over: it holds only as
  far as the escape hatches let it.
  › null, unchecked casts, asInstanceOf, believe_me — each one a place you told
    the checker to stop looking
- **Then arrays, and frame them correctly.** This is NOT another escape hatch and
  it is NOT Java failing. The static rule permits the assignment; Java makes up
  for it with a mandatory check on every store into a reference array. Read the
  two lines, then say who pays.
- Land on the hand-off.

LANDING LINE — now the closing paragraph of the VERBATIM above.
It was a separate quoted block here, which double-counted it in `make timing`.

MUST LAND
That giving up completeness is a *design decision taken on purpose*, in exchange
for a checker that always terminates. Everything else here is support for it.

WHAT NOT TO SAY

- **Not Gödel.** Type-checker conservatism is Rice's theorem and decidability.
  Gödel is the Act 1 beat about what a formal system can promise at all; this is
  a different result and conflating them is a real error (Part 8/C8).
- **Do not say the checker is undecidable.** It is not: type checking decides the
  language's own typing judgment, exactly and always. The undecidable thing is
  the *property you wanted* — no null dereference, no stuck state — and the
  typing judgment is a decidable approximation of it. Saying *type checking is
  undecidable so it approximates* collapses the two, which is the same
  program/type/checker equivocation the primer exists to prevent (C13).
- **Array covariance is not an escape hatch and Java is not failing here.** The
  static subtyping rule for arrays is unsound; Java's answer was a mandatory
  runtime store check (JLS §10.5) rather than a fix to the rule. Presenting the
  ArrayStoreException as evidence that Java is broken gets it backwards — the
  exception is the enforcement. The honest and more interesting reading is the
  cost: every store into a reference array is checked, in all your code, for
  ever, because one static rule was left unsound. That is the talk's thesis in
  miniature, which is why it earns its place.
- **Do not claim the audience feels incompleteness daily.** MB's experience is
  that they mostly do not, because when the compiler refuses it is usually
  correct to refuse. The moment it bites is when you reach for a stronger
  invariant, which is exactly the cost this talk asks them to weigh — so the
  claim is not just softer, it is the one that sets up `A6-cost`.

C13 CHECK (Part 8)
The whole slide is about the *checker*. Say what the checker promises about
programs and types; do not slide into talking about what a type *knows*.

FACTS
- Rice's theorem, 1953: every non-trivial semantic property of the language a
  Turing machine recognises is undecidable.
- The array-store example is real Java and compiles:
      Object[] arr = new String[1];
      arr[0] = 42;
  Java's covariant arrays are unsound by design, and the check was moved to
  runtime — ArrayStoreException. Generics are invariant precisely because of it.
- Hilbert's programme wanted consistency, completeness and decidability of
  formal systems; the three-word framing on `A1-crisis` compresses that. If
  pressed, the honest statement is that Gödel killed the completeness of
  sufficiently strong systems, and Church and Turing killed the general
  decidability.
