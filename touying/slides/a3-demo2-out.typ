// A3-demo2-out · captured output for Demo 2, verbatim from
// `demos/2-typestate.txt`. Fallback, and the freeze-frame to read from.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Demo 2 · javac], style: "bad"),
  body-gap: sz(26pt),
  [The lifecycle, enforced],
  stack(
    dir: ttb,
    spacing: sz(30pt),
    code-pane(
      filename: "Demo.java", language: "java", code-size: 20pt, pad-y: 12pt,
      highlights: ((2, "err"),),
      diagnostic: ("bad",
        "Demo.java:170: error",
        [incompatible types: `Payment<Initiated>` cannot be converted to
         `Payment<Authorized>`]),
    )[
```java
Payment<Initiated> init = Payment.initiate(order);
Payment.capture(init);
```
    ],
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      No test was written, and no reviewer was asked. The transition Charlie made
      is not a program.
    ],
  ),
)

#speaker-note[
#read("../scripts/18-demo2.md")
]
