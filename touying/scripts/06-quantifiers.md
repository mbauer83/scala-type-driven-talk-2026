A1-quantifiers · cap 1:05 · Act 1 beat 3 of 6 · rail: FREGE lit

THE OBJECTION THIS SLIDE EXISTS TO ANSWER (MB, 18 Aug)

> Any function is already a universal quantification over all instances of its
> input types. Why would generics make a difference?

That is correct, and the two previous versions of this slide had no answer to it.
`assessRisk(Order order)` **is** `∀ o : Order` — a non-dependent function type is
Π with the binder unused in the result. Presenting ∀ as the new thing, or a
generic as "∀ again", tells the people in the room who can follow exactly nothing,
and they are the ones whose trust the primer needs.

The real answer, and the spine of the slide: **a generic moves the variable up a
level.** It ranges over *types*, not values — second-order quantification, which
is Girard and Reynolds' System F rather than Frege. And the reason that buys
something is parametricity: the body cannot inspect `T`, so one implementation
discharges the claim for every `T` at once.

WHY IT MATTERS LATER
This puts two rungs on the board and leaves the third visible:

  over values, result fixed     a function type              (here)
  over types                    a generic                    (here)
  over values, result computed  Π — the result type may
                                mention the value            (`A1-above`)

That third line is the whole of dependent types, and `A1-above` can now land it
as the next step in a sequence the room has already climbed twice, instead of as
a new notation out of nowhere.

BEATS

- Frege 1879: a hole in a proposition, then a binder to close it.
- You already write it — every signature is one. `assessRisk` over every `Order`.
  › a function type is a for-all whose body never mentions what it bound
- The move: a generic quantifies over TYPES.
  › the body never gets to ask what `T` is
  › so one implementation covers every `T`, including ones nobody has written
  › one clause only on the flip side: with nothing known about `T` you can pass
    it around and nothing else, which is why real generics say
    `T extends something`. **Show the syntax, do not say "a bound"** — see the
    note below.
- Margin, one line only: ∃ exists, Java cannot write it honestly, it returns.

UNBOUNDED GENERICS ARE BARELY USEFUL, AND THE SLIDE HAS TO ADMIT IT (MB, 18 Aug)

`∀T. T → T` has exactly one inhabitant, and `∀T` in general lets you move a `T`
around and do nothing else to it. Claiming that a generic *proves something for
every type* without that qualification is a C2 overclaim, and the people most
likely to notice are the ones the primer needs.

The honest framing, and it costs one clause: **the body's inability to inspect
`T` is both the payoff and the limit.** It is what makes one implementation cover
every `T`, and it is why with nothing known about `T` you can pass it around and
do nothing else to it.

**Say `<T extends Comparable<T>>`, not "a bound".** (MB, 18 Aug.) The room is
mixed — the term is standard Java and a good part of the audience still will not
place it, especially arriving mid-sentence alongside quantification, where they
would have to resolve two unfamiliar things at once. Show the syntax they can
read and say what it does. The name is optional and costs more than it earns.
For your own reference: a bound is the quantifier's domain, restricting `∀T` to
`∀T <: X`.

**Budget discipline: one clause spoken, one sentence on the slide, no more.**
The full version belongs in Q&A, not in a 45-minute talk. What follows is for
Q&A only:
- Parametricity (Reynolds 1983, Wadler's *Theorems for Free*) turns the limit
  into a guarantee: from `∀T. List<T> -> List<T>` alone you can derive that the
  result is a permutation of a sublist of the input. Java weakens this with
  `null`, reflection and unchecked casts, so say *nearly* if you say it at all.
- Bounded quantification is `∀T <: X` — System F-sub, Cardelli and Wegner 1985.
  It is also the honest ancestor of Scala's refinements in Act 4, so if this
  question comes up early, it is a gift: the answer is *Act 4*.

MUST LAND
Generics are quantification one level up. If the room takes away *a generic is a
for-all over types, and the body's inability to look at T is what makes it worth
anything*, the beat worked.

C13 CHECK (Part 8)
The SIGNATURE is the quantified proposition; the BODY is the construction that
proves it. Both halves are said in the last sentence of the second beat. Never
compress to *generics are ∀* — that is the equivocation, and it drops the half
that does the work.

WHY THE JAVA IS WHAT IT IS
`assessRisk` is in the payment domain and is the method Bob's bug lives next to,
so the first rung costs the room no context. `Validator.check` is not domain
code, and that is deliberate: the point of the second rung is that `T` is *any*
type, so a generic over the payment domain would undercut it. It is real code
from Stage 2 and it is instantiated on the domain three lines later
(`PaymentService.java:76-84`, `Validator<Integer> positiveQuantity`) — say so if
anyone looks sceptical about where it comes from.

FACTS — grepped, not remembered (C1)
- `public static RiskDecision assessRisk(Order order)` —
  `03-java-function-types-sealed/PaymentService.java:20`
- `static <T> Validator<T> check(Predicate<T> predicate, String errorMessage)` —
  `02-java5-generics/Validator.java:21`
- Frege, *Begriffsschrift*, 1879, introduces quantification proper. Aristotle's
  four categorical forms quantify, but the quantifier is not an operator you can
  move, nest or negate.
- Second-order quantification over types: Girard 1972, Reynolds 1974 (System F).
  Do not name them on the slide; know them if asked.
- Do NOT offer `Optional<Proof>` as ∃. `Optional[T]` is `T ∨ 1`, a disjunction.
  The Curry-Howard reading of ∃ is a dependent pair — Σ on `A1-above`, and the
  thing Stage 6 shows Java cannot express. This is the one deliberate exception
  to Act 1's pair-every-concept-with-Java rule (Part 10/E) and it is
  load-bearing.

VERBATIM

"Frege's move, in eighteen seventy-nine: put a hole in a proposition, then bind
it. For all o of type Order, and then something true of every one of them.

You write that already. Every signature you write is a universal quantifier —
assessRisk takes an Order and returns a risk decision, for every order there will
ever be, including the ones placed tonight. A function type is a
for-all whose body never mentions the thing it bound.

A generic moves that variable up a level. It stops ranging over values and starts
ranging over types, and the power is in what the body cannot do: it never gets to
ask what T is. One
implementation covers all of them, including types nobody has written yet. For
the same reason it can only pass a T around and never call anything on it, which
is why in practice you nearly always write T extends something.

There is a second quantifier, there-exists. Java has no honest way to write that
one, and it is the first thing we need at the top of the climb."
