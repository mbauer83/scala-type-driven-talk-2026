// Clock: 14:30–15:30
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 3 · Acknowledged, Not Demoed]),
  [Function Pipelines · Rules as First-Class Values],
  stack(
    dir: ttb,
    spacing: sz(20pt),
    code-pane(filename: "Demo.java", language: "java")[
```java
// Business rule as a first-class value
Function<Payment<Initiated>, Result<Payment<Authorized>>> authorize3DSRule =
    payment -> ThreeDSService.challenge(payment)
               .flatMap(proof -> Payment.authorize3DS(payment, proof));

// Compose rules with andThen — scattered conditions become a pipeline
Function<Order, Result<Payment<Captured>>> checkoutPipeline =
    assessRisk
        .andThen(authorize3DSRule)
        .andThen(Payment::capture);
```
    ],
    callout(
      [Still open],
      [Neither generics nor function values change what states are _constructible_ or what branches must be handled. Records and sealed types do. Let's see how.],
      style: "accent",
    ),
  ),
)

#speaker-note[
"Java 8 also gave us function values. Stage 3 makes our business rules first-class — pipeline stages typed as functions from one lifecycle stage to the next, composed with `andThen`; risk rules as explicit, testable values rather than scattered conditions in service code. That code is in the repository. But neither generics nor function values change what states are constructible or what branches must be handled. Records and sealed types do. Let's see how."
]
