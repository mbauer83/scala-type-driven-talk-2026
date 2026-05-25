// Clock: 15:30–16:00
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#stage-opener-slide(
  [4],
  [Records · Sealed Types · Sum Types],
  [java 17 · sum types + exhaustive switch · Gentzen ∨E],
  stack(
    dir: ttb,
    spacing: sz(18pt),
    eyebrow(style: "accent")[→ DEMO 4 in `Demo.java`],
    grid(
      columns: (1fr, auto, 1fr),
      gutter: sz(24pt),
      code-pane(filename: "RiskDecision.java", language: "java")[
```java
sealed interface RiskDecision
    permits Low, Medium, High {

  record Low()    implements RiskDecision {}
  record Medium() implements RiskDecision {}
  record High()   implements RiskDecision {}
}
```
      ],
      align(center + horizon)[
        #set text(size: sz(22pt), fill: pal.fg-dim, font: mono-font)
        #stack(
          dir: ttb,
          spacing: sz(12pt),
          [A ∨ B    \[A\]→C    \[B\]→C],
          line(length: 100%, stroke: 0.5pt + pal.fg-dim),
          [C],
        )
        #v(sz(8pt))
        #text(size: sz(18pt), fill: pal.fg-faint)[Gentzen ∨E (recall S10)]
      ],
      code-pane(filename: "Demo.java", language: "java", highlights: ((4, "hl-good"),))[
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
  ),
)

#speaker-note[
"Records are product types — all fields required, no silent nulls. Sealed interfaces are sum types — the `permits` clause declares every possible variant, and the compiler knows all of them. Exhaustive switch is Gentzen's ∨E: to draw any conclusion from a disjunction, you must have handled every variant. Bob can no longer forget the Medium case. The compiler requires it. Stage 4's live demo will show both the sealed definition and the live deletion of a branch."

→ Step 1 (20 sec): Open `04-java17-records-sealed/PaymentMethod.java`. Show the sealed interface: three record variants, no default path in.
→ Step 2 (20 sec): Open `Demo.java`, navigate to `demo4()`. Show the exhaustive switch on `RiskDecision` — all three cases present.
→ Step 3 — LIVE DELETE MOMENT (60 sec): Delete the `case Medium m -> "3DS path"` line live. Watch the compiler report the error: "switch covers only 2 of 3 permitted subclasses" (or equivalent). Read it aloud. Say: "That compile error IS Gentzen's ∨E. You have not supplied the `[Medium]→C` branch. The compiler cannot apply the elimination rule." Restore with ⌘Z.
→ Step 4 (30 sec): Navigate to the `Result<T>` refund switch. Say: "Same pattern applied to error handling. To use a `Result<T>`, you must handle both `Ok` and `Err`. There is no `getValue()` escape hatch. OR-elimination applied to error handling."
→ Step 5 (30 sec): Navigate to `buggyDemo_LifecycleStillUnchecked()`. Show `new PaymentService.Capture(...)` constructed directly without an Authorization. Say: "This still compiles. `Capture` is a plain record with a public constructor. Nothing in the type system prevents this. Stage 5 fixes it."
→ Return to slides.
]
