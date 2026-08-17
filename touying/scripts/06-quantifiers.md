VERBATIM · cap 1:05 · Act 1 beat 3 of 6 · rail: FREGE lit

"Frege's real invention was not the connectives. It was propositions with holes
in them.

Before him you could say Socrates is mortal, and you could say Plato is mortal,
and you had two separate facts with nothing joining them. Frege let you write
that a property holds for every object, whatever the object turns out to be. For
all x, if x is medium-risk, then x needs three-D Secure. One statement, covering
every order that will ever exist, including the ones placed tonight.

You already write that too. A generic method is a claim about every type it will
ever be applied to — including types nobody has written yet, in codebases that do
not exist. You prove it once, in one place, and the compiler holds you to it
everywhere.

That is a much stronger thing to have said than most people realise they are
saying when they type angle bracket T."

DELIVERY
"Including types nobody has written yet" is the line that should land. It is also
true and checkable, which is why it beats the vaguer version.

C13 CHECK (Part 8)
The generic method's SIGNATURE is the universally quantified proposition; the
method BODY is the construction that proves it. Say it that way round if the
distinction is asked about — do not say "generics are ∀" without the body half,
because that is the equivocation.

FACTS
- Frege, Begriffsschrift, 1879, introduces quantification.
- Do NOT put `Optional<Proof>` here as ∃. `Optional[T]` is `T ∨ 1`, a
  disjunction; the Curry-Howard reading of ∃ is a dependent pair, which is
  exactly what `A1-above` introduces as Σ and what Stage 6 shows Java cannot do.
  A listener joining this slide to that one would conclude Java has Σ-types.
  ∃ is named on the slide and left for `A1-above`; it is not given a Java mirror.
- The Java is `Validator.check` from `02-java5-generics/Validator.java`.
