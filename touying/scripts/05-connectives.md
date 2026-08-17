A1-connectives · cap 1:20 · Act 1 beat 2 of 6 · rail: LEIBNIZ · BOOLE · FREGE

BEATS — delivery aid; the script is below

- Aristotle's shapes were already checkable — you check a shape by looking at it.
  What nobody had for two thousand years was a way to **calculate** with one.
- Leibniz wanted that. A notation for every concept plus a calculus to grind
  through it, so two people who disagreed could sit down and settle it.
  › say it exactly: let us calculate
  › he never built it — and he invented binary on the way, which buys him some
    patience from this room
- Boole, 1847: logic becomes algebra. **Inference becomes arithmetic** — symbols
  pushed around without asking what they mean.
- Frege, 1879: the notation that could actually carry mathematics.
- Then the turn to their code — one connective at a time:
  › `∨` — a risk decision is exactly one of low, medium, high.
    **The sealed interface is the proposition.**
  › the match — the compiler refuses until every case is handled.
    **That is the proof step.** Both panes are the same `∨`, declared then used.
  › `∧` — each record, every field present at once. The other connective.
- Guard against the equivocation before landing it:
  › none of this is `if (a && b)` — a boolean is worked out while the program
    runs; these shapes are fixed before it runs at all
- Land it: sums and products. Most domain modelling you will ever do.

MUST LAND — and this is the whole slide

The two halves, named as two different things. Point at the interface, say
*proposition*. Point at the match, say *proof step*. If the room leaves thinking
*sum types are nice*, the beat failed. If they leave thinking *the declaration is a
claim and the match is what discharges it*, it worked.

PART 10/F1 — WHAT BOOLE BUYS, AND WHAT HE DOES NOT
An earlier draft of this script said of Boole: *"that is the moment inference
becomes something a machine could do."* That is wrong, and it was wrong in a way
that steals Aristotle's beat. **Mechanical checkability arrives with Aristotle** —
a form can be checked by inspection, which is exactly the sense that matters for
a type checker. The arithmetic turn buys something later and different:
*numerical calculability*, the ability to compute an answer rather than recognise
a shape. Leibniz belongs on the calculable side, with binary. `A1-aristotle` now
carries the checkability half explicitly, so the two do not compete.

C13 CHECK (Part 8) — highest-risk slide in the deck for the equivocation
A Java developer hearing *you already write logic* thinks `if (a && b)`. Nothing
here is about boolean conditions. The sealed interface *declares* `A ∨ B`; the
exhaustive match *eliminates* it; a boolean is neither, it is a value computed at
runtime. The slide now says that in a line of its own — say it out loud too.

LAYOUT NOTE (Part 10)
Both code panes are a disjunction: its declaration and its use. The left column
used to stack `∨` above `∧`, which put `∧` level with the lower pane and let the
layout imply the lower pane was the conjunction. `∧` is now a strip under both
panes, pointing back up at the records, and the `∨` card says explicitly that
both panes are the same connective.

FACTS
- Boole, *The Mathematical Analysis of Logic*, 1847.
- Frege, *Begriffsschrift*, 1879.
- Leibniz: *characteristica universalis*, *calculus ratiocinator*, *calculemus*.
  Named in a clause, on the rail, no beat of his own (Part 6b/D2). He is here
  because he wanted inference *carried out* rather than merely inspected — the
  ambition Boole's algebra is the first working piece of.
- Java on the slide is extracted verbatim from
  `03-java-function-types-sealed/RiskDecision.java:9-13` — all three records,
  `permits` on one line, records as nested members. See Part 8/C1.

VERBATIM

"Aristotle gave us shapes, and a shape you can check by looking at it.
Calculating with one took another two thousand years. Leibniz wanted a notation
for every concept and a calculus to grind through it, so that two people who
disagreed could sit down and say, let us calculate. He never built it, though he
did invent binary on the way.

Boole delivered the first working piece in eighteen forty-seven by turning logic
into algebra, so that inference becomes arithmetic, carried out symbol by symbol.
Frege, thirty years later, built the notation that could carry mathematics.

You write the result already. Declare that a risk decision is exactly one of low,
medium or high and you have written a disjunction — the sealed interface is the
proposition. Match on it, and the compiler refuses until every case is handled,
which is the proof step — a disjunction cannot be used without covering every
side of it. A record, every field present at once, is the other connective.

None of this is if-a-and-b. A boolean is a value your program works out while it
runs; these are the shape of the data, fixed before it runs at all. Sums and
products, and most domain modelling you will ever do is those two."
