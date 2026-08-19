// The slide does three jobs instead: 1. restores the untyped floor. Stage 0
// was cut to "one line on A2-scenario" and the line was never written, so by
// Stage 1 there is nothing left to contrast against and Alice's incident has
// gone cold. 2. keeps the flow diagram, which is the spine of every later
// stage. 3. states what encoding a rule actually buys — the argument Act 2
// owes the room before the ladder starts.
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": *
#import "@preview/cetz:0.5.2": canvas, draw

#let payment-process = align(center)[
  #canvas({
    import draw: *
    let box-fill   = rgb("#ebe6d8")              // pal.bg-warm
    let box-stroke = (paint: rgb("#14161d"), thickness: 0.6pt)
    let arrow      = (paint: rgb("#14161d"), thickness: 0.6pt)
    let muted      = rgb("#5a5d68")

    let step(pos, name) = {
      let half-w = 1.05
      let half-h = 0.42
      rect(
        (pos.at(0) - half-w, pos.at(1) - half-h),
        (pos.at(0) + half-w, pos.at(1) + half-h),
        fill: box-fill, stroke: box-stroke, radius: 0.10,
      )
      content(pos, text(size: 11pt, weight: "medium", name))
    }
    let connect(a, b) = line(
      (a.at(0) + 1.05, a.at(1)),
      (b.at(0) - 1.05, b.at(1)),
      stroke: arrow,
      mark: (end: ">", fill: rgb("#14161d"), scale: 0.5),
    )

    let p-order  = (1.05,  0)
    let p-assess = (4.0,   0)
    let p-auth   = (7.0,   0)
    let p-cap    = (10.0,  0)
    let p-junc   = (12.3,  0)
    let p-ref    = (14.8,  1.10)
    let p-inv    = (14.8, -1.10)

    step(p-order,  [Order])
    step(p-assess, [assess])
    step(p-auth,   [authorize])
    step(p-cap,    [capture])
    connect(p-order, p-assess)
    connect(p-assess, p-auth)
    connect(p-auth,  p-cap)

    // Junction — small circle with × inside (XOR)
    circle(p-junc, radius: 0.22, fill: white, stroke: box-stroke)
    content(p-junc, text(size: 10pt, weight: "bold", [×]))
    line((p-cap.at(0) + 0.9, p-cap.at(1)), (p-junc.at(0) - 0.22, p-junc.at(1)),
         stroke: arrow)

    step(p-ref, [refund])
    step(p-inv, [invoice])
    // Diagonal arrows from junction to branch boxes
    line((p-junc.at(0) + 0.18, p-junc.at(1) + 0.18),
         (p-ref.at(0) - 1.05, p-ref.at(1)),
         stroke: arrow,
         mark: (end: ">", fill: rgb("#14161d"), scale: 0.5))
    line((p-junc.at(0) + 0.18, p-junc.at(1) - 0.18),
         (p-inv.at(0) - 1.05, p-inv.at(1)),
         stroke: arrow,
         mark: (end: ">", fill: rgb("#14161d"), scale: 0.5))

    // Branch annotations
    content((p-ref.at(0) + 1.6, p-ref.at(1)),
            text(size: 9pt, fill: muted, [(where supported)]),
            anchor: "west")
    content((p-inv.at(0) + 1.6, p-inv.at(1)),
            text(size: 9pt, fill: muted, [(no refund)]),
            anchor: "west")
  })
]


// Larger since the repeated flow diagram came off the slide: these four are
// the content, not a caption under a picture.
#let buys(head, body) = grid(
  columns: (sz(36pt), 1fr),
  column-gutter: sz(16pt),
  align: (left + top, left + top),
    text(size: sz(32pt), fill: pal.accent)[→],
  block[
    #set text(size: sz(32pt), fill: pal.fg)
    #set par(leading: 0.5em)
    #text(weight: 600)[#head] #h(sz(6pt))
    #text(fill: pal.fg-dim, size: sz(30pt))[#body]
  ],
)

#light-slide(
  eyebrow: eyebrow([The payment domain]),
  body-gap: sz(20pt),
  [What encoding a rule in the type system buys],
  stack(
    dir: ttb,
    spacing: sz(58pt),
    // The floor we start from — Alice's language had nothing to check.
    align(center)[
      #block(width: 100%, fill: pal.bg-warm, inset: (x: sz(28pt), y: sz(16pt)), radius: sz(4pt))[
        #grid(
          columns: (auto, 1fr),
          column-gutter: sz(36pt),
          align: (left + horizon, left + horizon),
          text(font: mono-font, size: sz(21pt), fill: pal.fg-faint, tracking: 0.06em)[THE FLOOR],
          [
            #set text(size: sz(24pt), fill: pal.fg-dim)
            Alice's service had no types at all —
            #text(font: mono-font, fill: pal.fg)["12" + "34"] is
            #text(font: mono-font, fill: pal.fg)["1234"], and nothing complains.
            That is where we start.
          ],
        )
      ]
    ],
    
    // One column, not two: with the flow diagram gone these four ARE the slide,
    // and a 2x2 left half of it empty.
    block(width: sz(1500pt))[
    #grid(
      columns: (1fr),
      row-gutter: sz(88pt),
      buys([Every use, not every call you remembered.],
           [The rule is applied where it is used, by the compiler.]),
      buys([The failure moves to compile time.],
           [Seconds after you typed it, not hours after you shipped it.]),
      buys([The intent is stated where the rule lives.],
           [Precise and small, at the definition — not a comment that can drift,
            and not a stack trace three services away at 2 a.m.]),
      buys([The defensive tests go.],
           [The ones that only ask _did somebody remember_. Behavioural tests stay.]),
    )],
  ),
)

#speaker-note[
#read("../scripts/10-scenario.md")
]
