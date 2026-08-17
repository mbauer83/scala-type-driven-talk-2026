// Clock: 14:30–19:00  (slide 14:30–16:30; demo 16:30–18:30; payoff 19:00)
//   merged: was Stage 3 (function-pipelines) + Stage 4 (records/sealed)
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [3],
  [Function Types · ADTs · Exhaustive Dispatch],
  [java 8–17 · lambdas → map synthesis · records ⊕ sealed · Gentzen ∨E],
  stack(
    dir: ttb,
    spacing: sz(16pt),
    eyebrow(style: "accent")[→ DEMO 3 in `Demo.java`],
    // ── Beat 1: function types as first-class values ──────────────────────
    // Non-generic example first, then the synthesis with Stage 2 generics.
    code-pane(filename: "Demo.java", language: "java", code-size: 16pt)[
```java
// A function type is an ordinary type — the lambda is an ordinary value  (t·t)
Function<String, Integer> idLength = s -> s.length();

// List<T> is a type constructor: takes a type argument, returns a type   (T·T)
// map is a polymorphic function: return type U inferred from the argument (t·T)
List<Integer> lengths = List.of("ord-001", "ord-002")  // List<String>
    .stream().map(idLength)   // Function<String,Integer> → U = Integer, inferred
    .toList();                // List<Integer>  ← compiler computed U, not declared
```
    ],
    // ── Beat 2: ADTs = records (products) + sealed (sums) ─────────────────
    // Records are product types; sealed interfaces are sum types.
    // Together they give us algebraic data types (ADTs): sums of products.
    grid(
      columns: (1fr, 1fr),
      rows: (auto,),
      gutter: sz(24pt),
      align: (left + top, left + top),
      code-pane(filename: "RiskDecision.java", language: "java", code-size: 18pt)[
```java
// Sum (∨): exactly one variant holds
sealed interface RiskDecision
    permits Low, Medium, High {
  // each variant is a product (∧)
  record Low()    implements RiskDecision {}
  record Medium() implements RiskDecision {}
  record High()   implements RiskDecision {}
}
```
      ],
      code-pane(filename: "Demo.java", language: "java", code-size: 18pt,
                highlights: ((4, "hl-good"),))[
```java
String path = switch (risk) {
    case Low    l -> "fast path";
    case Medium m -> "3DS path";
    case High   h -> "review path";
    // omit any case → compile error
};
```
      ],
    ),
    v(sz(4pt)),
    // ── Gentzen ∨E recall caption ─────────────────────────────────────────
    align(center)[
      #set text(size: sz(22pt), fill: pal.fg-dark-dim, font: mono-font)
      A ∨ B  #h(1.4em) \[A\]→C  #h(1.4em) \[B\]→C  #h(1.4em) ⊢  #h(1.4em) C
      #h(2.4em)
      #text(fill: pal.accent)[(∨E)]
      #h(1em)
      #text(size: sz(18pt), fill: pal.fg-dark-faint)[— recall S10]
    ],
  ),
)

#speaker-note[
// CUES:
// 1. Point at top pane: "Function<String,Integer> is a type; the lambda is a value — t·t"
//    → point at List<String>: "type constructor List<T> — T·T"
//    → point at .map(idLength): "polymorphic method — return type U inferred — t·T"
//    → point at List<Integer>: "compiler computed this, we didn't declare it"
// 2. Open PaymentMethod.java → "sum of products: each case is a record (all-fields),
//    the sealed interface says exactly which cases exist"
// 3. Open Demo.java → demo4() → show exhaustive switch on RiskDecision
// 4. Delete `case RiskDecision.Medium m →…` → compiler error → read aloud
// 5. Restore ⌘Z → "That compile error IS Gentzen's ∨E"

"Stage 2 gave us parametric polymorphism — `Validator<T>`, `AuditTrail<E>`. Type constructors: `Validator` takes a type argument and returns a specialised type — that's `T·T`. Powerful. But still limited: the code that *operated* on those typed containers couldn't itself be parameterised over what it produced. Java 8 changes that by making functions first-class values. A `Function<String,Integer>` is a type like any other; the lambda is a value of that type — that's `t·t`, the ordinary STLC level. The interesting case is `map`. `List<String>` is a type constructor applied to `String` — `T·T`. But `map` is a polymorphic method — `t·T`: it takes a function argument `f: T → U` and the compiler infers the return type `U` from `f`'s type. You pass `idLength`, a `Function<String,Integer>`, and the compiler concludes `U = Integer` and produces `List<Integer>` — you never declared that return type. The synthesis: type constructors together with polymorphic functions let the compiler compute what a transformation produces.

Now the second piece. Records are product types — all fields present, no optional parts, equality by value. Sealed interfaces are sum types — a closed list of variants the compiler knows in full. Put them together and you have algebraic data types: sums of products. `RiskDecision` is the sum; `Low()`, `Medium()`, `High()` are the products. To draw any conclusion from a `RiskDecision` you must handle each variant — that's Gentzen's ∨E, the same rule from S10. When you omit a case from the switch, the compiler is enforcing the elimination rule. Bob cannot forget `Medium` anymore. The compiler requires it."

→ Step 1 (20 sec): Show the top code pane. "'Functions are values — `Function<String,Integer>` is their type, the lambda is the value.' Point to `List<String>` annotation: `T·T`, type constructor. Point to `.map(idLength)`: `t·T`, polymorphic function. 'The compiler inferred `List<Integer>` — we never declared that. The return type is *computed* from the function you pass in.'"
→ Step 2 (20 sec): Open `03-java-function-types-sealed/PaymentMethod.java`. Show the sealed interface: sum type — three record variants, no default path in, compiler knows all cases.
→ Step 3 (20 sec): Open `Demo.java`, navigate to `demo4()`. Show the exhaustive switch on `RiskDecision` — all three cases present. "Each record is a product type; the sealed interface wraps them in a sum. ADTs."
→ Step 4 — LIVE DELETE MOMENT (60 sec): Delete the `case RiskDecision.Medium m -> "medium-risk 3DS path"` line live. Error to expect — javac/Eclipse: `"the switch expression does not cover all possible input values"` · IntelliJ: `"Switch is not exhaustive: 'RiskDecision.Medium' not handled"`. Read the error aloud, then say: "That compile error IS Gentzen's ∨E. You have not supplied the `[Medium]→C` branch. The compiler will not apply the elimination rule without it." Restore with ⌘Z.
→ Step 5 (30 sec): Navigate to the `Result<T>` refund switch in `demo4()`. "Same pattern on error handling. To use a `Result<T>`, you must handle both `Ok` and `Err`. No `getValue()` escape hatch. OR-elimination applied to error handling."
→ Step 6 (30 sec): Navigate to `buggyDemo_LifecycleStillUnchecked()`. Show `new PaymentService.Capture(...)` constructed directly. "This still compiles. Nothing in the type system prevents constructing a Capture without an Authorization first. Stage 4 closes it."
→ Return to slides.
]
