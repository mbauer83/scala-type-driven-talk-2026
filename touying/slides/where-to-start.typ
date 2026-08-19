// Two changes fix that without losing the ladder:  - The title opens with the
// invitation — "Curious to try it out?" — so the four rungs read as entry
// points rather than as instructions. - The rungs are labelled by what each
// one costs YOU to try, cheapest first, instead of by when your team is
// supposed to reach it. Every line is now something one person can do without
// anybody's agreement. The lead line went with them. Kotlin platform types and
// TypeScript are Q&A. Lean's browser proof games are the one thing from that
// slide anybody will actually go and use. R1, and A6-cost says the positive
// version one slide earlier.
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
         repository builds and runs as it stands — or `rockthejvm.com` if you
         would rather be taught than handed a build file.],
      ),
      (
        [A RABBIT HOLE],
        [Idris 2 · Lean 4],
        [Brady's _Type-Driven Development with Idris_ is the on-ramp. Lean has
         proof games that run in a browser with nothing to install —
         `adam.math.hhu.de`.],
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
