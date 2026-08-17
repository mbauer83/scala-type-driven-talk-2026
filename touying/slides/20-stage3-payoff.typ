// Clock: 19:00–19:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 3 Payoff · ADTs — Records + Sealed]),
  body-gap: sz(36pt),                            // payoff slides are dense — smaller headline gap
  [Bob Closed — One Gap Remains],
  stack(
    dir: ttb,
    spacing: sz(36pt),                        // generous gap between sections
    grid(
      columns: (1fr, 1fr),
      gutter: sz(28pt),
      [
        #text(fill: pal.good, weight: 500, size: sz(26pt))[✓ CLOSED] \
        #v(sz(6pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        ADTs: sum of products. Compiler requires every variant handled. Defensive per-call-site test deleted.
      ],
      [
        #text(fill: pal.bad, weight: 500, size: sz(26pt))[⚠ STILL EXPRESSIBLE → Stage 5] \
        #v(sz(6pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        Risk level not in authorization type. Wrong approval method still compiles.
      ],
    ),
    test-list((
      ("",   [2 invariants already closed ✓ — Stages 1–2],                        [],    "summary"),
      ("3",  [All risk branches handled exhaustively],                            [S·3], "just-gone"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [S·4], "active"),
      ("5",  [Right authorization method for the assessed risk level],            [S·5], "active"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·5], "active"),
      ("7",  [Client/server agree on the protocol shape],                         [S·5], "active"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·6], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·6], "active"),
    )),
    story-strip((
      (name: "Alice",    what: [Empty OrderId slips through the boundary],           state: "open", closed: false),
      (name: "Bob",      what: [Medium-risk branch forgotten — wrong approval path],  state: "open", closed: true),
      (name: "Charlie",  what: [Capture before authorize — lifecycle violated],       state: "open", closed: false),
      (name: "Danielle", what: [Client / server protocol drift at deployment],        state: "open", closed: false),
    )),
  ),
)

#speaker-note[
"Bob's immediate incident is closed — the branch can no longer be forgotten. The defensive 'did we test every branch' suite for that enum becomes unnecessary; we read the sealed-type definition once and confirm it covers the domain, and every consumer is automatically constrained. The deeper cause is still present though: the type of the risk decision doesn't flow into the authorization step. A developer can still write the Medium case, then call the wrong authorization method inside it. That's Stage 5's job."
]
