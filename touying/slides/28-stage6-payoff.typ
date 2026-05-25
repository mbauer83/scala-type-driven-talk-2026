// Clock: 33:45–34:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 6 Payoff · Scala 3]),
  [Three Stories Closed — Two Gaps Remain],
  stack(
    dir: ttb,
    spacing: sz(14pt),
    grid(
      columns: (1fr, 1fr, 1fr),
      gutter: sz(16pt),
      [
        #text(fill: pal.good, weight: 500, size: sz(24pt))[✓ BOB]
        #set text(size: sz(24pt), fill: pal.fg-dim)
        Protocol selects medium — `Approval LowRisk` rejected at compile time.
      ],
      [
        #text(fill: pal.good, weight: 500, size: sz(24pt))[✓ ALICE]
        #set text(size: sz(24pt), fill: pal.fg-dim)
        `OrderId` is `NonEmptyString`-refined. Empty string rejected at the boundary.
      ],
      [
        #text(fill: pal.good, weight: 500, size: sz(24pt))[✓ DANIELLE]
        #set text(size: sz(24pt), fill: pal.fg-dim)
        Server and client types from the same definition. Cannot drift.
      ],
    ),
    [
      #text(fill: pal.bad, weight: 500, size: sz(24pt))[⚠ TWO STRUCTURAL GAPS → Stage 7]
      #set text(size: sz(24pt), fill: pal.fg-dim)
      Protocol from ADT, not runtime `Order`. Dropped channel not caught. Stage 7 closes both.
    ],
    test-list((
      ("1",  [Shape confusion — passing an Order where an Authorization belongs], [S·1], "gone"),
      ("2",  [Wrong element type in typed collections],                           [S·2], "gone"),
      ("3",  [All risk branches handled exhaustively],                            [S·4], "gone"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [S·5], "gone"),
      ("5",  [Right authorization method for the assessed risk level],            [S·6], "just-gone"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·6], "just-gone"),
      ("7",  [Client/server agree on the protocol shape],                         [S·6], "just-gone"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·7], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·7], "active"),
    )),
    story-strip((
      (name: "Alice",    what: [Empty OrderId slips through the boundary],           state: "open", closed: true),
      (name: "Bob",      what: [Medium-risk branch forgotten — wrong approval path],  state: "open", closed: true),
      (name: "Charlie",  what: [Capture before authorize — lifecycle violated],       state: "open", closed: true),
      (name: "Danielle", what: [Client / server protocol drift at deployment],        state: "open", closed: true),
    )),
  ),
)

#speaker-note[
"Bob's story is done in this combination: once the protocol has selected the medium-risk path, a LowRisk approval cannot satisfy the channel's required MediumRisk evidence. It's the protocol context that catches the mistake. Alice's boundary class is done — an empty `OrderId` cannot exist at runtime, so consumers don't have to defend. Danielle's story is done — server and client hold types derived from the same protocol definition; they cannot drift. Two structural gaps remain: the protocol type is still selected at runtime from a fixed menu rather than computed from the runtime order; and the channel can be dropped without `finish()` being called. Stage 7 closes both."
]
