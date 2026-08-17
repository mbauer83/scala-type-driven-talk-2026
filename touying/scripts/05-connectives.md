A1-connectives · cap 1:20 · Act 1 beat 2 of 6 · rail: LEIBNIZ · BOOLE · FREGE

BEATS — delivery aid; the script is below

- Aristotle gave us shapes; nobody could **calculate** with them for two thousand years.
- Leibniz wanted to. Sketched a notation for every concept plus a calculus to grind
  through it, so two people who disagreed could sit down and settle it.
  › say it exactly: let us calculate
  › he never built it — and he invented binary along the way, which buys him some
    patience from this room
- Boole, 1847: logic becomes algebra. **This is the moment inference becomes
  symbol-pushing a machine could do.**
- Frege, 1879: the notation that could actually carry mathematics.
- Then the turn to their code — one connective at a time:
  › `∨` — a risk decision is exactly one of low, medium, high.
    **The sealed interface is the proposition.**
  › the match — the compiler refuses until every case is handled.
    **That is the proof step.**
  › `∧` — a record, every field present at once. The other connective.
- Land it: sums and products. Most domain modelling you will ever do.

MUST LAND — and this is the whole slide

The two halves, named as two different things. Point at the interface, say
*proposition*. Point at the match, say *proof step*. If the room leaves thinking
*sum types are nice*, the beat failed. If they leave thinking *the declaration is a
claim and the match is what discharges it*, it worked.

C13 CHECK (Part 8) — highest-risk slide in the deck for the equivocation
A Java developer hearing *you already write logic* thinks `if (a && b)`. Nothing
here is about boolean conditions. The sealed interface *declares* `A ∨ B`; the
exhaustive match *eliminates* it. Say which is which out loud.

FACTS
- Boole, *The Mathematical Analysis of Logic*, 1847.
- Frege, *Begriffsschrift*, 1879.
- Leibniz: *characteristica universalis*, *calculus ratiocinator*, *calculemus*.
  Named in a clause, on the rail, no beat of his own (Part 6b/D2). He is here
  because of **mechanisation** — the first to say inference could be carried out
  by a machine, which is what makes the checker in this talk more than a metaphor.
- Java on the slide is extracted verbatim from
  `03-java-function-types-sealed/RiskDecision.java:9-13` — all three records,
  `permits` on one line, records as nested members. See Part 8/C1.

VERBATIM

"Aristotle gave us shapes. What nobody had for two thousand years afterwards was
a way to calculate with them. Leibniz wanted one badly enough to sketch it — a
notation for every concept, and a calculus of reasoning to grind through it, so
that two people who disagreed could sit down and say, let us calculate. He never
built it. He also invented binary along the way, which I think buys him some
patience from this room.

Boole delivered the first working piece in eighteen forty-seven by turning logic
into algebra, and that is the moment inference becomes something a machine could
do. Frege, thirty years later, built the notation that could actually carry
mathematics.

Here is what came out of it, and you write it already. When you declare that a
risk decision is exactly one of low, medium or high, you have written a
disjunction — the sealed interface is the proposition. When you then match on it
and the compiler refuses until every case is handled, that is the proof step: you
cannot use a disjunction without covering every side of it. And a record, where
every field is present at once, is the other connective — a conjunction.

Sums and products. Most domain modelling you will ever do is those two."
