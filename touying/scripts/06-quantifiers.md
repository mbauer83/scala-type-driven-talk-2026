VERBATIM · cap 1:05 · Act 1 beat 3 of 6 · rail: FREGE lit

THE PART 10 PROBLEM THIS SLIDE NOW ANSWERS

MB, reviewing the built slide: the added value is not clear, because
*all medium-risk orders need 3DS* on `A1-aristotle` is **already a universal
quantification**. Presenting ∀ as new is therefore a beat the audience has had.
The slide had to change, not just the wording.

What Frege actually adds, and what the slide now shows in three parts:

1. **The quantifier becomes a separable part.** Aristotle's *all M are T* has the
   quantification baked into the sentence form; there are exactly four such forms
   and no way to take one apart. Frege binds a variable, so the ∀ is a piece you
   can move, nest inside another quantifier, and put a negation between.
2. **The domain stops being a category.** *All M* ranges over a term in a fixed
   scheme; *for all o* ranges over anything at all, including a domain nobody can
   enumerate.
3. **There is a second one.** ∃ has no place in the syllogistic forms as a first-
   class operator. It is named here and deliberately given no Java mirror.

BEATS — delivery aid; the script is below

- Concede first: you have already seen a quantifier. That is Aristotle's *all*.
- Frege's move is to make the quantifier a part you can get hold of.
  › propositions with holes in them, then bind the hole
  › for all o, if o is medium-risk, then o needs 3DS
- What binding buys, in order:
  › nest one inside another, negate between them
  › range over a domain nobody could enumerate
  › and it has a partner — there exists
- ∃ is NAMED and left unmirrored. Say only that Java has no honest way to write
  it and that we come back to it.
- Their code, and it is the universal only: a generic method claims something
  about every type it will ever be applied to.
- Land it: the signature is the claim, the body makes good on it.

VERBATIM

"You have already seen a quantifier. All medium-risk orders need three-D Secure —
that is Aristotle, and it does say something about every order. What Frege added
in eighteen seventy-nine is that the quantifier becomes a part of the sentence
you can get hold of.

He writes propositions with holes in them and then binds the hole: for all o, if
o is medium-risk, then o needs three-D Secure. Because o is a variable, you can
nest one quantifier inside another, put a negation between them, and range over a
domain nobody could enumerate. And the universal has a partner — there exists.
Hold that one; Java has no honest way to write it, and it comes back later.

You write the universal already. A generic method is a claim about every type it
will ever be applied to, including types nobody has written yet. The signature is
the claim, and the body is what makes good on it — once, for all of them."

DELIVERY
Concede the syllogism in the first breath. If the room is left to notice on its
own that Aristotle already quantified, the slide reads as repetition and the
three additions land on an audience that has stopped listening.

*Including types nobody has written yet* is the line that should land. It is also
true and checkable, which is why it beats the vaguer version.

C13 CHECK (Part 8)
The generic method's SIGNATURE is the universally quantified proposition; the
method BODY is the construction that proves it. The last line says it that way
round on purpose — do not shorten it to *generics are ∀*, because that is the
equivocation.

FACTS
- Frege, Begriffsschrift, 1879, introduces quantification proper. Aristotle's
  four categorical forms quantify, but the quantifier is not an operator in them.
- Do NOT put `Optional<Proof>` here as ∃. `Optional[T]` is `T ∨ 1`, a
  disjunction; the Curry-Howard reading of ∃ is a dependent pair, which is
  exactly what `A1-above` introduces as Σ and what Stage 6 shows Java cannot do.
  A listener joining this slide to that one would conclude Java has Σ-types.
  ∃ is named on the slide and left for `A1-above`; it is not given a Java mirror.
  This is the single deliberate exception to Act 1's pair-every-concept-with-its-
  Java-mirror rule (Part 10/E), and it is load-bearing.
- The Java is `Validator.check` from `02-java5-generics/Validator.java`.
