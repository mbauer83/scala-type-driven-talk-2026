VERBATIM · cap 1:05 · Act 1 beat 6 of 6 · rail: MARTIN-LÖF · COQUAND lit, rail complete

"One last step up, quickly, because you will see all of it running later.

Martin-Löf, nineteen seventy-two, allowed a type to depend on a value — so the
type of what a function gives back can be computed from what you passed in.
Coquand, in eighty-eight, folded that together with polymorphism into a small
kernel, and that kernel is what Rocq, Lean, Agda and Idris are built on.

Four notations, and I am deliberately not going to teach them.

A type indexed by a runtime value; a value paired with a proof about that
specific value; a binding that must be used exactly once; and a whole
conversation between two services, written down as one type.

You will not walk out fluent in any of that, and it is not the point. You will
walk out knowing what each one buys, because you will have watched all four run
on the payment flow we started with. There is a map of this territory, and we
will fill it in as we go."

NOTE ON THE LINTER
The four notations are punctuated as one list rather than four sentences. As
sentences they trip `monotone` — fairly, because four flat beats in a row is
exactly what that rule is for. A spoken list is one unit and should be written
as one. Same fix as the syllogism on `A1-aristotle`.

DELIVERY
Four one-liners on the slide, uncovered together rather than one at a time —
they are a glimpse, not a lesson, and revealing them separately invites the room
to try to decode each one.

The last sentence is the lambda-cube glimpse. One line, no explanation, no
drawing; the cube itself first appears lit at `A3-ceiling`.

C13 CHECK (Part 8)
"A type indexed by a runtime value" keeps the type/value distinction visible.
Avoid "types are values" and "values are types" — both are false and both are
the kind of thing that sounds profound at speed.

FACTS — every identifier here is grepped from the code (C1)
- `data Approval : RiskLevel -> Type`      PaymentDomain.idr:264
- `assessOrder : Order n c -> (lvl : RiskLevel ** Assessment lvl n c)`
                                            PaymentDomain.idr:255
- `(1 _ : Session p) -> ...`               PaymentChannel.idr:82 — the binder is
                                            never named; it is always `_`
- `Send[Order, Receive[RiskSnapshot, ...]]` Derivation.scala:38 truncated; the
                                            real LowRiskProtocol is five deep
- Martin-Löf's type theory, 1972; Coquand and Huet, Calculus of Constructions,
  1988, extended to CIC.
