VERBATIM · cap 1:25 · word count is computed by `make timing`, not stated here. This minute turns four war stories into the
thesis, and it is the second place you are most likely to stumble. Over-rehearse it.

TALKING POINTS
1. Concede it: a test could have caught every one — Alice's did, eventually
2. But a test is a case someone must think of and keep correct
3. A type is applied at every use, by the compiler, for free
4. You have been writing logic all along — every if, every guard — and it
constrains what the program does WHILE IT RUNS. Types do the same one level up — how it can be CONSTRUCTED
5. A type is that same job ONE LEVEL UP: about the program itself
6. You write that kind too — sealed interface = Gentzen 1935; generic = ∀
7. That question is 2,500 years old — philosophy, logic, maths, your compiler

VERBATIM

"A test could have caught every one of those - Alice's was, eventually. Each of those
tests, though, is a case somebody has to think of, write down, and keep correct,
everywhere the rule applies.

Where the same rule can be encoded in a type at a reasonable price, the compiler
applies it at every use, and nobody has to remember. How we can tell whether
something is valid and how we can say what that means 
- those questions are much older than programming.

That history stretches back about two and a half thousand years, across
philosophy, logic, mathematics and computer science. It is the thread I want to
follow tonight.

You have been writing logic all along - every if, every guard - and all of it
constrains what the program does while it runs. Types do the same thing one level up: they constrain how a program can be
constructed at all, and they settle it before it runs.

You write that kind too: when you write a sealed interface and the compiler makes
you handle every case, you are applying a rule that Gerhard Gentzen wrote down in
1935. When you write a generic method, you are stating that
you can do something for every type - present and future. That is a universally
quantified statement.

Once you can see the structure and the mechanisms, you can encode a great deal more 
of what your system actually requires, and have it checked for you 
— and for the agents now writing code next to you."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

EDIT TO MB'S PROSE, FLAGGED (C11) — 18 Aug
The fourth paragraph was: *When you write a sealed interface … That is a
universally quantified statement.* Both sentences survive verbatim. What is new
is the claim they are now evidence **for**, because MB asked for this to land
early and it was not being said anywhere:

> All programming already does logic — conditionals, guards, control flow. Types
> do logic **one level up**, where it specifies and constrains the program
> itself.

Two reasons it belongs here rather than in Act 1. This slide is where four war
stories turn into the thesis, so a claim about what kind of thing a type *is*
belongs in the same breath. And Bob's `if (risk != HIGH)` is one slide old — the
room has just watched program-level logic be correct, compile, and be wrong
anyway, which is the strongest possible setup for *there is another level*.

C3 in its usual form: **name the frame here, fill it at `A1-connectives`**, where
`||` and `&&` reappear as `∨` and `∧` over types. An earlier attempt tried to do
both jobs inside a clause on `A1-connectives` — *Watch which level they land on
in Java* — which stated neither half, dismissed program logic rather than
affirming it, and was rightly called out.

The spoken version is deliberately the short one — **the slide carries the full
statement**, so the speaker names the level and moves on rather than reading it
out. Paragraph three was also tightened by twelve words (it was restating the
slide almost verbatim), which is where most of the new airtime came from.

Revert freely if the wording is not yours; the claim has to stay somewhere in
this minute. If the cap needs to move to hold it, `A0-turn` is the slide to move
it for, and the time comes from Act 4 (Part 3's standing rule for overage).
NOTES ON THE WORDING
- PART 10, three corrections applied here.
  1. »every call site« is gone. **Types do not have call sites**, and they are
     useful well beyond functions and methods — a field, a record component, a
     type parameter, a variable binding. »Every use« is both correct and wider.
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
  re-deriving it here is redundant — and »would have found it in a day« was wrong
  anyway: once written, that test fails immediately. »Alice's was, eventually«
  references the established fact without putting a number on how long it took.
- The hedged restatement — because-a-good-part-of-what-everyone-in-this-room-does-
  already-sits-at-the-end-of-it — is deliberately GONE. Slide 1 now makes that
  claim, and harder. What follows here — Gentzen, universal quantification — is the
  evidence for it, and evidence lands better without a restated thesis in front of
  it. Do not put it back without also weakening slide 1.
- »Stating that you can do something for every type« fuses the claim and the
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
