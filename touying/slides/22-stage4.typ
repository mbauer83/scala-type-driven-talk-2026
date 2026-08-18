// A3-stage4 · cap 1:45 · Act 3 beat 6 of 8 · REWORK of v1 22-stage4
//
// v1 was a stage-opener with the three-line happy path and a signature card.
// The happy path is not the point: nothing on it can go wrong, so it shows the
// mechanism and hides the argument. Charlie's incident is the argument, and
// Part 3 puts his actual code here, next to the family of signatures that makes
// it unwriteable.
//
// The bridge from Bob is two spoken sentences (Part 4 deleted 21-bridge): Bob's
// bug was a missing CASE; Charlie's is a wrong ORDER, which no sum type catches.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 4 · phantom typestate · java]),
  body-gap: sz(18pt),
  [The check happens once, and the type remembers],
  stack(
    dir: ttb,
    spacing: sz(22pt),
    grid(
      columns: (1fr, 1.15fr),
      column-gutter: sz(44pt),
      row-gutter: sz(12pt),
      align: (left + top, left + top),

      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.bad)[Charlie's shortcut.] Load it, run it.
        Nothing asked whether it was approved.
      ],
      text(size: sz(24pt), fill: pal.fg-dim)[
        #text(weight: 600, fill: pal.good)[The gateway demands evidence] — and
        the repository cannot produce it.
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
          "Refund<?>                 findById(RefundId id)\n"
          + "Optional<Refund<Approved>> asApproved(Refund<?> r)\n"
          + "void                      execute(Refund<Approved> r)")
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
