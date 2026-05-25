// Clock: 40:00–40:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Stage 7 Payoff · Idris 2]),
  [All Stories Closed],
  stack(
    dir: ttb,
    spacing: sz(12pt),
    [
      #set text(size: sz(24pt), weight: 300, fill: pal.good)
      ✓ All four production incidents are now unrepresentable in the type system — not caught by tests.
    ],
    test-list((
      ("1",  [Shape confusion — passing an Order where an Authorization belongs], [S·1], "gone"),
      ("2",  [Wrong element type in typed collections],                           [S·2], "gone"),
      ("3",  [All risk branches handled exhaustively],                            [S·4], "gone"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [S·5], "gone"),
      ("5",  [Right authorization method for the assessed risk level],            [S·6], "gone"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·6], "gone"),
      ("7",  [Client/server agree on the protocol shape],                         [S·6], "gone"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·7], "gone"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·7], "gone"),
    )),
    ladder(
      [Lifecycle and authorization structurally enforced. Behavioural tests remain.],
      [Every invariant class has a compile-time test.],
      [All nine. Runtime-to-type via Π. Channel completion via multiplicity 1.],
      encoded-active: true,
    ),
  ),
)

#speaker-note[
"Each of these four production incidents — Alice's boundary, Bob's branch, Charlie's lifecycle, Danielle's protocol — has, at this point, become a program that cannot be expressed in the type system - a much stronger guarantee than 'we wrote a test that catches it.'"
]
