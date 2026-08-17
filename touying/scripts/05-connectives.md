VERBATIM · cap 1:20 · Act 1 beat 2 of 6 · rail: LEIBNIZ · BOOLE · FREGE lit

"Aristotle gave us shapes. What nobody had for two thousand years afterwards was
a way to calculate with them. Leibniz wanted one badly enough to sketch it — a
notation for every concept and a calculus of reasoning to grind through it, so
that two people who disagreed could sit down and say, let us calculate. He never
built it, and he also invented binary along the way, which I think buys him some
patience from this room.

Boole delivered the first working piece in eighteen forty-seven, by turning logic
into algebra. And, Frege, thirty years later, built the notation that could
actually carry mathematics.

Here is what came out of it, and you write it already. When you declare that a
risk decision is exactly one of low, medium or high, you have written a
disjunction — the sealed interface is the proposition. When you then match on it
and the compiler refuses until every case is handled, that is the proof step:
you cannot use a disjunction without covering both sides. And a record, where
every field is present at once, is the other connective — a conjunction.

Sums and products. Most domain modelling you will ever do is those two."

DELIVERY
The two-halves point is the one to land: the sealed interface DECLARES, the match
ELIMINATES. Point at each in turn on the slide.

C13 CHECK (Part 8) — this is the highest-risk slide in the deck for the
equivocation. Say explicitly which half is the proposition and which is the proof
step. If the audience leaves thinking "sum types are nice", the beat has failed;
if they leave thinking "the declaration is a claim and the match is what
discharges it", it has worked.

FACTS
- Boole, The Mathematical Analysis of Logic, 1847.
- Frege, Begriffsschrift, 1879.
- Leibniz: characteristica universalis and calculus ratiocinator; "calculemus".
  He is named in a clause and appears on the rail — no beat of his own, per
  Part 6b/D2. The reason he is here at all is mechanisation: he is the first to
  say inference could be carried out by a machine, which is what makes the
  checker in this talk more than a metaphor.
- The Java on the slide is extracted from `03-java-function-types-sealed/
  RiskDecision.java:9-13` — all three records, `permits` on one line. See C1.
