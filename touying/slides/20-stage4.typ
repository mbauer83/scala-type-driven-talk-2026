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
    spacing: sz(28pt),
    eyebrow(style: "accent")[→ DEMO 4 in `Demo.java`],
    // Two code panes side-by-side; equal-height by 1fr row + 100%-height boxes.
    // Tighter code-size on both so the RiskDecision lines don't wrap.
    grid(
      columns: (1fr, 1fr),
      rows: (auto,),                       // size to content, not the whole slide
      gutter: sz(24pt),
      align: (left + top, left + top),
      code-pane(filename: "RiskDecision.java", language: "java", code-size: 20pt)[
```java
sealed interface RiskDecision
    permits Low, Medium, High {

  record Low()    implements RiskDecision {}
  record Medium() implements RiskDecision {}
  record High()   implements RiskDecision {}
}

// Compiler knows the full variant set.
```
      ],
      code-pane(filename: "Demo.java", language: "java", code-size: 20pt,
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
    v(sz(40pt)),  // generous breathing room above the recall caption
    // ── Gentzen ∨E rule — caption row beneath the two panes; (∨E) sits with
    //   generous horizontal spacing so it doesn't ride into the formula.
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
"Records are product types — all fields required, no silent nulls. Sealed interfaces are sum types — the `permits` clause declares every possible variant, and the compiler knows all of them. Exhaustive switch is Gentzen's ∨E: to draw any conclusion from a disjunction, you must have handled every variant. Bob can no longer forget the Medium case. The compiler requires it. Stage 4's live demo will show both the sealed definition and the live deletion of a branch."

→ Step 1 (20 sec): Open `04-java17-records-sealed/PaymentMethod.java`. Show the sealed interface: three record variants, no default path in.
→ Step 2 (20 sec): Open `Demo.java`, navigate to `demo4()`. Show the exhaustive switch on `RiskDecision` — all three cases present.
→ Step 3 — LIVE DELETE MOMENT (60 sec): Delete the `case Medium m -> "3DS path"` line live. Watch the compiler report the error: "switch covers only 2 of 3 permitted subclasses" (or equivalent). Read it aloud. Say: "That compile error IS Gentzen's ∨E. You have not supplied the `[Medium]→C` branch. The compiler cannot apply the elimination rule." Restore with ⌘Z.
→ Step 4 (30 sec): Navigate to the `Result<T>` refund switch. Say: "Same pattern applied to error handling. To use a `Result<T>`, you must handle both `Ok` and `Err`. There is no `getValue()` escape hatch. OR-elimination applied to error handling."
→ Step 5 (30 sec): Navigate to `buggyDemo_LifecycleStillUnchecked()`. Show `new PaymentService.Capture(...)` constructed directly without an Authorization. Say: "This still compiles. `Capture` is a plain record with a public constructor. Nothing in the type system prevents this. Stage 5 fixes it."
→ Return to slides.
]
