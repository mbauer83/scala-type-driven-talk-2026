// Clock: 14:00–14:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [2],
  [Generics · Write Once, Prove for All],
  [java 5 · parametric polymorphism · System F],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    eyebrow(style: "accent")[→ DEMO 3 in `Validator.java`],
    code-pane(filename: "Validator.java", language: "java", highlights: ((11, "hl"),))[
```java
@FunctionalInterface
public interface Validator<T> {

    T validate(T value);

    // Composition: first run this, then run next (if this passes).
    default Validator<T> andThen(Validator<T> next) {
        return value -> next.validate(this.validate(value));
    }

    static <T> Validator<T> check(Predicate<T> predicate, String errorMessage) {
        return value -> {
            if (predicate.test(value)) return value;
            throw new IllegalArgumentException(errorMessage + ", got: " + value);
        };
    }
}
```
    ],
  ),
)

#speaker-note[
"Generics are System F polymorphism: write `Validator` once, the compiler proves it correct for every type it's instantiated with. Same for `AuditTrail` — inserting a Capture into a String-typed log is a compile error, not a runtime surprise, granting us some real architectural wins. But notice the bug class neither stage has touched: branching. The risk decision is a proper enum since Stage 1, but no `if/else` over that enum is forced to be exhaustive. Bob's incident from the opening is still a valid program here. That structural gap is what records and sealed types close, coming up in Stage 4."

→ Open `02-java5-generics/` — show `Validator<T>` with `andThen` composition in 10 sec.
→ Navigate to `AuditTrail<E>` — show the type-safe append in 10 sec.
→ Navigate to `buggyDemo_ForgottenBranch()` — show the if/else chain over `RiskDecision`, with MEDIUM silently falling to the fast path. Compiles. Runs. Output: "Authorized (no 3DS)" on a medium-risk order.
→ Say: "Architectural wins. Bug still compiles."
]
