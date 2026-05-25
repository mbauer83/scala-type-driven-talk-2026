// Clock: 11:30–12:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([The Payment Domain]),
  [Test Spine · What "Test Deleted" Really Means],
  stack(
    dir: ttb,
    spacing: sz(20pt),
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
    ladder(
      [Order → assess → authorize → capture → refund (where supported). Same scenario at every stage; comparisons are like-for-like.],
      [At Stage 0 every one of these is a runtime test someone has to remember to write.],
      [Nothing yet — Stages 1–7 ahead. Defensive tests shrink as invariants move into types.],
      encoded-active: false,
    ),
    story-strip((
      (name: "Alice",    what: [Empty OrderId slips through the boundary],          state: "open", closed: false),
      (name: "Bob",      what: [Medium-risk branch forgotten — wrong approval path], state: "open", closed: false),
      (name: "Charlie",  what: [Capture before authorize — lifecycle violated],      state: "open", closed: false),
      (name: "Danielle", what: [Client / server protocol drift at deployment],       state: "open", closed: false),
    )),
  ),
)

#speaker-note[
"One scenario carries the rest of the talk: an e-commerce payment — assess, authorize, capture, sometimes refund. What changes at each stage is how much of it the type system enforces. Don't try to read all nine items now — they'll reappear on every payoff slide as we tick them off. The bottom section is the honest part: defensive tests — 'did the developer remember X' — shrink in proportion to what we encode. Behavioural tests stay; you want those anyway. Verifying that the type definition correctly encodes the rule replaces per-call-site checks — paid once, in code review, at the definition."
]
