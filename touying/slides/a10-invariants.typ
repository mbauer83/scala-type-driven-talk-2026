// APPENDIX · the complete invariant inventory.
//
// Part 2 sent this out of the main deck and it never moved — it was still slide
// 10, headed "Demo Scenario & Potential Bugs", with a `CLOSES` column that gives
// the answer away before the suspense exists (P5) and a note that re-explained a
// scenario the room met on slide 2. Here it is a Q&A artefact, which is what it
// is good for: nine invariants and the stage that removes each one.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Appendix · the full inventory]),
  body-gap: sz(28pt),
  [Nine invariants, and where each one stops being a test],
    test-list((
      ("1",  [Shape confusion — passing an Order where an Authorization belongs], [S·1], "active"),
      ("2",  [Wrong element type in typed collections],                           [S·2], "active"),
      ("3",  [All risk branches handled exhaustively],                            [S·3], "active"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [S·4], "active"),
      ("5",  [Right authorization method for the assessed risk level],            [S·5], "active"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [S·5], "active"),
      ("7",  [Client/server agree on the protocol shape],                         [S·5], "active"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [S·6], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [S·6], "active"),
    )),
)

#speaker-note[
Q&A only. If someone asks what the complete set of encoded invariants is, this is
it, with the stage that closes each. Not spoken in the main deck.
]
