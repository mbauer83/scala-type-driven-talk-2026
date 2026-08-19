// A6-monday · cap 0:55 · Act 6 beat 2 of 3 · MERGE of v1 where-to-start + 33-horizon
//
// The one slide in the deck that asks the audience to go and do something, which
// is exactly why MB found it presumptuous on 19 Aug: NOW / SOON / NEXT / HORIZON
// is a schedule for somebody else's team, and the rows told this room how to
// spend its sprints. Two changes fix that without losing the ladder:
//
//  - The title opens with the invitation — "Curious to try it out?" — so the four
//    rungs read as entry points rather than as instructions.
//  - The rungs are labelled by what each one costs YOU to try, cheapest first,
//    instead of by when your team is supposed to reach it. Every line is now
//    something one person can do without anybody's agreement.
//
// The lead line went with them. "A change one team makes in one service — and
// can undo in one service" is a symmetry doing the work of a sentence: it says
// only "reversible", which the rungs say better and concretely.
//
// Gradual typing lives here rather than on A6-cost (Part 3 put it there), because
// this slide IS the incremental ladder — the point is its frame rather than an
// aside. Kotlin platform types and TypeScript are Q&A.
//
// HORIZON absorbs 33-horizon, which budget.tsv has listed as "three lines on
// A6-monday" since the cut list was written. Lean's browser proof games are the
// one thing from that slide anybody will actually go and use.
//
// The v1 landing line — "the right question is not 'is this mature?'" — is gone.
// R1, and A6-cost says the positive version one slide earlier.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Where to start]),
  body-gap: sz(24pt),
  [Curious to try it out? — what to do on Monday],
  stack(
    dir: ttb,
    spacing: sz(40pt),
    [
      #set text(size: sz(26pt), fill: pal.fg)
      Cheapest first.
      #text(fill: pal.fg-dim)[ Every one of them is small enough to try on your
      own, before anybody has to agree to anything.]
    ],
    line(length: 100%, stroke: 0.5pt + pal.rule),
    beat-grid((
      (
        [AN AFTERNOON],
        [Sealed interfaces + switch expressions],
        [Java 17+, no new dependency, and the compiler starts checking that every
         case was handled.],
      ),
      (
        [ONE SERVICE],
        [Phantom typestate],
        [An interface and a private constructor, wherever there is a lifecycle.
         It stays inside that service, and it comes back out as easily as it went
         in.],
      ),
      (
        [A WEEKEND],
        [Scala 3 and the Iron library],
        [Where tonight's refinements came from. The sbt scaffold in the Stage 5
         repository builds and runs as it stands.],
      ),
      (
        [A RABBIT HOLE],
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
