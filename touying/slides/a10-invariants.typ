// APPENDIX · the complete invariant inventory. Here it is a Q&A artefact,
// which is what it is good for: nine invariants and the stage that removes
// each one.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Appendix · the full inventory]),
  body-gap: sz(28pt),
  [Nine invariants, and what closes each one],
    test-list(closes-width: 360pt, closes-size: 25pt, (
      ("1",  [Shape confusion — an Order where an Authorization belongs], [Stage 1 · named types], "active"),
      ("2",  [Wrong element type in typed collections],                           [Stage 2 · generics], "active"),
      ("3",  [All risk branches handled exhaustively],                            [Stage 3 · sealed + switch], "active"),
      ("4",  [Lifecycle ordering — capture only after authorize],                 [Stage 4 · phantom typestate], "active"),
      ("5",  [Right authorization method for the assessed risk level],            [Stage 5 · Approval\[R\]], "active"),
      ("6",  [Boundary constraints — non-empty identifiers],                      [Stage 5 · refinements], "active"),
      ("7",  [Client/server agree on the protocol shape],                         [Stage 5 · session duality], "active"),
      ("8",  [Channel is consumed completely (never dropped mid-protocol)],       [Stage 6 · use-once], "active"),
      ("9",  [Protocol shape matches the runtime risk classification],            [Stage 6 · dependent types], "active"),
    )),
)

#speaker-note[
Q&A only. If someone asks what the complete set of encoded invariants is, this is
it, with the stage that closes each. Not spoken in the main deck.
]
