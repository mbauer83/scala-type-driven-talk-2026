// Clock: Q&A — Tracking Capabilities
//
// Depth for A4-mechanisms, which carries the same pair in 40 seconds. This slide
// is NOT redundant with it: what it adds is the cost of each (monadic style vs
// direct), the status of each, the fact that they are not exclusive, and the
// linearity-vs-capability distinction. Keep it in step with the main slide —
// the capture-checking example was wrong on both until 19 Aug (MB): it
// annotated the returned value, `User^{db}`, instead of the arrow, and it
// dropped ZIO's error channel so the two sides did not correspond.
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Appendix A1 · Effect Systems], style: "accent"),
  [Tracking Capabilities: Effect Systems and Capture Checking],
  stack(
    dir: ttb,
    spacing: sz(36pt),
    [
      #set text(size: sz(28pt), weight: 300)
      #set par(leading: 0.45em)
      The shared concern: tracking _capabilities_ — IO, file handles, DB connections, mutable refs — in the type of every value that touches them.
    ],
    grid(
      columns: (1fr, 1fr),
      gutter: sz(28pt),
      callout(
        [Effect Systems (ZIO, cats-effect — production today)],
        stack(
          dir: ttb,
          spacing: sz(12pt),
          raw(lang: "scala", "def loadUser(id: UserId): ZIO[Database, DbError, User]"),
          [
            #set text(size: sz(24pt), fill: pal.fg-dim)
            The `R` parameter tracks "this needs a Database"; `A` tracks the success type; `E` tracks errors. Mature, widely deployed, large community libraries.

            #v(sz(8pt))
            #text(fill: pal.fg)[Cost:] monadic style — for-comprehensions, `.flatMap` chains.
          ],
        ),
        style: "accent",
      ),
      callout(
        [Capture Checking (Scala 3, experimental — "Caprese")],
        stack(
          dir: ttb,
          spacing: sz(12pt),
          raw(lang: "scala", "val loadUser: UserId ->{db, canThrow} User"),
          [
            #set text(size: sz(24pt), fill: pal.fg-dim)
            The capture set sits on the arrow: `db` is the database capability, `canThrow` is a `CanThrow[DbError]`, and the result is a plain `User` — the same three things ZIO puts in its parameters. `A ->{c} B` is shorthand for `(A -> B)^{c}`; a `throws E` clause desugars to `using CanThrow[E]`, which is why the two experiments compose. Use-after-close, capability escape and effect leaks become compile errors, and the code keeps its ordinary shape.

            #v(sz(8pt))
            #text(fill: pal.fg)[Status:] experimental in Scala 3; not yet production.
          ],
        ),
        style: "accent",
      ),
    ),
    [
      #set text(size: sz(26pt), fill: pal.fg-dim)
      These approaches are not exclusive — a project can use ZIO today and migrate piecewise as Capture Checking matures. Linearity (multiplicity-1 from Stage 6) is a related but distinct question: it restricts _how many times_ a value may be used, not _which capabilities_ it carries.
    ],
  ),
)

#speaker-note[
"Effect systems and Capture Checking are two answers to the same problem: how do you put 'this function needs a database' or 'this function touches IO' into the type? ZIO and cats-effect — in production now — do it by wrapping the result in a monad whose parameters track the capability, the error channel, and the success type. The cost is that your code becomes monadic; you stay in for-comprehensions. Capture Checking is the Scala 3 experimental direction that tries to do this without the monad — the capabilities a function reaches for are tracked on its arrow, and your code keeps its imperative shape. They are not exclusive: a project can absolutely use ZIO today and migrate piecewise as Capture Checking matures. If the multiplicity-1 mechanism from Stage 6 comes up here, the linearity slide (A2) covers it — it restricts how many times a value may be used, a related but distinct question from which capabilities it carries."
]
