// Clock: 35:00–35:30
#import "../theme.typ": *
#import "../components.typ": *

// Clean stage opener — matches the format of all other stage openers (0–5).
// The Scala 3 ceiling callout and the two idris-block code examples have moved:
//   ceiling callout  → scala3-ceiling.typ (inserted before this slide)
//   idris code       → 29-mltt-running.typ (already present there as code-panes)

#stage-opener-slide(
  [6],
  [Idris 2 · The Final Bridge],
  [idris 2 · dependent types + quantitative type theory],
  [
    Π-types compute the protocol type from the runtime risk value. \
    QTT multiplicity-1 makes sure every protocol-stage is used exactly once.
  ],
)

#speaker-note[
// CUES:
// 1. "Third lambda-cube axis — type depends on a runtime value"
// 2. "protocolFromSnapshot takes a risk snapshot → returns a SessionType"
// 3. "That SessionType indexes the channel endpoints — openSession (protocolFromSnapshot snapshot n c)"
// 4. "QTT multiplicity 1: the channel is a linear resource — must be consumed exactly once"
// 5. → Advance to MLTT Running (S32) for the Idris demo

"Stage 6 adds the third lambda-cube axis: types whose shape depends on runtime values. The protocol isn't selected from a pre-declared menu — `protocolFromSnapshot` takes a runtime risk snapshot and returns a `SessionType` specific to that risk value. That session-type flows into `openSession`, which returns channel endpoints with the appropriate protocol. Every subsequent `send` and `receive` is type-checked against the protocol. Idris 2 also gives every binding a multiplicity: the default is omega — unrestricted use, like every other language we have seen. 1 means use exactly once. 0 means erased at runtime. Since the session channel has multiplicity 1, the linearity checker refuses any program that drops or re-uses it or fails to call `finish`. The two ideas — Π-types for the protocol shape and QTT for its completion — together close the two structural gaps that remained after Stage 5."
]
