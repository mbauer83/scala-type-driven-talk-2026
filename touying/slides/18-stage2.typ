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
"Stage 1 gave us nominal types and smart constructors. Stage 2 adds the second dimension: parametric polymorphism — System F. Write `Validator` once, and the compiler proves it correct for every type it's instantiated with. Same for `AuditTrail` — inserting a Capture into a String-typed log is a compile error, not a runtime surprise. Real architectural wins. But notice the bug class neither stage has touched: branching. The risk decision is a proper enum since Stage 1, but no `if/else` over that enum is forced to be exhaustive. Bob's incident from the opening is still a valid program here. That structural gap is what records and sealed types close, coming up in Stage 4."

→ Open `02-java5-generics/` — show `Validator<T>` with `andThen` composition in 10 sec. L. 122 in Demo.java (the `Validator` composition demo).
→ Navigate to `AuditTrail<E>` — show the type-safe append at Demo.java L. 76 (declaration) and PaymentService.java L. 51 (append call in processLowRisk) in 10 sec.
→ Navigate to `pickAuthPath()` at L. 150 first — show the non-exhaustive if/else over `RiskDecision`: LOW and HIGH handled, MEDIUM falls through to the fast path silently. Then navigate to `buggyDemo_ForgottenBranch()` at L. 158 to show it being called.
→ Run the demo. Output: "Authorized (no 3DS)" on a medium-risk order — no error.
→ Say: "Architectural wins. Bug still compiles."
]
