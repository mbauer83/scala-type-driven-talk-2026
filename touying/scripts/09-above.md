A1-above · cap 1:05 · Act 1 beat 6 of 6 · rail: MARTIN-LÖF (+) lit, rail complete

WHAT WAS MISSING, AND IT WAS THE WHOLE POINT (MB, 18 Aug)

The previous version listed four notations and never said what dependent types
*change*. It showed the syntax of the most powerful idea in the section and left
the room with no reason to care, then covered the gap with
*four notations, and I am deliberately not going to teach them* — a line that
announces a refusal and carries no information.

The shift, stated plainly, and it is now the lede on the slide:

> Until now a function's result type was fixed before you called it. Martin-Löf
> let the result type be **computed from the argument**. That collapses two
> languages into one — the language the compiler runs to work out a type is the
> language you write your program in — and it means a type can state **any
> property you could write a program to check**.

That is the ceiling coming off. Everything below Stage 6 is a way of encoding
*some* invariants in a type system that was not designed to hold them; above it,
the question stops being *can my type system express this* and becomes *can I
write down a proof*.

IT IS ALSO THE THIRD RUNG OF A LADDER THE ROOM HAS ALREADY CLIMBED
`A1-quantifiers` puts two rungs on the board. This is the third, and saying so
out loud is what makes the beat land as an arrival rather than as new syntax:

  over values, result fixed      a function type       (A1-quantifiers)
  over types                     a generic             (A1-quantifiers)
  over values, result computed   Π                     (here)

BEATS

- One more step, and it changes what a type is able to say.
- Martin-Löf 1972: the result type may be computed from the argument.
  › the type language and the program language become the same language
  › so a type can state any property you could write a program to check
- Coquand 1988 folds that together with polymorphism into a small kernel — the
  one Rocq, Lean, Agda and Idris are built on.
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

C13 CHECK (Part 8)
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

VERBATIM

"One more step up, and it changes what a type can say.

Everything so far has had the result type fixed before you called the function.
Martin-Löf, in nineteen seventy-two, let it be computed from the argument
instead. That collapses two languages into one: the compiler now works out a type
by running the same language you write your program in. So a type can state any
property you could write a program to check. Coquand folded that together with
polymorphism in eighty-eight, and that kernel is what Rocq, Lean, Agda and Idris
are built on.

What that buys, in the places you will see it run: a type indexed by a runtime
value; a value paired with a proof about that value; a binding the compiler
counts and will not let you drop; and a conversation between two services
written down as one type.

You will walk out knowing what each one buys, having watched all four run on our
payment flow. There is a map of this territory, and we fill it in as we go."
