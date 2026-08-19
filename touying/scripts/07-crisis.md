VERBATIM · cap 1:35 · Act 1 beat 4 of 6 · rail: RUSSELL · HILBERT · GÖDEL lit

TALKING POINTS
1. Bridge from Frege: he spent twenty years building that notation into a
   foundation — then Russell broke it, with a shape you already know
2. The barber shaves everyone who does not shave themselves. Who shaves him?
2. 1901 — Russell finds the same shape at the foundations; writes to Frege
3. The set of all sets that do not contain themselves — does it contain itself?
4. Either answer contradicts: naive set theory is inconsistent
5. And set theory was the ground under arithmetic, analysis and proof itself
6. Russell's repair: every statement gets a level, one above what it mentions
7. The set of all sets would sit one level above itself — no legal way to write it
8. He called the levels TYPES
9. Hilbert wanted three: consistent, complete, mechanically checkable
10. Gödel 1931 — big enough for arithmetic means giving up complete
11. The programme narrowed into proof theory. That is your compiler's deal

VERBATIM

"Frege spent the next twenty years turning that notation into a foundation for
the whole of mathematics. Then Russell broke it, with a shape you probably know.

The barber shaves everyone who does not shave themselves. So who shaves the
barber? Russell found that shape at the foundations of mathematics in
nineteen-oh-one, and broke Frege's life's work with one question: the set of all
sets that do not contain themselves — does it contain itself?

Either answer contradicts, so naive set theory is inconsistent — and set theory
was the ground being laid under arithmetic, analysis and proof itself. 
Russell's own repair is the reason we are all here tonight.
He gave every statement a level, defined by what it talks about: always one above
whatever it mentions. A statement trying to define the set of all sets 
that do not contain themselves would have to sit one level above itself, 
so it has no level at all — there is no legal way to write it. 
He called the levels types, and every sealed interface any of you writes 
is downstream of a man trying to stop logic and mathematics from eating themselves.

If the ground can crack like that, what is a formal system still good for?
Hilbert wanted three things at once: no contradictions, everything true provable,
and mechanically checkable. Gödel showed in nineteen thirty-one that any consistent
system big enough for arithmetic gives up the middle one. That did not kill the
programme; it narrowed it into proof theory, and giving up completeness is the
deal your compiler takes every morning."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

BEATS — delivery aid; the script is below

- Open on the barber, because it is the same shape and nobody needs set theory
  to feel it.
  › the barber shaves everyone who does not shave themselves
  › so who shaves the barber?
- Then the real one. 1901: Russell finds that shape at the foundations, writes to
  Frege, and breaks his life's work with one question.
  › the set of all sets that do not contain themselves — does it contain itself?
- **Name the damage before offering the repair.** Naive set theory is
  inconsistent, and set theory was the ground under arithmetic, analysis and
  proof itself.
- Russell's own repair, and the reason we are here: everything sits on a level,
  and nothing may talk about things on its own level.
  › he called the levels types — that is where the word comes from
- Every sealed interface in this room is downstream of a man trying to stop
  mathematics from eating itself.
- **Motivate Hilbert, then list.** If the ground can crack like that, the
  question is what a formal system is still good for.
  › consistent · complete · checkable by machine
- Gödel 1931: a consistent system big enough for arithmetic gives up complete.
- Hand off: that is the deal your compiler takes every morning. (A2-promises
  cashes it out; do not do that work here.)

DELIVERY
The barber earns its place by costing eight seconds and removing the need for
anyone to parse set-builder notation while you are still talking. Say it, let the
room answer it in their heads, then put the real one up.

Russell's letter is a story; tell it as one. The three requirements are a list and
should sound like a list — that is what `A2-promises` then cashes out for type
checkers, so do not explain them here beyond the one-clause gloss.

PART 10 — WHAT CHANGED AND WHY
1. The headline was *the crisis, and where the word comes from*, which is a
   forward reference nobody can resolve until they have read to the middle of the
   slide. It names the word now.
2. The slide posed the paradox and jumped to the repair. What was missing is the
   sentence in between: the contradiction destroys naive set theory, and set
   theory was the foundation being built for mathematics and for proof theory.
   Without it the audience gets a riddle and a fix with no stakes.
3. Hilbert's three requirements arrived unmotivated. They stay — they are what
   `A2-promises` cashes out — but the column now leads with the question they
   answer.
4. The barber goes above the set-theoretic form as the intuitive version.

C13 CHECK (Part 8)
This beat is about the *checker*, not about programs or types individually. It
establishes what a mechanical check can promise at all, which is why it sits
before Curry-Howard rather than after.

FACTS
- Russell's letter to Frege, June 1902, about the 1893 Grundgesetze; the paradox
  is usually dated 1901 when he found it. Saying he found it in 1901 and wrote to
  Frege compresses those; if precision is challenged, the paradox is 1901 and the
  letter is 1902.
- The barber is Russell's own popularisation of the paradox (1919). It is not a
  perfect analogue — the honest resolution is that no such barber exists, whereas
  the set version breaks the theory that permits the set. If challenged, concede
  it: the barber is the intuition, the set is the problem.
- Type theory as the repair: Russell's ramified theory, 1908.
- **Hilbert's third was decidability / mechanical checkability, NOT soundness.**
  An earlier version of this slide listed consistent / sound / complete and said
  Gödel showed you cannot have all three. Both halves were wrong. Hilbert's
  programme wanted consistency, completeness and an effective decision procedure;
  and *sound + complete + consistent* is not a triple Gödel ruled out — plain
  propositional logic has all three, and a logic-literate attendee will say so.
  The theorem needs its hypotheses: **any consistent, effectively axiomatized
  system strong enough for arithmetic is incomplete.** »Big enough for arithmetic«
  is the spoken form of that, and it is the shortest honest one.
  Note this also puts *mechanical checkability* on the slide, which is what
  Part 6b/D2 (ii) asked `A1-crisis` to carry in the first place.
- Gödel's first incompleteness theorem, 1931.
- Do NOT say type-checker conservatism is Gödel — that is Rice's theorem and
  decidability, and it belongs to `A2-promises`. See Part 8/C8.

WORDING (18 Aug)
The barber shaves everyone who does not shave **themselves**. An earlier pass
changed that to *himself*; MB had chosen the neutral form deliberately and it
goes back. The flowery half of the damage line — *the young business of putting
proof itself on a formal footing* — is cut to *proof itself*, which says the same
thing at a third of the length and does not sound like it is enjoying itself.
