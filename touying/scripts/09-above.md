A1-above · cap 1:20 · Act 1 beat 6 of 6 · rail: MARTIN-LÖF (+) lit, rail complete

TALKING POINTS
1. A few more steps up, starting with a big one — it changes what a type is ABOUT
2. So far the result type was fixed before you called the function
3. Martin-Löf 1972 — compute it from the argument VALUES
4. A vector carrying its length: three ++ four has type seven
5. Let the vector do the work — do not generalise it out loud
7. Coquand 1988 — kernels of Rocq, Lean, Agda, Idris
8. Glimpse of what is coming: Π · Σ · use-exactly-once · a conversation as a type
9. You will have watched all four run on our payment flow
10. There is a map of this territory; we fill it in as we go

VERBATIM

"There are a few more steps up, starting with a big one that changes what a type can be about.

Everything so far has had the result type completely fixed before you called the function.
Martin-Löf, in nineteen seventy-two, let it be computed from argument values
instead. Picture a vector that carries its own length in its type: concatenate a
vector of three with a vector of four, and the type of the result says seven,
because the compiler did the arithmetic. Coquand added polymorphism in
eighty-eight, and between the two of them you have the kernels of proof assistants 
and programming languages like Rocq, Lean, Agda and Idris.

Here's a glimpse of what's to come: a conversation between two services written
down as one type; a type indexed by a runtime value; a value paired with a proof
about that value - and an instruction that tells the compiler to verify that a
resource is used exactly once.

At the end, you'll have seen what each of those can buy, having watched all four run on our
payment flow. There is a map of this territory, and we fill it in as we go."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

IT IS ALSO THE THIRD RUNG OF A LADDER THE ROOM HAS ALREADY CLIMBED
`A1-quantifiers` puts two rungs on the board. This is the third, and saying so
out loud is what makes the beat land as an arrival rather than as new syntax:

  over values, result fixed      a function type       (A1-quantifiers)
  over types                     a generic             (A1-quantifiers)
  over values, result computed   Π                     (here)

BEATS

- One more step, and it changes what a type can be about.
- Martin-Löf 1972: the result type may be computed from the argument.
  › **let the vector carry it** — three ++ four has type seven, because the
    compiler did the arithmetic. Do not generalise that out loud (see below)
- Coquand 1988 folds that together with polymorphism. Between Martin-Löf and
  Coquand you have the kernels of Rocq, Lean, Agda and Idris — **say »between the
  two of them«, not »that kernel«** (see the correction below).
- The notations, uncovered together. Read the glosses, not the syntax, and
  introduce them by what the shift buys rather than by how many there are.
- The contract: you will walk out knowing what each one buys, having watched all
  four run on the payment flow.
- Last line is the cube glimpse. One line, no drawing.

DELIVERY
Four one-liners on the slide, uncovered together rather than one at a time —
revealing them separately invites the room to decode each one, and they are a
glimpse rather than a lesson. Do not announce that you are not teaching them;
just do not teach them, and spend the words on what they buy instead.

C13 CHECK
*A type indexed by a runtime value* keeps the type/value distinction visible.
Avoid *types are values* and *values are types* — both false, both the kind of
thing that sounds profound at speed.

FACTS — every identifier grepped from the code (C1)
- `data Approval : RiskLevel -> Type`      PaymentDomain.idr:264
- `assessOrder : Order n c -> (lvl : RiskLevel ** Assessment lvl n c)`
                                            PaymentDomain.idr:255
- `(1 _ : Session p) -> ...`               PaymentChannel.idr:82 — the binder is
                                            never named; it is always `_`
- `Send[Order, Receive[RiskSnapshot, ...]]` Derivation.scala:38 truncated; the
                                            real LowRiskProtocol is five deep
- Martin-Löf's type theory, 1972; Coquand and Huet, Calculus of Constructions,
  1988, extended to CIC.
- **the four systems do not share one kernel.** Rocq and
  Lean descend from the Calculus of Constructions; **Agda is an extension of
  Martin-Löf type theory** and **Idris 2's core is quantitative type theory**,
  Atkey's QTT over an MLTT base. Saying *that kernel is what all four are built
  on* is precise enough to be checked and wrong for half of them. *Between the
  two of them* is accurate, three words shorter, and still credits both names.
