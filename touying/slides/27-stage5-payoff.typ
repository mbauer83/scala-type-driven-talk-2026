// Clock: 33:45–34:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 5 Payoff · Scala 3]),
  body-gap: sz(28pt),                            // S29 is the densest payoff — extra tight
  [Three Stories Closed — Two Gaps Remain],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    // Single condensed status line — three closed, two open.
    grid(
      columns: (1fr, 1fr),
      gutter: sz(28pt),
      [
        #text(fill: pal.good, weight: 500, size: sz(24pt))[✓ Three stories closed] \
        #v(sz(4pt))
        #set text(size: sz(22pt), fill: pal.fg-dim)
        #set par(leading: 0.4em)
        Protocol selects medium · `OrderId` is `NonEmptyString`-refined · server/client types from one definition.
      ],
      [
        #text(fill: pal.bad, weight: 500, size: sz(24pt))[⚠ Two gaps → Stage 6] \
        #v(sz(4pt))
        #set text(size: sz(22pt), fill: pal.fg-dim)
        #set par(leading: 0.4em)
        Protocol from ADT, not runtime `Order`. Dropped channel not caught.
      ],
    ),
    test-list((
      ("",   [4 invariants already closed ✓ — Stages 1–4],                        [],    "summary"),
      ("5",  [Right authorization method for the assessed risk level],            [S·5], "just-gone"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·5], "just-gone"),
      ("7",  [Client/server agree on the protocol shape],                         [S·5], "just-gone"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·6], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·6], "active"),
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
"Bob's story is done in this combination: once the protocol has selected the medium-risk path, a LowRisk approval cannot satisfy the channel's required MediumRisk evidence. It's the protocol context that catches the mistake. Alice's boundary class is done — an empty `OrderId` cannot exist at runtime, so consumers don't have to defend. Danielle's story is done — server and client hold types derived from the same protocol definition; they cannot drift. Two structural gaps remain: the protocol type is still selected at runtime from a fixed menu rather than computed from the runtime order; and the channel can be dropped without `finish()` being called. Stage 6 closes both."
]
