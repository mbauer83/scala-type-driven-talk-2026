A2-values · cap 0:50 · Act 2 beat 2 of 3 · VERBATIM

TALKING POINTS
1. Two words the rest of the talk leans on
2. A value is a bit pattern plus an agreement about how to read it
3. A reference is a value that denotes a location
4. Java, precisely: == is value for primitives, identity otherwise
5. .equals is whatever the class defined; a record generates a component-wise one
6. A type does a different job — it classifies; the checker reasons with it
7. Most of what it buys is spent before the program runs
8. Payment<Initiated> and Payment<Authorized> are the same bytes
9. So it is cheap — and what you erase you cannot ask about later
10. Stage 6 is the one place we spend at runtime on purpose

VERBATIM

"A value is a bit pattern plus an agreement about how to read it. A reference is
a value that denotes a location — and in Java, double-equals compares primitives
by value and everything else by identity; equals means whatever the class chose
to define.

A type does a different job: it classifies values, and the checker uses that
classification to decide which values may flow where. Most of what the pair buys
you is spent before the program runs — while you model the domain, while the
checker turns down a bad call, while somebody reads a signature.

Payment-of-Initiated and Payment-of-Authorized are the same bytes. Nearly
everything this talk asks for is paid at compile time, and Stage 6 is the one
place we spend at runtime on purpose."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

TREATMENT — CHANGED 18 Aug
Part 6b/T had Act 2 as cues plus one scripted landing line, so this file carried
an EST-WORDS declaration and no script. MB: the verbatim sections were simply
missing. Both Act 2 slides are now fully scripted like Act 0 and Act 1, the
EST-WORDS estimate is gone, and `make timing` counts the real thing.

BEATS

- Bridge from the scenario first, in one clause — the room has just been looking
  at a payment flow and is owed a reason for the detour: encoding a rule once, at
  the definition, rests on two words.
- Then the two words themselves.
  › a value is a bit pattern plus an agreement about how to read it
  › a reference is a value that denotes a location
- Java, and say it precisely because this room can check you: `==` compares
  primitives by value and everything else by identity; `.equals` is whatever the
  class defined and defaults to identity; a `record` is where the compiler writes
  a component-wise one for you. Do not linger — they know this and are waiting to
  hear why it matters.
- **The turn, and the load-bearing part.** A type classifies values; the checker
  uses that classification to decide which values may flow where. Most of what
  the pair buys is spent before the program runs at all.
  › while you model the domain
  › while the checker turns down a bad call
  › while somebody reads a signature and infers the contract
- Point at the two `Payment` types: same bytes.
- Then the cheap/costly pair, fast:
  › a type parameter like `<Initiated>` carries no data, opaque types are plain
    Strings, the use-once markers are gone before the program starts — you pay
    in compile-time expressiveness
  › **do not say *phantom* here.** Stage 4 introduces it two acts later; using
    the name before the thing is C3, and half the room will not have it
  › and what you erase you cannot ask about later, which is why
    `x instanceof List<String>` does not compile
- Name the exception and move on. Stage 6 runs the other way.

LANDING LINE — now the closing paragraph of the VERBATIM above.
It was a separate quoted block here, which double-counted it in `make timing`.

MUST LAND
That types are a design-time and compile-time tool. If the room leaves with
*types are free because they get erased*, the slide has taught the wrong lesson
and Stage 6 has nothing left to sell.

TWO POINTS THAT MUST NOT BE CONFLATED (Part 3, raised in review)

1. **The value of types here is mostly independent of erasure.** Most of the
   payoff arrives before the program runs — modelling, rejection, reading a
   signature. Whether the type survives to runtime is largely an implementation
   question. Do not let the argument rest on erasure; erasure is why it is
   *cheap*, not why it is *good*.
2. **Dependent types are the deliberate exception.** Stage 6 works precisely
   because a runtime value flows into a type: `protocolFromSnapshot` computes a
   `SessionType` from data only known at runtime. That is a different mechanism
   from the erased phantom parameters of Stages 4 and 5, and flattening the two
   into *types are erased anyway* destroys the Idris payoff before it arrives.
   The footnote states the general rule here and marks the exception; `A5-mltt`
   collects it.

NOT ON THIS SLIDE
**Gradual typing.** It was proposed here and moved to `A6-cost` (Part 3): it is
an *adoption* argument — how do I start without a rewrite — not a claim about
what a type is, and the cost slide is where that question gets asked.

C13 CHECK (Part 8)
This is one of the three slides most at risk. Keep type and value distinct in
every sentence. Never *types are values* or *values are types*; the type is the
proposition, the value is not a claim about anything.

FACTS
- `Payment<Initiated>` and `Payment<Authorized>` really are the same bytes —
  the phantom parameter in `04-java-typestate` has no runtime representation.
- `x instanceof List<String>` is rejected by javac: illegal generic type for
  instanceof. `List<?>` compiles. Worth knowing precisely if challenged.
- Scala 3 opaque types erase to their underlying representation; Idris 2
  quantities (0, 1, ω) are erased and are a compile-time discipline.

CORRECTIONS FROM THE 18 AUG EXTERNAL REVIEW (F-09, F-10, F-11)

**F-09 was a blocker and it was on the one slide a Java room can fact-check in
their heads.** The old line said `==` compares the reference and `.equals`
compares the value. Both halves are wrong: `==` compares primitives by value, and
`Object.equals` defaults to identity, so `new Object().equals(new Object())` is
false. Records were also described as giving *value semantics*, which they do not
— JLS 8.10.3 generates a component-wise `equals`, and the record stays a
reference type. Say the precise version; it is barely longer and it is the slide
where credibility is cheapest to lose.

**F-10 — *a type is the compiler's reasoning* merged the type with the checker**,
three slides after `A1-curry-howard` separated them by name. The type classifies;
the checker reasons. The plan's own Part 3 wording had the same slip and it was
copied straight onto the slide.

**F-11 — the landing line erased the exception the slide had just made.** Saying
everything is paid at compile time, one line under a footnote about Stage 6
sending a runtime value into a type, sets up exactly the *types are free* reading
this slide exists to prevent. It now concedes Stage 6 by name.
