A1-connectives · cap 1:20 · Act 1 beat 2 of 6 · rail: LEIBNIZ · BOOLE

BEATS — delivery aid; the script is below

- Aristotle's forms were already checkable by eye. What nobody had was a way to
  *calculate* with one.
- Leibniz wanted that. A notation for every concept plus a calculus to grind
  through it, so two people who disagreed could sit down and settle it.
  › say it exactly: let us calculate
  › never built it; did invent binary on the way
- Boole 1847 delivers the first working piece: logic as algebra. **OR becomes a
  plus sign, AND becomes a times sign.**
- Left pane — the plus. A risk decision is low or medium or high, nothing else.
- Right card — the times. A risk decision paired with a refund mechanism, both at
  once. Point at the two comment numbers, 3 and 2.
- **The counting, and this is the beat that does the work.** Three values and two
  values. A choice between them: five. Both at once: six. 3 + 2 against 3 × 2.
  That is where the names come from.
- Bottom line: nest them. PaymentMethod is a sum whose variants are products.
- Land it: most domain models are that shape.

MUST LAND
The arithmetic is literal. If the room takes away *sum type and product type are
named after addition and multiplication, and you can count the values*, the beat
worked. That is a fact about types they have never been told and cannot confuse
with anything else they know.

THIS SLIDE DEMONSTRATES THE LEVEL POINT; `A0-turn` MAKES IT (MB, 18 Aug)
The claim — *all programming already does logic with conditionals and control
flow, and types do logic one level up, about the program* — is stated on
`A0-turn`, where the incidents become the thesis and Bob's `if (risk != HIGH)` is
one slide old. **This slide is the demonstration, not the claim:** `||` and `&&`
are the connectives the room already has, and the two panes are the same two
connectives over types.

An earlier attempt put the whole thing here as a clause — *Watch which level they
land on in Java: one above the booleans you compute while the program runs* —
which MB rejected, correctly. It never affirmed the first half, it dismissed
program logic instead of crediting it, and it interrupted a sentence about
algebra to do it. Claim first, on its own slide; demonstration here.

The word *level* then does work three more times without further explanation:

  `A1-quantifiers`  a generic quantifies one level up again, over types
  `A1-above`        Π lets a type depend on a value, and the levels collapse
  `A2-values`       a type classifies; the checker reasons with it

Making it general and early is what lets `A1-quantifiers` stop teaching two
things at once.

HOW THIS SLIDE HANDLES C13 — and why there is no disclaimer on it
The equivocation to head off is a Java developer hearing *you already write
logic* and thinking `if (a && b)`. The previous version fought that with a line
on the slide saying it was not about booleans. That is the wrong instrument:
naming the wrong idea plants it. This version simply cannot be read that way,
because counting the inhabitants of a type is not something a boolean expression
does. Boole's `+` and `×` combine *propositions*; in Java they combine *types*,
and the result is a shape that exists before anything runs. Say that positively
if you want it explicit — do not say what it is not.

WHAT IS NOT ON THIS SLIDE, ON PURPOSE
Introduction and elimination — the exhaustive match as `∨E` — belong to
`A3-gentzen`, sixty seconds before the compile error they explain. That is the
whole of P2. This beat is formation: what the connectives *build*. Splitting it
that way is also what gave `∧` room to have an example of its own, which is the
thing MB called out as unacceptable in the previous version.

PART 10/F1 — WHAT BOOLE BUYS, AND WHAT HE DOES NOT
An earlier draft said of Boole: *that is the moment inference becomes something a
machine could do*. Wrong, and it stole Aristotle's beat. **Mechanical
checkability arrives with Aristotle** — a form can be checked by inspection. The
algebra buys *calculability*: you can compute an answer rather than recognise a
shape. Leibniz belongs on the calculable side, with binary.

FACTS — grepped, not remembered (C1)
- Boole, *The Mathematical Analysis of Logic*, 1847. He wrote conjunction as
  juxtaposition or `xy`, and disjunction as `x + y` — and his `+` required the
  classes to be **disjoint**, which is exactly a tagged union. Jevons later
  relaxed it to inclusive or. The disjointness is a real point in your favour if
  anyone asks why a sealed interface is a *sum*.
- `RiskDecision` — 3 variants, `RiskDecision.java:9-13`, verbatim on the slide
  except that `permits` is wrapped onto its own line to fit the column. Same
  identifiers, same order, `record Medium()` present.
- `RefundMechanism` — 2 real variants, `InstantReversal` and
  `CreditNoteRequired`, `RefundMechanism.java:14-16`. Named in the gloss under
  the card so the audience can verify where the 2 comes from.
- **`RefundRule` is illustrative and is the one thing on this slide that is not
  in the repository.** Both of its field types are real and both numbers are
  checkable on screen; only the wrapper is invented. It is deliberately NOT
  rendered as a `code-pane`: no filename tab, no line numbers, no syntax colour,
  so nothing on the slide claims it is a file. If asked, say so plainly — it is a
  shape, and the two types in it are real.

WHY THE PRODUCT EXAMPLE CHANGED (MB, 18 Aug)
It used to be the real `OrderLine(String sku, int unitPriceCents, int quantity)`.
Verbatim from the repo, and useless here: the number of strings is unbounded, so
the caption could only say *as many as sku × price × quantity*, which asserts the
arithmetic instead of doing it. **The one thing this slide has to earn is that
you can count the values**, and a `String` field makes that impossible. Two small
real sealed types multiply to six, which a room can check in their heads while
you say it. The trade — one invented wrapper name against a demonstration that
actually demonstrates — is worth taking, and the mitigation above keeps it
honest.
- `PaymentMethod` — `Card(String token) | Wallet(String token) |
  Invoice(String reference)`, `PaymentMethod.java:9-12`. The bottom line is that
  type written as algebra.
- Leibniz: *characteristica universalis*, *calculus ratiocinator*, *calculemus*.
  Named in a clause, on the rail, no beat of his own (Part 6b/D2).
- Frege is NOT on this slide any more. 1879 and the quantifier are the next
  beat, and he was here only because an earlier draft needed a third name.

VERBATIM

"Aristotle's forms you could check by hand. What nobody had was a way to remove 
the quotation marks from <<mechanically checkable>> and actually calculate with
these logical shapes. Leibniz, in the 17th century, was perhaps the first to truly
devote himself to researching this in detail: a notation for every concept,
and a calculus to grind through it, so two people who disagreed could sit down and say, 
<<let us calculate>>. 
He never built it himself - but our current proof calculi and recent developments in 
categorical logic for example are definitely part of the same endeavor... 
and he invented binary encoding along the way.

Boole turned logic into algebra in eighteen forty-seven. He wrote OR as a plus
sign and AND as a times sign, and there's a mathematical reason for that. You
know both of these already from boolean expressions — here they are over types
instead.

Here is his plus: a risk decision is low, medium or high, and nothing else - 
a sum of three parts with one inhabitant each. Here is his times — pair a risk decision 
with a refund mechanism in one record, and you have both of them at once. 
Two options in one field, three in the other - 6 combinations overall.

Then you nest them. A payment method is a card or a wallet or an invoice, and
each of those carries its own field: a sum whose variants are products. Most of
the data you will ever model has that shape - and that shape is what permits 
effective pattern matching."
