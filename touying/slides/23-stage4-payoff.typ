// Clock: 24:30–25:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 4 Payoff · Phantom Typestate]),
  body-gap: sz(36pt),
  [Charlie Closed — Two Gaps Remain],
  stack(
    dir: ttb,
    spacing: sz(36pt),
    grid(
      columns: (1fr, 1fr),
      gutter: sz(28pt),
      [
        #text(fill: pal.good, weight: 500, size: sz(26pt))[✓ CLOSED] \
        #v(sz(6pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        `Payment[Authorized]` is the lifecycle proof. Capture-before-authorize unrepresentable.
      ],
      [
        #text(fill: pal.bad, weight: 500, size: sz(26pt))[⚠ STILL EXPRESSIBLE → Stage 5] \
        #v(sz(6pt))
        #set text(size: sz(24pt), fill: pal.fg-dim)
        Risk level not in the type. Non-empty boundary still a runtime check.
      ],
    ),
    test-list((
      ("",   [3 invariants already closed ✓ — Stages 1–3],                        [],    "summary"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [S·4], "just-gone"),
      ("5",  [Right authorization method for the assessed risk level],            [S·5], "active"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·5], "active"),
      ("7",  [Client/server agree on the protocol shape],                         [S·5], "active"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·6], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·6], "active"),
    )),
    story-strip((
      (name: "Alice",    what: [Empty OrderId slips through the boundary],           state: "open", closed: false),
      (name: "Bob",      what: [Medium-risk branch forgotten — wrong approval path],  state: "open", closed: true),
      (name: "Charlie",  what: [Capture before authorize — lifecycle violated],       state: "open", closed: true),
      (name: "Danielle", what: [Client / server protocol drift at deployment],        state: "open", closed: false),
    )),
  ),
)

#speaker-note[
"Charlie's story is done. The lifecycle ordering has moved into the type itself — from the runtime check it was at Stage 0–2, from the class-name convention it was at Stage 3, into a structural property the compiler enforces. Two things remain expressible here, both closed by Stage 5: the risk level isn't yet in the type, so a medium-risk order can still be sent through `authorizeAuto`; and boundary predicates like 'this identifier is non-empty' are still runtime checks. Those are the next stage's work."
]
