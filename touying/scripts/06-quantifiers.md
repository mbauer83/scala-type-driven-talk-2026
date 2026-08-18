A1-quantifiers · cap 1:05 · Act 1 beat 3 of 6 · rail: FREGE lit

THIRD BUILD (MB, 18 Aug). Three changes, and the reasons matter more than the
wording:

**1. This slide no longer teaches two things.** The program-level / type-level
distinction has moved to `A1-connectives`, where Java first appears, and is made
once for the whole act — *these land one level above the booleans a program works
out while it runs*. Repeating it here as a second teaching job was what made the
slide feel like two slides.

**2. The values rung is a concession, not a rung.** MB's objection stands and has
to be answered — `assessRisk(Order order)` **is** `∀o:Order`, so presenting ∀ as
the new thing tells the room nothing. But answering it costs one clause in the
lede, not half the slide and a code pane of its own.

**3. Generics arrive bounded.** An unbounded `T` is barely useful: with nothing
known about `T` you can pass it around and little else. Showing `<T>` bare and
then adding bounds as a caveat teaches the wrong default, so the first generic
the room sees here is `<T extends Comparable<T>>`.

HOW TO EXPLAIN A BOUND IN ONE BREATH
Do not say *bounded quantification*, and do not draw a lattice. Use the shape the
room already has from `A1-aristotle`:

    ∀ T.  comparable(T) →  ( List<T> → T )

That is a for-all with an **if** inside it — the same form as *all medium-risk
orders need 3DS*. The bound is the *if*: it names which types the claim covers.
Two glosses, one clause each, and then move on:

- **In Java** it is a region of the hierarchy: everything at or below
  `Comparable<T>`. That is the interval reading, said without the word.
- **Without subtyping** the same job is done by a typeclass constraint —
  Haskell's `Ord a =>`, Rust's `T: Ord`, Scala's `using`. Name it, do not teach
  it. It is also the honest ancestor of Act 4's refinements, so if the question
  comes early the answer is *Act 4*.

TWO THINGS THAT WERE WRONG HERE (MB, 18 Aug)

**1. The bound looked like it was doing the wrong job.** The line was *for all T,
if T can be compared, then a list of T gives you back a T* — which reads as
though comparability is what gets an element out of the list. It never named the
function. Naming `max` fixes it and makes the beat much stronger: **`max` cannot
be written at all without the bound**, which is the sharpest possible way to show
that an unbounded `T` buys you almost nothing.

**2. "The first thing we need at the top of the climb" was two errors.** Nobody
knows what *the climb* is — the word appears in exactly one other spoken line, on
`A1-curry-howard`, which comes *two slides later*, and the opening never
announces a Java → Scala → Idris ascent at all. And *the first thing we need* is
a ranking claim with nothing behind it: Stage 6's payoff is led by Π, not Σ. Now
it is just *we come back to it* — which is all the forward reference has to do,
since its only job (Part 10/E) is to stop a listener concluding Java has Σ-types.

**Standing rule from this: no metaphor the talk has not issued.** *The climb*,
*the top*, *the summit*, *the ladder* — every one of them is invisible to the
room until the deck has spent a sentence establishing it, and none of them has.

WHAT IS DELIBERATELY NOT HERE
- **Composition over inheritance.** There is a real connection — a sealed
  interface is the alternative to subtype polymorphism for closed variation — but
  it is a design-principle argument, orthogonal to the logical content, and it
  invites a debate a Java room has strong opinions about. It costs minutes and
  buys nothing the ladder needs. Keep it for Q&A; if pressed, the one-liner is
  *sums close the variation, subtyping leaves it open, and the compiler can only
  check the closed one*.
- **Parametricity by name**, and the System F citation. Q&A only.

BEATS

- Frege 1879: a proposition with a **variable** in it, and a way to say what
  holds for every value that variable could take. **Say "variable", not "a hole
  in a proposition"** — MB, 18 Aug: the room has the first word already.
- You already write it — every signature is one. `assessRisk` over every `Order`.
  › a function type is a for-all whose body never mentions what it bound
- The move: a generic quantifies over TYPES.
  › **name the function.** For all T, if T can be compared, you can pick the
    largest out of a list of T. Saying only *a list of T gives you back a T*
    makes it sound as though comparability is what produces the element
  › the comparing is why the bound is there — without it `max` cannot be written
  › call back to Aristotle: a for-all with an `if` inside it
  › the bound is the `if` — which types the claim covers, and what lets the body
    call `compareTo`
- Margin, one line only: ∃ exists, Java's wildcards are a weak version, the
  strong form comes back later. **No ranking, no "the climb"** — see below.

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

TWO CORRECTIONS FROM THE 18 AUG EXTERNAL REVIEW

**F-03 was a blocker: "Java has no honest way to write ∃" is false.** JLS §4.5.1
treats wildcards as a restricted existential — `List<?>` is `∃T. List<T>`, and a
generics specialist in the room can produce it instantly, at the exact moment the
talk claims its first expressiveness boundary. The narrower claim is the true one
and is also the one Stage 6 actually pays off: Java cannot express a **dependent
pair**, a value handed to you together with evidence *about that value*. Say
wildcards out loud, concede them, then name what is missing.

**F-04: an unbounded `T` is not opaque — it has `Object`'s methods.** `t.equals`,
`t.hashCode`, `t.toString` and `t.getClass` are all available, and `getClass`
hands you the argument's runtime class. So *it never gets to ask what T is* is
too strong: the method gets no runtime handle on `T` itself, which is erased, but
it can still branch on what it was handed. Say *little it can do beyond what
Object offers* — true, checkable, and it keeps the point intact.

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

"Frege's move, in eighteen seventy-nine: let a proposition contain a variable,
then say what holds for every value it could take. You already write that — every
signature does it over the values of its arguments, and assessRisk holds for
every order there will ever be.

A generic moves the variable one level up, from values to types. And look at the
shape it takes: for all T, if T can be compared, then a list of T gives you back
a T. That is a for-all with an if inside it — the same form we started with two
slides ago. The bound is the if. It says which types the claim covers —
here, everything at or below Comparable — and it is what hands compareTo back to
the body, because otherwise there is very little you can do to a T at all.

There is a second quantifier, there-exists. Java's wildcards are a weak version;
the strong one — a value handed to you with evidence about it — is the first
thing we need at the top of the climb."
