A2-values · cap 0:50 · Act 2 beat 2 of 3 · CUES + one scripted landing line

EST-WORDS: 118

TREATMENT
Cues, not a verbatim script (Part 6b/T). The one sentence in quotes below is the
landing line and should be exact; everything else is spoken from the slide.

BEATS

- Two words, because the rest of the talk leans on them.
  › a value is a bit pattern plus an agreement about how to read it
  › a reference is a value that denotes a location
- Java, in one clause: primitives are values, everything else is a reference —
  hence `==` against `.equals`, hence `record`. Do not linger; the room knows
  this and is waiting to hear why it matters.
- **The turn, and the load-bearing part.** A type is the compiler's reasoning
  about which values may flow where, and most of what it buys is spent before the
  program runs at all.
  › while you model the domain
  › while the checker turns down a bad call
  › while somebody reads a signature and infers the contract
- Point at the two `Payment` types: same bytes.
- Then the cheap/costly pair, fast:
  › phantom parameters carry no data, opaque types are plain Strings,
    multiplicities are erased — you pay in compile-time expressiveness
  › and what you erase you cannot ask about later, which is why
    `x instanceof List<String>` does not compile
- Name the exception and move on. Stage 6 runs the other way.

LANDING LINE — say this one as written

"Everything the rest of the talk asks for is paid at compile time, and the part
that helps you most has already been collected by the time you press run."

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
