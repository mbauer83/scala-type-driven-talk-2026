VERBATIM · cap 1:50 · word count is computed by `make timing`, not stated here. This minute turns four war stories into the
thesis, and it is the second place you are most likely to stumble. Over-rehearse it.

"A test could have caught every one of those - Alice's was, eventually. Each of those
tests, though, is a case somebody has to think of, write down, and keep correct,
everywhere the rule applies.

Where the same rule can be encoded in a type at a reasonable price, the compiler
applies it at every use, and nobody has to remember. How we can tell whether
something is valid and how we can say what that means 
- those questions are much older than programming.

The history of what we are doing when we specify programs and types stretches back
about two and a half thousand years, across philosophy, logic, mathematics, and
computer science. That is the thread I want to follow tonight.

When you write a sealed interface and the compiler makes you handle every case, you
are applying a rule that Gerhard Gentzen wrote down in 1935. When you write a
generic method, you are stating that you can do something for every type - present
and future. That is a universally quantified statement.

Once you can see the structure and the mechanisms, you can encode a great deal more 
of what your system actually requires, and have it checked for you 
— and for the agents now writing code next to you."

NOTES ON THE WORDING
- PART 10, three corrections applied here.
  1. "every call site" is gone. **Types do not have call sites**, and they are
     useful well beyond functions and methods — a field, a record component, a
     type parameter, a variable binding. "Every use" is both correct and wider.
  2. The four fields were joined by arrows on the slide, which reads as a
     progression where each supplants or improves on the last. It is not one.
     They are middots now. A caption spelling that out was tried and cut — a
     slide should not explain its own punctuation, and the sentence was the
     kind of balanced nothing Part 12 exists to catch.
  3. The arithmetic/algebraic turn is NOT what makes logic mechanically
     checkable — **Aristotle's insight already does**, because a form can be
     checked by inspection. What the algebra buys is numerical *calculability*,
     which is later and different, and is where Leibniz and binary belong.
     Nothing on this slide claims otherwise; the claim lived on
     `A1-connectives` and is corrected there (Part 10/F1). Recorded here so the
     two slides cannot drift apart again.
- The opening no longer explains how a test would have caught Alice's. Slide 2
  already showed exactly that (the first two-line order in the test data), so
  re-deriving it here is redundant — and "would have found it in a day" was wrong
  anyway: once written, that test fails immediately. "Alice's was, eventually"
  references the established fact and carries the months in one word.
- The hedged restatement — because-a-good-part-of-what-everyone-in-this-room-does-
  already-sits-at-the-end-of-it — is deliberately GONE. Slide 1 now makes that
  claim, and harder. What follows here — Gentzen, universal quantification — is the
  evidence for it, and evidence lands better without a restated thesis in front of
  it. Do not put it back without also weakening slide 1.
- "Stating that you can do something for every type" fuses the claim and the
  capability into one clause instead of offering the audience a disjunction to
  resolve. It is also the proposition/program pairing, four slides before
  Curry-Howard names it.
- Sentence two is yours, lightly restructured so the verb arrives sooner: the
  original subject ran fourteen words before the verb. Your version reads fine
  on paper and is harder to say. Revert if you prefer it.
- 2,500 vs 2,400: Aristotle's Prior Analytics is roughly 350 BCE, so the literal
  figure is about 2,376 years. About-two-and-a-half-thousand is a fair round
  number; two-thousand-five-hundred states more precision than the date supports.
- Gentzen 1935 is the Untersuchungen über das logische Schließen, which introduces
  natural deduction and the introduction/elimination rules. The Gentzen slide (`A3-gentzen`) shows them.
- The claim is deliberately sits-at-the-end-of-it rather than is-proof-theory.
  A sealed interface instantiates a structure proof theory studies; saying it IS
  proof theory overclaims and loses anyone who knows the difference.
- The agents clause is one clause on purpose. Slide 29 carries that argument.
