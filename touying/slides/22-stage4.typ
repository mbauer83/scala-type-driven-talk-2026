#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 4 · phantom typestate · java]),
  body-gap: sz(34pt),
  [The check happens once, and the type remembers],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    grid(
      columns: (1fr, 1.15fr),
      column-gutter: sz(44pt),
      row-gutter: sz(20pt),
      align: (left + top, left + top),

      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.bad)[Charlie's shortcut.] Load it, run it.
        Nothing asked whether it was approved.
      ],
      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.good)[A reviewer's approval is an argument] —
        and on the high-risk path you need one to get an authorized payment.
      ],

      block(width: 100%, fill: pal.bad-bg, radius: sz(6pt),
            inset: (x: sz(22pt), y: sz(18pt)))[
        #show raw: set text(font: mono-font, size: sz(18pt), fill: pal.fg)
        #raw(block: true,
          "var refund = refundRepo.findById(id);\npaymentGateway.execute(refund);")
      ],
      block(width: 100%, fill: pal.bg-dark-2, stroke: 0.5pt + pal.rule-dark-strong,
            radius: sz(6pt), inset: (x: sz(22pt), y: sz(18pt)))[
        #show raw: set text(font: mono-font, size: sz(18pt), fill: pal.fg-dark)
        #raw(block: true,
          "authorizeReview(Payment<Initiated>, ManualReviewApproval)\n"
          + "                       -> Payment<Authorized>")
      ],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),

    // The state ladder, from the real file. Without this the room never sees
    // the phantom parameter written out before Demo 2's error names two of its
    // values — and the demo breaks Payment, while Charlie's card above is about
    // a refund, so the two need visibly joining.
    stack(
      dir: ttb,
      spacing: sz(16pt),
      [
        #set text(size: sz(24pt), fill: pal.fg)
        #text(weight: 600)[One parameter, four values, and Charlie's refund is
        the last rung of the same ladder.]
        #text(fill: pal.fg-dim)[ You cannot refund what was never captured, or
        capture what was never authorized. `Payment.java`, bodies elided.]
      ],
      // No highlight: green reads as "this is the fix", and capture is not the
      // fix — it is the line Demo 2 is about to break. Let the room find it when
      // the error names it.
      code-pane(filename: "Payment.java", language: "java", code-size: 17pt, pad-y: 12pt)[
```java
public final class Payment<S extends PaymentState> { ... }

static Payment<Initiated>        initiate(Order order)
static Payment<Authorized>       authorizeAuto(Payment<Initiated> p)
static Payment<Captured>         capture(Payment<Authorized> p)
static Result<Payment<Refunded>, PaymentError>
                                 refund(Payment<Captured> p, RefundMechanism m)
```
      ],
    ),

    line(length: 100%, stroke: 0.5pt + pal.rule),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(48pt),
      [
        #set text(size: sz(24pt), fill: pal.fg)
        #set par(leading: 0.45em)
        #text(weight: 600)[No type knows what is in your database.]
        #text(fill: pal.fg-dim)[ What it can do is make the gateway unreachable
        until somebody has asked — once, at the boundary. What the asking hands
        back is #text(fill: pal.fg, weight: 500)[provenance]: where the value has
        been, carried in its type.]
      ],
      [
        #set text(size: sz(24pt), fill: pal.fg)
        #set par(leading: 0.45em)
        #text(weight: 600)[Inside your own code there is no check to run.]
        #text(fill: pal.fg-dim)[ `Payment<Initiated>` and `Payment<Authorized>`
        are the same bytes; the parameter carries no data, only which methods
        will accept the value.]
      ],
    ),
  ),
)

#speaker-note[
#read("../scripts/17-stage4.md")
]
