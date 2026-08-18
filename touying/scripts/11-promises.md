A2-promises · cap 1:05 · Act 2 beat 3 of 3 · CUES + one scripted landing line

EST-WORDS: 150

TREATMENT
Cues, not a verbatim script (Part 6b/T). The landing line at the bottom should
be exact, because it is the hand-off to `A6-cost`.

BEATS

- Call back to Russell's slide in one clause: Hilbert asked for three things, and
  here they are against the compiler on your laptop.
- Walk the table left to right, one row at a time. Do not read the logic column
  aloud twice — say the checker column and let the logic column sit there.
  › consistent — no well-typed program can inhabit an impossible type
  › sound — if it compiles, the property holds
  › complete — every safe program is accepted, and this one is given up
- **The correction, and say it plainly because someone in the room may know it.**
  Completeness goes for *decidability*, and the theorem is Rice's, not Gödel's.
  › every non-trivial semantic property of programs is undecidable
  › so a checker that always terminates has to approximate
  › and it approximates on the safe side — it rejects programs that were fine
- Then soundness, which is the one people actually trip over: it holds only as
  far as the escape hatches let it.
  › null, unchecked casts, asInstanceOf, believe_me
  › and Java's own hole, which is the honest one to show a Java room
- Read the two lines of the array-store example, then say what happens. Give it a
  beat; it surprises people who have written Java for fifteen years.
- Land on the hand-off.

LANDING LINE — say this one as written

"When the compiler says no, it is usually right, so the missing completeness is
not something you feel on a normal Tuesday. You feel it the first time you try to
encode a stronger invariant — and what that costs is the last question of the
talk."

MUST LAND
That giving up completeness is a *design decision taken on purpose*, in exchange
for a checker that always terminates. Everything else here is support for it.

WHAT NOT TO SAY

- **Not Gödel.** Type-checker conservatism is Rice's theorem and decidability.
  Gödel is the Act 1 beat about what a formal system can promise at all; this is
  a different result and conflating them is a real error (Part 8/C8).
- **Do not claim the audience feels incompleteness daily.** MB's experience is
  that they mostly do not, because when the compiler refuses it is usually
  correct to refuse. The moment it bites is when you reach for a stronger
  invariant, which is exactly the cost this talk asks them to weigh — so the
  claim is not just softer, it is the one that sets up `A6-cost`.

C13 CHECK (Part 8)
The whole slide is about the *checker*. Say what the checker promises about
programs and types; do not slide into talking about what a type "knows".

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
