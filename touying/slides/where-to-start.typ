// A6-monday · cap 0:55 · Act 6 beat 2 of 3 · MERGE of v1 where-to-start + 33-horizon
//
// The one slide in the deck that tells the audience to do something, so the four
// rungs keep their v1 wording — they were already right. Three things changed:
//
//  1. The frame at the top. Gradual typing lives here rather than on A6-cost
//     (Part 3 put it there); this slide IS the incremental ladder, so the point
//     is its frame rather than an aside. In the room's own terms, which was the
//     plan's own instruction — a raw type talking to a generic one, @Nullable
//     going on file by file. Kotlin platform types and TypeScript are Q&A.
//  2. HORIZON absorbs 33-horizon, which budget.tsv has listed as "three lines on
//     A6-monday" since the cut list was written. Lean's browser proof games are
//     the one thing from that slide anybody will actually go and use.
//  3. The v1 landing line — "the right question is not 'is this mature?'" — is
//     gone. R1, and A6-cost says the positive version one slide earlier.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Where to start]),
  body-gap: sz(24pt),
  [What to do on Monday],
  stack(
    dir: ttb,
    spacing: sz(40pt),
    [
      #set text(size: sz(26pt), fill: pal.fg)
      Each of these is a change one team makes in one service
      #text(fill: pal.fg-dim)[ — and can undo in one service.]
    ],
    line(length: 100%, stroke: 0.5pt + pal.rule),
    beat-grid((
      (
        [NOW],
        [Sealed interfaces + switch expressions],
        [Java 17, no new dependency. An afternoon.],
      ),
      (
        [SOON],
        [Phantom typestate],
        [An interface and a private constructor, on the one service that carries
         a lifecycle — a sprint, and it touches nothing else.],
      ),
      (
        [NEXT],
        [Scala 3 and the Iron library],
        [Where tonight's refinements came from. The sbt scaffold is in the Stage 5
         repository.],
      ),
      (
        [HORIZON],
        [Idris 2 · Lean 4],
        [Brady's _Type-Driven Development with Idris_ is the on-ramp. Lean teaches
         itself in a browser — the proof games at `adam.math.hhu.de`.],
      ),
    )),
    align(right)[
      #text(size: sz(21pt), fill: pal.fg-faint, font: mono-font)[
        full reading list → appendix A7
      ]
    ],
  ),
)

#speaker-note[
#read("../scripts/30-monday.md")
]
