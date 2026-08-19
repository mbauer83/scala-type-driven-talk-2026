A3-gentzen · cap 1:15 · Act 3 beat 3 of 8 · sixty seconds before Demo 1

TALKING POINTS
1. Segue: that refusal has a name and a date
2. Gentzen, 1935: a connective is defined by two rules
2. How you build one, and how you take one apart
3. Building an OR: you must supply an actual A, or an actual B
4. In Java that is new RiskDecision.Medium() — you picked a side
5. Taking one apart: you may conclude X only if X follows from A AND from B
6. Every branch, no exceptions. That is the elimination rule
7. The sealed interface is the introduction rule; the match is the elimination
8. Hold that for sixty seconds — I am about to break it

VERBATIM

"That refusal has a name, and a date. Gerhard Gentzen, nineteen thirty-five: you
define a logical connective by exactly two things — how you build one, and how
you take one apart.

Building an or is the easy half. To assert A or B you have to supply an actual A,
or an actual B — you cannot simply claim that one of them holds. In Java that is
new RiskDecision dot Medium. You picked a side, and you constructed it.

Taking one apart is the half that matters here. Given an A or B, you may conclude
something only if you can conclude it from A and also from B. Every branch, no
exceptions — and that is exactly what your compiler is doing when it refuses a
switch with a case missing.

So the sealed interface is the introduction rule, and the exhaustive match is the
elimination rule. Hold on to that for about sixty seconds, because I am going to
break it."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THIS FILE'S NUMBER IS NOT ITS RUNNING ORDER (MB, 19 Aug)
`13-gentzen.md` runs **after** `14-stage3.md`. The deck is
`19-stage3.typ` -> `10-gentzen-or.typ` -> `a3-demo1.typ`, which is what makes
the handoff work: `14-stage3` ends on *»a compiler that refuses to build until
every variant has a branch«* and this beat opens on *»that refusal has a name«*.
Gentzen also has to sit sixty seconds before Demo 1, and it does.

Both files also carried the wrong beat number until 19 Aug — this one said
*beat 2 of 8* and `14-stage3` said *beat 3 of 8*, the reverse of the deck. The
script filenames are numbered from an earlier plan and were never renumbered;
`scripts/README.md` lists the real running order.

WHY THIS SLIDE IS A THIRD OF WHAT IT WAS
Inherited at 291 words against a 1:15 cap. It was written for Act 1, where it had
to justify its own existence, so it argued constructive versus classical logic,
the law of the excluded middle, and what a witness is. Sitting sixty seconds
before the compile error it explains (P2, the whole reason it moved here) it
needs none of that: state the two rules, map each to Java, and get out of the
way. The excluded-middle material is genuinely interesting and belongs in Q&A.

FOR Q&A ONLY
The introduction rule is the constructive reading of disjunction: no free lunch,
no assumed truths, an explicit witness. Classical logic allows `A ∨ ¬A` with
evidence for neither; Gentzen's natural deduction and a sealed-type exhaustiveness
check both require the construction. That is also the honest reason `¬` was left
off `A1-connectives`.

FACTS
- Gentzen, *Untersuchungen über das logische Schließen*, 1935 — natural
  deduction, and the introduction/elimination discipline.
- `new RiskDecision.Medium()` is real: `RiskDecision.java:12` declares
  `record Medium() implements RiskDecision {}`.
- The diagram is `diagrams/gentzen-or.typ`, unchanged.

JOIN
Backwards: `A3-stage3` ends on *the compiler refuses the program until every
variant has a branch*, and this slide names that refusal. Forwards: Demo 1 is the
very next slide, so *hold on to that for about sixty seconds* is now literally
true — it was not when Gentzen sat two slides earlier, which is why the order
changed (P2 always wanted the rule adjacent to the error it explains).
