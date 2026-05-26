// Clock: 11:30–12:00
#import "../theme.typ": *
#import "../components.typ": *
#import "@preview/cetz:0.3.4": canvas, draw

// ── ArchiMate-style flow: Order → assess → authorize → capture →⟨×⟩→ refund / invoice
//
// Each step is a rounded rectangle with an icon-strip on top-right (process
// glyph). Flow relations are open arrows; the or-junction is rendered as a
// small circle with "×" indicating exclusive-or branching.

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

#light-slide(
  eyebrow: eyebrow([The Payment Domain]),
  body-gap: sz(32pt),                          // healthy headline → diagram gap
  [Demo Scenario & Potential Bugs],
  stack(
    dir: ttb,
    spacing: sz(40pt),                        // equal gap diagram↔table↔callout
    payment-process,
    // Test inventory
    test-list((
      ("1",  [Shape confusion — passing an Order where an Authorization belongs], [S·1], "active"),
      ("2",  [Wrong element type in typed collections],                           [S·2], "active"),
      ("3",  [All risk branches handled exhaustively],                            [S·4], "active"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [S·5], "active"),
      ("5",  [Right authorization method for the assessed risk level],            [S·6], "active"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·6], "active"),
      ("7",  [Client/server agree on the protocol shape],                         [S·6], "active"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·7], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·7], "active"),
    )),
    // "What 'test deleted' really means" — three-line callout.
    block(
      width: 100%,
      inset: (left: sz(20pt), right: sz(20pt), y: sz(14pt)),
      stroke: (left: 2pt + pal.accent),
    )[
      #set text(size: sz(22pt), fill: pal.fg)
      #set par(leading: 0.4em)
      #text(weight: 600)[Defensive tests] — "did the developer remember X" — shrink as invariants move into types.\
      #text(weight: 600)[Behavioural tests] — "does the system charge the right amount" — stay. You want these anyway.\
      #text(weight: 600)[Type-definition review] — "does this type actually encode the rule" — replaces the per-call-site test, paid once at the definition.
    ],
  ),
)

#speaker-note[
"One scenario carries the rest of the talk: an e-commerce payment — assess, authorize, capture, sometimes refund. What changes at each stage is how much of it the type system enforces. Don't try to read all nine items now — they'll reappear on every payoff slide as we tick them off. The bottom section is the honest part: defensive tests — 'did the developer remember X' — shrink in proportion to what we encode. Behavioural tests stay; you want those anyway. Verifying that the type definition correctly encodes the rule replaces per-call-site checks — paid once, in code review, at the definition."
]
