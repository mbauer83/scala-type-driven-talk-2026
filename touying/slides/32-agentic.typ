// Clock: 42:00–43:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Agentic Development]),
  [Expressive Types in the Age of Agentic Development],
  stack(
    dir: ttb,
    spacing: sz(40pt),
    [
      #set text(size: sz(30pt), weight: 300)
      #set par(leading: 0.45em)
      Code is now being generated faster than humans can review it.
      Agents propose changes; teams ship them.

      When the type system can carry the invariants we care about,
      every generated line passes the same structural checks every hand-written line does.
      *The compiler does not care who wrote it.*
    ],
    callout(
      [Unwritable — regardless of author],
      grid(
        columns: (1fr, 1fr),
        gutter: sz(20pt),
        row-gutter: sz(8pt),
        [
          #set text(size: sz(26pt), font: mono-font, fill: pal.fg-dim)
          Incomplete protocol step #h(1fr) → does not compile.\
          Skipped lifecycle transition #h(1fr) → does not compile.
        ],
        [
          #set text(size: sz(26pt), font: mono-font, fill: pal.fg-dim)
          Empty identifier at the boundary #h(1fr) → does not compile.\
          Dropped channel without finish #h(1fr) → does not compile.
        ],
      ),
      style: "accent",
    ),
    stack(
      dir: ttb,
      spacing: sz(22pt),
      [
        #set text(size: sz(28pt), weight: 300)
        #set par(leading: 0.45em)
        For agentic workflows specifically: the type error is precise.
        #text(fill: pal.fg-dim, font: mono-font, size: sz(24pt))["Approval[LowRisk] does not conform to Approval[MediumRisk]"]
        tells the agent exactly which type is wrong and where — no human needed to interpret
        the failure. The compiler's type error IS the specification.
      ],
      [
        #set text(size: sz(26pt), fill: pal.fg-dim)
        #set par(leading: 0.45em)
        When generation speed exceeds review capacity, an expressive type system raises the
        share of correctness that is enforced before merge rather than spotted by a reviewer.
      ],
    ),
  ),
)

#speaker-note[
"There's another concrete reason this story matters now. AI agents can produce a working PR faster than a human can read it carefully. An expressive type system raises the floor of correctness that holds regardless of the author: incomplete protocol steps, skipped lifecycle transitions, empty identifiers, dropped channels — none of those compile, whether a person or a model wrote them. For agentic workflows specifically: the type error is precise. "Approval[LowRisk] does not conform to Approval[MediumRisk]" tells the agent exactly which type is wrong and where. The agent doesn't need a human to interpret the failure — the compiler's type error IS the specification. This is qualitatively different from a test failure, which says "the output was wrong" without saying what structural change would make it right. Proof assistants like Lean, Rocq, Agda, and Idris itself go further: the proof obligation becomes a first-class part of the type. In contrast to what we've seen — where the type checker automatically verifies structural properties, and you just declare the type — proof assistants let you encode more complex propositions as types, but to use a function you must also supply an explicit proof that the precondition holds. The machine checks that proof term mechanically, and modern tactic libraries automate increasing fractions of the work."
]
