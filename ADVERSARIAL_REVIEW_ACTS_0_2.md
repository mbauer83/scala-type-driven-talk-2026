## Summary

| ID | Slide | Sev | Category | One-line |
|----|-------|-----|----------|----------|
| F-01 | A0-title / A1-curry-howard | MAJOR | argument | The deck correctly implies that annotations are optional, but it never names the typing judgment required for a proof reading and still overextends the claim to ordinary Java type-checking. |
| F-02 | A1-connectives | MAJOR | legibility | The two code examples central to the slide render at 15 px and will not survive the back of the room. |
| F-03 | A1-quantifiers | BLOCKER | factual | Java wildcards are explicitly a restricted form of existential types. |
| F-04 | A1-quantifiers | MAJOR | overclaim | An unbounded Java `T` still exposes `Object` methods and the argument's runtime class. |
| F-05 | A1-crisis | BLOCKER | factual | The Hilbert/Gödel account substitutes soundness for decidability and states an unrestricted theorem Gödel did not prove. |
| F-06 | A1-curry-howard | MAJOR | time | The thesis slide is thirty seconds over cap because it carries three dispensable historical and effects asides. |
| F-07 | A1-above | MAJOR | factual | Rocq and Lean descend from CoC, but Agda and Idris 2 do not share the claimed kernel. |
| F-08 | A2-values | MAJOR | join | Page 10 lands on definition-level review; page 11 abruptly restarts with elementary definitions and no causal link. |
| F-09 | A2-values | BLOCKER | factual | `.equals` does not generally compare value, and records remain reference types. |
| F-10 | A2-values | MAJOR | c13-equivocation | Calling a type "the compiler's reasoning" merges the type with the checker. |
| F-11 | A2-values | MAJOR | overclaim | The landing says everything is paid at compile time immediately after acknowledging runtime-indexed dependent types. |
| F-12 | A2-promises | BLOCKER | c13-equivocation | The slide conflates deciding a typing judgment with deciding arbitrary semantic safety, then misapplies Rice to type-checking itself. |
| F-13 | A2-promises | BLOCKER | factual | Java's array-store check is a deliberate runtime enforcement mechanism, not a soundness hole. |
| F-14 | A2-promises | MAJOR | legibility | The two-line example that must surprise the room renders at 17 px. |
| F-15 | A0-title / A0-incidents / A0-turn | MINOR | robustness | Three script headers contradict the authoritative budgets by a combined 45 seconds. |

### F-01 · A0-title / A1-curry-howard · MAJOR · argument

WHERE    touying/scripts/01-title.md:8; touying/scripts/08-curry-howard.md:43  
QUOTE    "By the end I think you'll see that writing a program that type-checks is, in a precise sense, the same thing as constructing a proof in formal logic, and that you've been doing it all along." / "That holds whether or not you write the types down, because in an untyped language the proposition is still there and nothing ever checks it."  
FAULT    Curry–Howard does not require annotations—a JavaScript string literal can be given an implicit, dynamic or external judgment `"hello" : String` and thereby witness that `String` is inhabited—but it does require some typing judgment connecting the term to a proposition, while the opening still claims the correspondence for ordinary Java type-checking that page 8 later says is not a proof.  
IMPACT   The audience is left unable to tell whether the thesis is about annotations, runtime classifications, static derivations, successful executions, or Java's checker, so the one sentence they repeat next morning has no stable strength.  
FIX      Replace the opening with: "By the end I think you'll see that writing a program that type-checks can be, in a precise sense, the same as constructing a proof — and how close Java gets." Replace the later sentence with: "The annotations may be absent; the proof reading still requires a typing judgment connecting the program to a proposition."  
COST     -12 words  
CONF     high

### F-02 · A1-connectives · MAJOR · legibility

WHERE    rendered page 5, both central code panes  
QUOTE    (layout)  
FAULT    `RiskDecision.java` and `OrderLine.java` render at 15 px even though inspecting those definitions is the slide's concrete bridge from algebra to Java.  
IMPACT   The back half hears "plus" and "times" while being unable to verify which Java construction corresponds to either.  
FIX      Set both panes to `code-size: 22pt`; wrap the `permits` list onto three continuation lines and leave the surrounding copy unchanged.  
COST     none  
CONF     high

### F-03 · A1-quantifiers · BLOCKER · factual

WHERE    touying/scripts/06-quantifiers.md:130  
QUOTE    "There is a second quantifier, there-exists. Java has no honest way to write that one, and it is the first thing we need at the top of the climb."  
FAULT    The Java Language Specification explicitly describes wildcards as a restricted form of existential types, so `List<?>` is the immediate counterexample. [JLS §4.5.1](https://docs.oracle.com/javase/specs/jls/se25/html/jls-4.html#jls-4.5.1)  
IMPACT   A Java generics specialist can puncture the climb's first claimed expressiveness boundary before the dependent-type payoff arrives.  
FIX      Replace with: "Java wildcards are restricted existentials; the stronger form that returns a value together with evidence comes back at the top of the climb."  
COST     -6 words  
CONF     high

### F-04 · A1-quantifiers · MAJOR · overclaim

WHERE    touying/scripts/06-quantifiers.md:123  
QUOTE    "the power is in what the body cannot do: it never gets to ask what T is."  
FAULT    An unbounded `T` has `Object`'s members, including `getClass`, so Java weakens the parametricity claim even though the type argument itself is erased. [JLS §§4.3.2, 4.4 and 4.6](https://docs.oracle.com/javase/specs/jls/se25/html/jls-4.html)  
IMPACT   Experienced Java developers supply `t.getClass()`, `t.equals(...)`, or reflection and stop trusting the claimed guarantee.  
FIX      Replace spoken lines 123–128 with: "A generic method receives no runtime token for T, so one implementation covers every T, including future types. It can still use Object methods or inspect each argument's runtime class; add T extends something when it needs T-specific operations."  
COST     -11 words  
CONF     high

### F-05 · A1-crisis · BLOCKER · factual

WHERE    touying/scripts/07-crisis.md:41  
QUOTE    "Hilbert's answer was three things. Consistency, so it never derives a contradiction; soundness, so anything it proves is true; completeness, so anything true can be proved. Gödel showed in nineteen thirty-one that you cannot have all three, and the one everybody gave up was completeness"  
FAULT    Hilbert's programme centred on consistency, completeness and effective decision, while Gödel's theorem applies to consistent, effectively axiomatized systems strong enough for arithmetic—not every sound formal system, and not "all three" as listed here. [Gödel's incompleteness theorem](https://plato.stanford.edu/entries/goedel-incompleteness/)  
IMPACT   The historical bridge into the checker slide is false, and a logic-literate attendee can dismantle it before Curry–Howard appears.  
FIX      Replace that paragraph and the right-hand panel with: "Hilbert asked whether formal mathematics could be made consistent and complete, with proofs checked mechanically. Gödel showed that any consistent, effectively axiomatized system strong enough for arithmetic is incomplete. That leaves the practical question your compiler answers: what can a terminating check still guarantee?"  
COST     -26 words  
CONF     high

### F-06 · A1-curry-howard · MAJOR · time

WHERE    touying/scripts/08-curry-howard.md:32  
QUOTE    "Church and Turing, both in nineteen thirty-six, made computation formal, and Church's typed lambda calculus is the direct ancestor of the Function-of-String-to-Integer you wrote in Java 8."  
FAULT    The slide carrying the thesis measures 2:00 against a 1:30 cap because Church/Turing lineage, Lambek/category theory and the effects taxonomy all compete with the construction/type/checker distinction.  
IMPACT   The most important explanation is rushed, while Act 1 reaches 8:52 against its 7:10 allocation.  
FIX      Delete spoken lines 32–34, the two Lambek sentences at lines 39–41, and the two effects sentences at lines 54–56; also remove the Lambek caption and effects sentence from the slide. The sequence becomes Howard → construction/type/checker → totality caveat → ladder.  
COST     -84 words  
CONF     high

### F-07 · A1-above · MAJOR · factual

WHERE    touying/scripts/09-above.md:76  
QUOTE    "Coquand folded that together with polymorphism in eighty-eight, and that kernel is what Rocq, Lean, Agda and Idris are built on."  
FAULT    Rocq and Lean use descendants of the Calculus of Constructions, but Agda describes itself as an extension of Martin-Löf type theory and Idris 2 uses a QTT-based core. [Agda](https://agda.readthedocs.io/en/stable/getting-started/what-is-agda.html), [Idris 2](https://idris2.readthedocs.io/en/latest/implementation/overview.html)  
IMPACT   The closing historical claim of the primer is precise enough to be checked and broad enough to be wrong.  
FIX      Replace with: "Coquand and Huet combined dependency with polymorphism in the Calculus of Constructions, one ancestor of modern proof-assistant kernels."  
COST     -3 words  
CONF     high

### F-08 · A2-values · MAJOR · join

WHERE    touying/slides/15-test-spine.typ:117; touying/scripts/10-values.md:11  
QUOTE    "Verifying that the type definition correctly encodes the rule replaces per-call-site checks — paid once, in code review, at the definition." / "Two words, because the rest of the talk leans on them."  
FAULT    The second sentence does not explain why the talk has left the payment scenario and returned to definitions of values and references.  
IMPACT   Act 2 feels like a primer restarting after the promised arrival rather than the foundation of the code ladder.  
FIX      Replace the opening cue with: "That definition-level review rests on two words the rest of the talk leans on: value and reference."  
COST     +6 words  
CONF     high

### F-09 · A2-values · BLOCKER · factual

WHERE    touying/slides/a2-values.typ:50  
QUOTE    "In Java the primitives are values and everything else is a reference, which is why `==` compares the reference and `.equals` compares the value — and why `record` exists, to give you value semantics over one."  
FAULT    `==` also compares primitive values, `.equals` means whatever the class defines and defaults to identity, while records merely synthesize component-based equality and remain reference types. [Object.equals](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/lang/Object.html#equals(java.lang.Object)), [JLS record equality](https://docs.oracle.com/javase/specs/jls/se25/html/jls-8.html#jls-8.10.3)  
IMPACT   A foundational slide tells a Java room something they can disprove with `new Object().equals(new Object())`.  
FIX      Replace with: "In Java, `==` compares primitive values or reference identity; `.equals` means whatever the class defines, and records generate component-wise equality while remaining reference types."  
COST     -12 words  
CONF     high

### F-10 · A2-values · MAJOR · c13-equivocation

WHERE    touying/slides/a2-values.typ:63  
QUOTE    "A type is the compiler's reasoning about which values may flow where."  
FAULT    The type classifies expressions and values; the checker is the thing performing reasoning with that classification.  
IMPACT   The slide re-merges type and checker three pages after the talk explicitly separated them.  
FIX      Replace with: "A type classifies values and expressions; the checker uses it to decide which values may flow where."  
COST     +5 words  
CONF     high

### F-11 · A2-values · MAJOR · overclaim

WHERE    touying/scripts/10-values.md:36  
QUOTE    "Everything the rest of the talk asks for is paid at compile time, and the part that helps you most has already been collected by the time you press run."  
FAULT    Stage 6 explicitly depends on runtime values entering indexed types, while constructors and boundary validation elsewhere in the ladder also perform runtime work.  
IMPACT   The landing erases the exception the same slide worked to preserve and sets up a false "types are free" thesis.  
FIX      Replace with: "Most of the benefit arrives before runtime: while you model the domain, when the checker rejects a bad call, and when somebody reads a signature."  
COST     -5 words  
CONF     high

### F-12 · A2-promises · BLOCKER · c13-equivocation

WHERE    touying/slides/a2-promises.typ:52  
QUOTE    "if it compiles, the property holds" / "every safe program is accepted — deliberately given up" / "Given up for decidability — and that is Rice, not Gödel"  
FAULT    A checker may decide its formal typing judgment exactly; Rice constrains non-trivial semantic properties of arbitrary computations, so the claimed trade only appears after "the typing judgment" has been silently replaced by "all semantic safety." [Rice's theorem](https://doi.org/10.1090/S0002-9947-1953-0053041-6), [type safety via progress and preservation](https://www.cs.cmu.edu/~fp/courses/15312-f04/lectures/06-safety.html)  
IMPACT   The slide that should cash out the thesis instead commits its central equivocation between the encoded proposition and everything one might want the program to do.  
FIX      Replace the table with: "typing judgment — the program satisfies the language's formal rules"; "encoded guarantee — the corresponding soundness theorem holds, subject to explicit escape hatches"; "semantic safety — broader than any terminating checker can decide for arbitrary programs." Replace the Rice paragraph with: "Rice limits the last row, not the first: the checker can decide its own rules exactly and still reject programs that are safe in a broader semantic sense."  
COST     -22 words  
CONF     high

### F-13 · A2-promises · BLOCKER · factual

WHERE    touying/slides/a2-promises.typ:72  
QUOTE    "`null`, unchecked casts, Scala's `asInstanceOf`, Idris's `believe_me` — and one hole that is Java's own:"  
FAULT    Array covariance is a static imprecision followed by a mandatory runtime store check; that check prevents the wrong value entering the array and therefore preserves the language's safety boundary. [JLS §10.5](https://docs.oracle.com/javase/specs/jls/se26/html/jls-10.html#jls-10.5)  
IMPACT   The slide presents Java successfully enforcing its rule as evidence that Java's rule is unsound.  
FIX      Replace the heading and list with: "Unchecked casts and `believe_me` are escape hatches. Array covariance is different: Java accepts this assignment statically, then a mandatory store check throws before the array is corrupted." Change the code comment to `// runtime check → ArrayStoreException`.  
COST     +4 words  
CONF     high

### F-14 · A2-promises · MAJOR · legibility

WHERE    rendered page 12, lower-right `ArrayStore.java` pane  
QUOTE    (layout)  
FAULT    The two lines the speaker is instructed to read and pause over render at 17 px.  
IMPACT   The audience hears that the example is surprising but cannot independently inspect the assignment that makes it so.  
FIX      Raise this pane alone to `code-size: 24pt`; both lines fit its current width without changing the grid.  
COST     none  
CONF     high

### F-15 · A0-title / A0-incidents / A0-turn · MINOR · robustness

WHERE    touying/scripts/01-title.md:1; touying/scripts/02-incidents.md:1; touying/scripts/03-the-turn.md:1  
QUOTE    "VERBATIM · cap 1:00" / "VERBATIM · cap 2:35" / "VERBATIM · cap 1:50"  
FAULT    The authoritative caps are respectively 0:50, 2:15 and 1:35, so the rehearsal-facing headers license 45 seconds the budget does not contain.  
IMPACT   Pacing from the scripts spends almost a third of the whole-talk slack before Act 1 begins.  
FIX      Change the three headers to `cap 0:50`, `cap 2:15` and `cap 1:35`.  
COST     none  
CONF     high

## Do not change

- A0-incidents: keep Alice's single-line-fixture explanation and the distinction between compilation and production escape; those make the story credible.

- A0-turn: keep "A test could have caught every one" and "at a reasonable price." Removing either recreates an overclaim already corrected.

- A1-aristotle: keep the payment-domain syllogism before the symbolic form. It introduces validity without requiring a second example.

- A1-connectives: keep the sum/product pairing and literal counting. Increase the code size; do not replace the capability-first arrangement.

- A1-curry-howard: keep the explicit construction/type/checker distinction, the total-pure-calculus caveat, and the point that source annotations are not required. Correct the scope by naming the required typing judgment; do not replace it with a claim that only explicitly annotated programs can have a proof reading.

- A1-above: keep the opening explanation that the result type may depend on the argument; it is the slide's only reason for showing the four notations.

- A2-values: keep the design-time payoff separate from erasure, and keep the Stage 6 exception—made larger and phrased precisely.

- A1-crisis → A1-curry-howard: preserve the "what can a formal check guarantee?" → "why can a compiler take that deal?" hand-off after correcting the history.

## Open questions for the speaker

- Will the opening use the defensible "can be / how close Java gets" claim, or will you retain the literal "same thing / you have done it all along" claim and explicitly defend how Java's partiality fits it?

- On the Curry–Howard slide, will you describe JavaScript's proof reading through an implicit or external typing judgment, or make the weaker claim only about values that successfully reach a runtime classification?

- For the required Act 1 time recovery, will you cut the 84-word Curry–Howard asides, or invoke the reserved connectives/quantifiers merge?

## Top five, ranked

1. F-12 — the checker slide confuses typing judgments with arbitrary semantic safety, recreating the exact program/type/checker collapse the primer exists to prevent.
2. F-05 — the Hilbert/Gödel claim is plainly false and supplies the faulty premise reused by A2-promises.
3. F-13 — the Java-specific evidence for unsoundness actually demonstrates Java's runtime enforcement mechanism.
4. F-03 — "Java has no existential" has a direct JLS counterexample and damages credibility with precisely the strongest Java developers in the room.
5. F-01 — the talk can retain the valuable no-annotations insight, but it must name the typing judgment and reconcile the opening with its own Java caveat.
